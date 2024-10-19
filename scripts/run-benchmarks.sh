#!/bin/sh

# To be able to import the local csv module
export MODULAR_MOJO_MAX_NIGHTLY_IMPORT_PATH=..

mojo ./benchmarks/csv_bench.mojo
python ./benchmarks/csv_bench.py
