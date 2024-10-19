fn assert_line_equal(lhs: List[String], rhs: List[String]) raises:
    if not lhs == rhs:
        raise Error(
            "AssertionError: value "
            + lhs.__repr__()
            + " not equal to "
            + rhs.__repr__()
        )
