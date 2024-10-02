from csv import Dialect
from testing import assert_equal, assert_raises


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
