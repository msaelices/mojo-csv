import os
from time import perf_counter_ns
from csv import reader
from python import Python, PythonObject

from utils import Variant

alias File = Variant[FileHandle, PythonObject]

alias BenchFunc = fn (file: FileHandle) raises -> None
alias PyBenchFunc = fn (file: PythonObject) raises -> None


fn mojo_csv_read(file: FileHandle) raises:
    var csv_reader = reader(
        file, delimiter=",", quotechar='"', doublequote=True
    )
    i = 0
    for row in csv_reader:
        i += 1
    _ = file.seek(0)


fn python_csv_read(file: PythonObject) raises:
    py_csv = Python.import_module("csv")
    var csv_reader = py_csv.reader(
        file, delimiter=",", quotechar='"', doublequote=True
    )
    i = 0
    for row in csv_reader:
        i += 1
    _ = file.seek(0)


fn do_bench[function](file: File) -> Int:
    for i in range(10):
        if file.isa[FileHandle]():
            function(file[FileHandle]())
        else:
            function(file[PythonObject]())
    report = 0
    for i in range(10):
        start = perf_counter_ns()
        if file.isa[FileHandle]():
            function(file[FileHandle]())
        else:
            function(file[PythonObject]())
        end = perf_counter_ns()
        report = max(report, end - start)
    return report


fn run_bench[
    function_python: PyBenchFunc, function_mojo: BenchFunc
](quiet: Bool = False) raises -> Tuple[Int, Int]:
    csv_file_path = "test.csv"
    with open(csv_file_path, "w") as f:
        f.write(String("a,b,c\n"))
        for i in range(100):
            f.write(str(i) + "," + str(i) + "," + str(i) + "\n")

    file = Python.import_module("builtins").open(csv_file_path, "r")
    report_python = do_bench[function_python](file)
    file.close()

    with open(csv_file_path, "r") as file:
        report_mojo = do_bench[function_mojo](file)

    if not quiet:
        print("Mojo runtime (ns): \t", report_mojo)
        print("PyMojo runtime (ns): \t", report_python)

    os.remove(csv_file_path)
    return report_python, report_mojo


fn main() raises:
    _ = run_bench[python_csv_read, mojo_csv_read]()
