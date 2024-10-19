from csv import reader, Dialect
from testing import assert_equal, assert_raises
from pathlib import Path, _dir_of_current_file
from test_utils import assert_line_equal


def test_dialect():
    var d = Dialect(delimiter=",", quotechar='"', lineterminator="\n")
    assert_equal(d.delimiter, ",")
    assert_equal(d.quotechar, '"')
    assert_equal(d.lineterminator, "\n")
    assert_equal(d.quoting, 0)
    assert_equal(d.doublequote, False)
    assert_equal(d.escapechar, "")
    assert_equal(d.skipinitialspace, False)
    d.validate()
    assert_equal(d._valid, True)

    d = Dialect(delimiter=",,", quotechar='"', lineterminator="\n", quoting=1)
    assert_equal(d.quoting, 1)
    with assert_raises(contains="delimiter must be a 1-character string"):
        d.validate()


def test_reader():
    var csv_path = _dir_of_current_file() / "people.csv"
    with open(csv_path, "r") as csv_file:
        var r = reader(
            csv_file,
            delimiter=",",
            doublequote=True,
            quotechar='"',
            lineterminator="\n",
        )
        var r_it = r.__iter__()
        assert_line_equal(
            r_it.__next__(),
            List(String("Name"), String("Age"), String("Gender")),
        )
        assert_line_equal(
            r_it.__next__(),
            List(String("Peter, Smith"), String("23"), String("'Male'")),
        )
        assert_line_equal(
            r_it.__next__(),
            List(String('Dwayne "The Rock"'), String("52"), String("Male")),
        )
        assert_line_equal(
            r_it.__next__(),
            List(String("Martín"), String("43"), String("Male")),
        )
