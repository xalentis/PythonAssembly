import functions
import time
import numpy as np
import random
import ctypes

def run_tests():

    # test values
    x = 5
    arr = [11, 102, 88, 99]
    c_arr = (ctypes.c_int * len(arr))(*arr)

    assert functions.dummy(x) == 5, "DUMMY failed."
    assert functions.square(x) == 25, "SQUARE failed."
    assert functions.mean(c_arr) == 75, "MEAN failed."
    assert functions.max(c_arr) == 102, "MAX failed."
    assert functions.min(c_arr) == 11, "MIN failed."
    assert functions.sum(c_arr) == 300, "SUM failed."

    print("All tests passed.")

def dummy(value):
    return value

def run_performance():

    x = 5 # test value

    ##############################################################################
    print("Dummy Functions:")
    t0 = time.time()
    result = 0
    for index in range(1,1000000):
        result = dummy(x)
    t1 = time.time()
    print("Std     : " + str(t1-t0)) # 0.053304433822631836

    t0 = time.time()
    result = 0
    for index in range(1,1000000):
        result = functions.dummy(x)
    t1 = time.time()
    print("Assembler: " + str(t1-t0)) # 0.1439192295074463

    # quite a lot of overhead involved in calling outside of Python
    # for simple, single-value functions that can be performed inside Python
    # without having to use Numpy, so in those cases, just stick with Python.

    ##############################################################################
    print("Non-Array Functions:")
    t0 = time.time()
    result = 0
    for index in range(1,1000000):
        result = (x^2)
    t1 = time.time()
    print("Std     : " + str(t1-t0)) # 0.0241546630859375

    t0 = time.time()
    result = 0
    for index in range(1,1000000):
        result = np.square(x)
    t1 = time.time()
    print("Numpy   : " + str(t1-t0)) # 0.3786153793334961

    t0 = time.time()
    result = 0
    for index in range(1,1000000):
        result = functions.square(x)
    t1 = time.time()
    print("Assembly: " + str(t1-t0)) # 0.14838027954101562

    ##############################################################################
    print("Array Functions:")
    arr = [random.choice(range(100)) for _ in range(100)]
    c_arr = (ctypes.c_int * len(arr))(*arr)

    t0 = time.time()
    result = 0
    for index in range(1,1000000):
        result = max(arr)
    t1 = time.time()
    print("Array   : " + str(t1-t0)) # 0.7592031955718994

    t0 = time.time()
    result = 0
    np_arr = np.array(arr)
    for index in range(1,1000000):
        result = np.max(np_arr)
    t1 = time.time()
    print("Numpy   : " + str(t1-t0)) # 1.4104564189910889

    t0 = time.time()
    result = 0
    for index in range(1,1000000):
        result = functions.max(c_arr)
    t1 = time.time()
    print("Assembly: " + str(t1-t0)) # 0.244368314743042


run_tests()
run_performance()