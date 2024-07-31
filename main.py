import functions
import time
import numpy as np
import random
import ctypes

def run_tests():

    # unsigned
    x = 5
    arr = [11, 102, 88, 99, 55]
    c_arr = (ctypes.c_int * len(arr))(*arr)

    assert functions.median(c_arr) == 88, "UNSIGNED MEDIAN failed."
    assert functions.dummy(x) == 5, "UNSIGNED DUMMY failed."
    assert functions.square(x) == 25, "UNSIGNED SQUARE failed."
    assert functions.mean(c_arr) == 71, "UNSIGNED MEAN failed."
    assert functions.max(c_arr) == 102, "UNSIGNED MAX failed."
    assert functions.min(c_arr) == 11, "UNSIGNED MIN failed."
    assert functions.sum(c_arr) == 355, "UNSIGNED SUM failed."

    # signed
    x = -2
    arr = [11, -2, 88, 99, 55]
    c_arr = (ctypes.c_int * len(arr))(*arr)

    assert functions.square(x) == 4, "SIGNED SQUARE failed."
    assert functions.min(c_arr) == -2, "SIGNED MIN failed"

    print("All tests passed.")

run_tests()