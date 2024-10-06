# import benchmark
import os
from time import time
from csv import reader


def csv_read(file):
    csv_reader = reader(
        file, delimiter=",", quotechar='"', doublequote=True
    )
    i = 0
    for row in csv_reader:
        i += 1
    file.seek(0)


def run_bench(quiet: bool = False):
    csv_file_path = "test.csv"
    with open(csv_file_path, "w") as f:
        f.write("a,b,c\n")
        for i in range(100):
            f.write(f"{i},{i},{i}\n")

    with open(csv_file_path, "r") as file:
        # Warmup
        for i in range(10):
            csv_read(file)
        # Execute the function and measure the max runtime
        report_python = 0
        for i in range(10):
            start = time()
            csv_read(file)
            end = time()
            duration = end - start
            report_python = max(report_python, duration)
        file.close()

    if not quiet:
        print("Python runtime (ns): \t", int(report_python * 1_000_000_000))

    os.remove(csv_file_path)

    return report_python


if __name__ == "__main__":
    run_bench()
