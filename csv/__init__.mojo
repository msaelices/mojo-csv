"""
CSV parsing and writing.

This module provides classes that assist in the reading and writing
of Comma Separated Value (CSV) files, and implements the interface
described by PEP 305.  Although many CSV files are simple to parse,
the format is not formally defined by a stable specification and
is subtle enough that parsing lines of a CSV file with something
like line.split(",") is bound to fail.  The module supports three
basic APIs: reading, writing, and registration of dialects.

Example:

    >>> import csv
    >>> with open("example.csv", "r") as csvfile:
    ...     reader = csv.reader(csvfile, delimiter=",", quotechar='"')
    ...     for row in reader:
    ...         print(row)
    ['a', 'b', 'c']
    ['1', '2', '3']
"""

from .reader import Dialect, Reader
