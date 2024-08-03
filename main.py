import functions
import time
import numpy as np
import random
import ctypes

def run_tests():

    # tests
    x = 5
    arr = [11, 102, 88, 99, 55]
    c_arr = (ctypes.c_int * len(arr))(*arr)
    arr2 = [22, 55, 77, 44, 66]
    c_arr2 = (ctypes.c_int * len(arr2))(*arr2)

    # work in progress:
    arr3 = [22, 55, 77, 44, 66]
    c_arr3 = (ctypes.c_int * len(arr3))(*arr3)
    result = functions.mode(c_arr3)
    
    # these tests return a single numeric results
    assert functions.compare(c_arr, c_arr) == 1, "COMPARE failed equal."
    assert functions.compare(c_arr, c_arr2) != -1, "COMPARE failed not equal."
    assert functions.contains(c_arr, 88) == 2, "CONTAINS failed."
    assert functions.contains(c_arr, 44) == -1, "CONTAINS failed."
    assert functions.median(c_arr) == 88, "MEDIAN failed."
    assert functions.square(x) == 25, "SQUARE failed."
    assert functions.mean(c_arr) == 71, "MEAN failed."
    assert functions.max(c_arr) == 102, "MAX failed."
    assert functions.min(c_arr) == 11, "MIN failed."
    assert functions.sum(c_arr) == 355, "SUM failed."

    # these tests returns a tuple of (result, arr)
    # these tests modify the contents of first array upon return
    c_arr = (ctypes.c_int * len(arr))(*arr)
    c_arr2 = (ctypes.c_int * len(arr2))(*arr2)
    assert functions.add(c_arr, c_arr2) == (1, [33, 157, 165, 143, 121]), "ADD failed."
    c_arr = (ctypes.c_int * len(arr))(*arr)
    assert functions.sortasc(c_arr) == (1,[11, 55, 88, 99, 102]), "SORT ASC failed."
    c_arr = (ctypes.c_int * len(arr))(*arr)
    assert functions.sortdsc(c_arr) == (1,[102, 99, 88, 55, 11]), "SORT DSC failed."
    c_arr = (ctypes.c_int * len(arr))(*arr)
    c_arr2 = (ctypes.c_int * len(arr2))(*arr2)
    assert functions.mul(c_arr, c_arr2) == (1, [242, 5610, 6776, 4356, 3630]), "MUL failed."
    c_arr = (ctypes.c_int * len(arr))(*arr)
    c_arr2 = (ctypes.c_int * len(arr2))(*arr2)
    assert functions.dot(c_arr, c_arr2) == 20614, "DOT failed."
    arr3 = [22, 55, 77, 55, 88]
    c_arr3 = (ctypes.c_int * len(arr3))(*arr3)
    assert functions.unique(c_arr3) == (4, [22, 55, 77, 88]), "UNIQUE failed."

    print("All tests passed.")

run_tests()