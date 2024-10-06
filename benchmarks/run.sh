#!/bin/sh

# To be able to import the local csv module
export MODULAR_MOJO_MAX_NIGHTLY_IMPORT_PATH=..

mojo csv_bench.mojo
python csv_bench.py
