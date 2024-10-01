from csv.write import writer
from testing import assert_equal, assert_raises
from pathlib import Path, _dir_of_current_file


def test_writer():
    var csv_path = _dir_of_current_file() / "animals.csv"
    csv_file_to_write = open(csv_path, "w")
    var r = writer(
        csv_file_to_write^,
        delimiter=",",
        doublequote=True,
        quotechar='"',
        lineterminator="\n",
    )
    r.writerow(List[String]("Name", "Species", "Age"))
    r.writerow(List[String]("Peter", "Rabbit", "5"))
    r.writerow(List[String]("Dwayne", "Dog", "3"))
    r.writerow(List[String]("Martín", "Cat", "7"))

    with open(csv_path, "r") as csv_file:
        contents = csv_file.read()
        assert_equal(
            contents,
            '"Name","Species","Age"\n"Peter","Rabbit","5"\n"Dwayne","Dog","3"\n"Martín","Cat","7"\n',
        )
