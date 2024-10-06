import benchmark
from csv import reader
from python import Python


alias BenchFunc = fn[file_path: String] () raises -> None


fn mojo_csv_read[file_path: String]() raises:
    with open(file_path, "r") as file:
        csv_reader = reader(
            file, delimiter=",", quotechar='"', doublequote=True
        )
        i = 0
        for row in csv_reader:
            i += 1


fn python_csv_read[file_path: String]() raises:
    py_open = Python.import_module("builtins").open
    py_csv = Python.import_module("csv")
    file = py_open(file_path, "r")
    csv_reader = py_csv.reader(
        file, delimiter=",", quotechar='"', doublequote=True
    )
    i = 0
    for row in csv_reader:
        i += 1
    file.close()


fn run_bench[
    function_python: BenchFunc, function_mojo: BenchFunc, csv_file_path: String
](quiet: Bool = False) raises -> Tuple[Float64, Float64, Float64]:
    var report_python = benchmark.run[function_python[csv_file_path]](
        max_runtime_secs=1.0
    ).mean(benchmark.Unit.ms)
    var report_mojo = benchmark.run[function_mojo[csv_file_path]](
        max_runtime_secs=1.0
    ).mean(benchmark.Unit.ms)

    var speedup = report_python / report_mojo

    if not quiet:
        print("Python runtime (ms): \t", report_python)
        print("Mojo runtime (ms): \t", report_mojo)
        print("Speedup factor: \t\t", (speedup))

    return report_python, report_mojo, speedup


fn main() raises:
    _ = run_bench[python_csv_read, mojo_csv_read, "test.csv"]()
