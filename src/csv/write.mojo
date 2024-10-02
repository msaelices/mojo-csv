from memory import Box


from .dialects import (
    Dialect,
    QUOTE_MINIMAL,
)


struct writer:
    """
    CSV writer.

    This struct write CSV files.

    Example:

        >>> csvfile = open("example.csv", "w")
        >>> writer = csv.writer(csvfile^, delimiter=",", quotechar='"')
        >>> writer.writerow(["a", "b", "c"])
        >>> writer.writerow(["1", "2", "3"])
    """

    var dialect: Dialect
    """The CSV dialect."""
    # var csvfile_ref: Reference[FileHandle, writer_lifetime]
    var csvfile_box: Box[FileHandle]
    """The CSV file."""

    fn __init__(
        inout self: Self,
        owned csvfile: FileHandle,
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
        self.csvfile_box = Box(csvfile^)

    fn writerow(inout self: Self, row: List[String]) raises -> None:
        """
        Write a row to the CSV file.

        Args:
            row: The row to write.
        """
        var line: String = ""
        var i = 0
        for i in range(len(row)):
            field = row[i]
            if i > 0:
                line += self.dialect.delimiter
            line += self.dialect.quotechar
            for c in field:
                if c == self.dialect.quotechar:
                    line += self.dialect.quotechar
                line += c
            line += self.dialect.quotechar
        line += self.dialect.lineterminator

        self.csvfile_box[].write(line)
