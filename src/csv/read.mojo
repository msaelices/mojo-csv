from memory import memcmp, memcpy, Pointer, UnsafePointer

from .dialects import (
    Dialect,
    QUOTE_MINIMAL,
    QUOTE_ALL,
    QUOTE_NONNUMERIC,
    QUOTE_NONE,
    QUOTE_STRINGS,
    QUOTE_NOTNULL,
)


struct reader:
    """
    CSV reader.

    This struct reads CSV files.

    Example:

        >>> with open("example.csv", "r") as csvfile:
        ...     reader = csv.reader(csvfile, delimiter=",", quotechar='"')
        ...     for row in reader:
        ...         print(row)
        ['a', 'b', 'c']
        ['1', '2', '3']
    """

    var dialect: Dialect
    """The CSV dialect."""
    var content: String
    """The content of the CSV file."""

    fn __init__(
        inout self: Self,
        csvfile: FileHandle,
        delimiter: String,
        quotechar: String = '"',
        escapechar: String = "",
        doublequote: Bool = False,
        skipinitialspace: Bool = False,
        lineterminator: String = "\r\n",
        quoting: Int = QUOTE_MINIMAL,
    ) raises:
        """
        Initialize a Dialect object.

        Args:
            csvfile: The CSV file to read from.
            delimiter: The delimiter used to separate fields.
            quotechar: The character used to quote fields containing special
                characters.
            escapechar: The character used to escape the delimiter or quotechar.
            doublequote: Whether quotechar inside a field is doubled.
            skipinitialspace: Whether whitespace immediately following the
                delimiter is ignored.
            lineterminator: The sequence used to terminate lines.
            quoting: The quoting mode.
        """
        self.dialect = Dialect(
            delimiter=delimiter,
            quotechar=quotechar,
            escapechar=escapechar,
            doublequote=doublequote,
            skipinitialspace=skipinitialspace,
            lineterminator=lineterminator,
            quoting=quoting,
        )
        self.dialect.validate()

        # TODO: Implement streaming to prevent loading the entire file into memory
        self.content = csvfile.read()

    fn __iter__(self: Self) raises -> _ReaderIter[__lifetime_of(self)]:
        """
        Iterate through the CSV lines.

        Returns:
            Iterator.
        """
        return _ReaderIter[__lifetime_of(self)](reader=self)

    fn __len__(self: Self) -> Int:
        """
        Get the number of lines in the CSV file.

        Returns:
            The number of lines in the CSV file.
        """
        return len(self.content)


# ===------------------------------------------------------------------=== #
# Auxiliary structs and functions
# ===------------------------------------------------------------------=== #

alias START_RECORD = 0
alias START_FIELD = 1
alias IN_FIELD = 2
alias IN_QUOTED_FIELD = 3
alias ESCAPED_CHAR = 4
alias ESCAPED_IN_QUOTED_FIELD = 5
alias END_FIELD = 6
alias END_RECORD = 7
alias QUOTE_IN_QUOTED_FIELD = 8


struct _ReaderIter[
    reader_mutability: Bool, //,
    reader_lifetime: Lifetime[reader_mutability].type,
](Sized):
    """Iterator for any random-access container"""

    var reader_ref: Pointer[reader, reader_lifetime]
    var pos: Int
    var field_pos: Int
    var quoted: Bool
    var quotechar: String
    var delimiter: String
    var doublequote: Bool
    var escapechar: String
    var quoting: Int
    var eat_crnl: Bool
    var content_ptr: UnsafePointer[UInt8]
    var bytes_len: Int

    fn __init__(inout self, ref [reader_lifetime]reader: reader):
        self.reader_ref = Pointer.address_of(reader)
        self.pos = 0
        self.field_pos = 0
        self.quoted = False
        self.quotechar = reader.dialect.quotechar
        self.delimiter = reader.dialect.delimiter
        self.doublequote = reader.dialect.doublequote
        self.escapechar = reader.dialect.escapechar
        self.quoting = reader.dialect.quoting
        self.content_ptr = reader.content.unsafe_ptr()
        self.bytes_len = len(reader)
        self.eat_crnl = False

    @always_inline
    fn __next__(inout self: Self) raises -> List[String]:
        return self.next_row()

    fn __hasmore__(self) -> Int:
        # This is the current way to imitate the StopIteration exception
        # TODO: Remove when the iterators are implemented and streaming is done
        return (self.bytes_len - self.pos) > 0

    fn next_row(inout self) -> List[String]:
        var row = List[String]()

        # TODO: This is spaghetti code mimicing the CPython implementation
        #       We should refactor this to be more readable and maintainable
        #       See parse_process_char() function in cpython/Modules/_csv.c
        var state = START_RECORD

        var content_ptr = self.content_ptr
        var delimiter_ptr = self.delimiter.unsafe_ptr()
        var delimiter_len = self.delimiter.byte_length()
        var quotechar_ptr = self.quotechar.unsafe_ptr()
        var quotechar_len = self.quotechar.byte_length()
        var escapechar_ptr = self.escapechar.unsafe_ptr()
        var escapechar_len = self.escapechar.byte_length()

        @always_inline
        fn _is_delimiter(ptr: UnsafePointer[UInt8]) -> Bool:
            return _is_eq(ptr, delimiter_ptr, delimiter_len)

        @always_inline
        fn _is_quotechar(ptr: UnsafePointer[UInt8]) -> Bool:
            return _is_eq(ptr, quotechar_ptr, quotechar_len)

        @always_inline
        fn _is_escapechar(ptr: UnsafePointer[UInt8]) -> Bool:
            return escapechar_len and _is_eq(
                ptr, escapechar_ptr, escapechar_len
            )

        if _is_eol(content_ptr.offset(self.pos)):
            self.pos += 1

        self.field_pos = self.pos
        self.eat_crnl = False

        while self.pos < self.bytes_len:
            var curr_ptr = content_ptr.offset(self.pos)

            # print(
            #     "CHAR: ", repr(chr(int(curr_ptr[]))), " STATE:", state, " POS: ", self.pos
            # )

            # TODO: Use match statement when supported by Mojo
            if state == START_RECORD:
                if _is_eol(curr_ptr):
                    state = END_RECORD
                else:
                    state = START_FIELD
                continue  # do not consume the character
            elif state == START_FIELD:
                self.field_pos = self.pos
                if _is_delimiter(curr_ptr):
                    # save empty field
                    self._save_field(row)
                elif _is_quotechar(curr_ptr):
                    self._mark_quote()
                    state = IN_QUOTED_FIELD
                else:
                    state = IN_FIELD
                    continue  # do not consume the character
            elif state == IN_FIELD:
                if _is_delimiter(curr_ptr):
                    state = END_FIELD
                    continue
                elif _is_eol(curr_ptr):
                    state = END_RECORD
                elif _is_escapechar(curr_ptr):
                    state = ESCAPED_CHAR
            elif state == IN_QUOTED_FIELD:
                if _is_quotechar(curr_ptr):
                    if self.doublequote:
                        state = QUOTE_IN_QUOTED_FIELD
                    else:  # end of quoted field
                        state = IN_FIELD
                elif _is_escapechar(curr_ptr):
                    state = ESCAPED_IN_QUOTED_FIELD
            elif state == QUOTE_IN_QUOTED_FIELD:
                # double-check with CPython implementation
                if _is_quotechar(curr_ptr):
                    state = IN_QUOTED_FIELD
                elif _is_delimiter(curr_ptr):
                    self._save_field(row)
                    state = START_FIELD
            elif state == ESCAPED_CHAR:
                state = IN_QUOTED_FIELD
            elif state == ESCAPED_IN_QUOTED_FIELD:
                state = IN_QUOTED_FIELD
            elif state == END_FIELD:
                self._save_field(row)
                state = START_FIELD
            elif state == END_RECORD:
                self.eat_crnl = True
                break

            self.pos += 1

        if self.field_pos < self.pos:
            self.eat_crnl = True
            self._save_field(row)

        # TODO: Handle the escapechar and skipinitialspace options
        return row

    @always_inline("nodebug")
    fn _mark_quote(inout self):
        self.quoted = True

    fn _save_field(inout self, inout row: List[String]):
        start_idx, end_idx = (
            self.field_pos,
            self.pos,
        ) if not self.quoted else (self.field_pos + 1, self.pos - 1)
        if self.eat_crnl:
            end_idx -= 1

        var src_ptr = self.content_ptr.offset(start_idx)
        var length = end_idx - start_idx
        var data_ptr = UnsafePointer[UInt8].alloc(length + 1)
        memcpy(
            dest=data_ptr,
            src=src_ptr,
            count=length,
        )
        data_ptr[length] = 0  # null-terminate the string

        var field = String(data_ptr)

        if self.doublequote:
            quotechar = self.quotechar
            field = field.replace(quotechar * 2, quotechar)
        row.append(field)

        # reset values
        self.quoted = False


@always_inline("nodebug")
fn _is_eq(
    ptr1: UnsafePointer[UInt8], ptr2: UnsafePointer[UInt8], len: Int
) -> Bool:
    return memcmp(ptr1, ptr2, len) == 0


@always_inline("nodebug")
fn _is_eol(ptr: UnsafePointer[UInt8]) -> Bool:
    alias nl = ord("\n")
    alias cr = ord("\r")
    var c = ptr[]
    return c == nl or c == cr
