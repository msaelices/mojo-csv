import os
from time import perf_counter_ns
from csv import reader
from python import Python, PythonObject


alias BenchFunc = fn (file: FileHandle) raises -> None
alias PyBenchFunc = fn (
    file: PythonObject, py_reader: PythonObject
) raises -> None


fn mojo_csv_read(file: FileHandle) raises:
    var csv_reader = reader(
        file, delimiter=",", quotechar='"', doublequote=True
    )
    i = 0
    for row in csv_reader:
        i += 1
    _ = file.seek(0)


fn python_csv_read(file: PythonObject, py_reader: PythonObject) raises:
    var csv_reader = py_reader(
        file, delimiter=",", quotechar='"', doublequote=True
    )
    i = 0
    for row in csv_reader:
        i += 1
    _ = file.seek(0)


fn run_bench[
    function_python: PyBenchFunc, function_mojo: BenchFunc
](quiet: Bool = False) raises -> Tuple[Int, Int]:
    csv_file_path = "test.csv"
    with open(csv_file_path, "w") as f:
        f.write(String("a,b,c\n"))
        for i in range(100):
            f.write(str(i) + "," + str(i) + "," + str(i) + "\n")

    py_csv = Python.import_module("csv")
    # with Python.import_module('builtins').open(csv_file_path, "r") as file:
    file = Python.import_module("builtins").open(csv_file_path, "r")
    # Warmup
    for i in range(10):
        function_python(file, py_csv.reader)
    # Execute the function and measure the max runtime
    report_python = 0
    for i in range(10):
        start = perf_counter_ns()
        function_python(file, py_csv.reader)
        end = perf_counter_ns()
        duration = end - start
        report_python = max(report_python, duration)
    file.close()

    with open(csv_file_path, "r") as file:
        # Warmup
        for i in range(10):
            function_mojo(file)
        # Execute the function and measure the maximum max runtime
        report_mojo = 0
        for i in range(10):
            start = perf_counter_ns()
            function_mojo(file)
            end = perf_counter_ns()
            duration = end - start
            report_mojo = max(report_mojo, duration)

    if not quiet:
        print("Mojo runtime (ns): \t", report_mojo)
        print("PyMojo runtime (ns): \t", report_python)

    os.remove(csv_file_path)
    return report_python, report_mojo


fn main() raises:
    _ = run_bench[python_csv_read, mojo_csv_read]()
