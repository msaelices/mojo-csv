# mojo-csv

   ![Written in Mojo][language-shield]
   [![MIT License][license-shield]][license-url]

`mojo-csv` is a lightweight library for parsing and writing CSV files that adheres closely to the Python standard library's `csv` module. It aims to provide an intuitive and familiar interface with additional features for enhanced usability.

## Features

- **CSV Reading**: Supports reading from and writing to CSV files with a familiar API.
- **Custom Delimiters**: Easily specify custom delimiters, quote characters, and line terminators.
- **Data Validation**: Includes optional data validation during parsing.
- **Compatibility**: API similar to Python's `csv` module for easy transition and minimal learning curve.

## Example of usage

```mojo
from csv import reader

def main():
    with open('data.csv', 'r') as file:
        csv_reader = reader(file, delimiter=',', quotechar='"', doublequote=True)
        i = 0
        for row in csv_reader:
            i += 1
            print(','.join(row))

if __name__ == '__main__':
    main()
```

## TODO

- [ ] CSV writing

## Installation

COMPLETE
