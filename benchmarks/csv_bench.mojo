import os
from time import perf_counter_ns
from csv import reader
from python import Python, PythonObject

from utils import Variant

alias BenchFunc = fn (file: FileHandle) raises -> None


fn csv_read(file: FileHandle) raises:
    var csv_reader = reader(
        file, delimiter=",", quotechar='"', doublequote=True
    )
    i = 0
    for row in csv_reader:
        i += 1
    _ = file.seek(0)


fn do_bench[function: BenchFunc](file: FileHandle) raises -> Int:
    # warmup
    for _ in range(10):
        function(file)
    report = 0
    # measure
    for _ in range(10):
        start = perf_counter_ns()
        function(file)
        end = perf_counter_ns()
        report = max(report, end - start)
    return report


fn run_bench[function: BenchFunc](quiet: Bool = False) raises -> Int:
    var report_mojo: Int
    var csv_file_path = "test.csv"

    with open(csv_file_path, "w") as f:
        f.write(String("a,b,c\n"))
        for i in range(100):
            f.write(i, ",", i, ",", i, "\n")

    with open(csv_file_path, "r") as file:
        report_mojo = do_bench[function](file)

    if not quiet:
        print("Mojo runtime (ns): \t", report_mojo)

    os.remove(csv_file_path)
    return report_mojo


fn main() raises:
    _ = run_bench[csv_read]()
