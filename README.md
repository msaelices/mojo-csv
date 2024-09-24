# mojo-csv

`mojo-csv` is a lightweight library for parsing and writing CSV files that adheres closely to the Python standard library's `csv` module. It aims to provide an intuitive and familiar interface with additional features for enhanced usability.

## Disclaimer ⚠️

This software is in a early stage of development, using the Mojo nightly version.

## Features

- **CSV Reading**: Supports reading from and writing to CSV files with a familiar API.
- **Custom Delimiters**: Easily specify custom delimiters, quote characters, and line terminators.
- **Data Validation**: Includes optional data validation during parsing.
- **Compatibility**: API similar to Python's `csv` module for easy transition and minimal learning curve.

## Installation

1. **Install [Mojo nightly](https://docs.modular.com/mojo/manual/get-started) 🔥**

2. **Add the CSV Package** (at the top level of your project):

    ```bash
    curl -o "csv.mojopkg" https://raw.githubusercontent.com/msaelices/mojo-csv/main/csv.mojopkg
    ```

    <!-- > *<span style="color: green;">**Note:**</span> In the near future, you will be able to simply call `magic add csv`, which will manage this dependency in your project's environment automatically. QOL is in sight!* -->

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
```

## TODO

- [ ] CSV writing
- [ ] Optimizations leveraging SIMD

## Contributing

Contributions are welcome! If you'd like to contribute, please follow the contribution guidelines in the [CONTRIBUTING.md](CONTRIBUTING.md) file in the repository.

## License

mojo-csv is licensed under the [MIT license](LICENSE).
