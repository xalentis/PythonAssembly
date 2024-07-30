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

    assert functions.square(x) == 25, "SQUARE failed."
    assert functions.mean(c_arr) == 75, "MEAN failed."
    assert functions.max(c_arr) == 102, "MAX failed."
    assert functions.min(c_arr) == 11, "MIN failed."
    assert functions.sum(c_arr) == 300, "SUM failed."

    print("All tests passed.")


def run_performance():

    # test values
    x = 5

    print("Non-Array Functions:")
    t0 = time.time()
    result = 0
    for index in range(1,1000000):
        result = (x^2)
    t1 = time.time()
    print("Array   : " + str(t1-t0)) # 0.0241546630859375

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

# Non-Array Functions:
# Array   : 0.025586843490600586
# Numpy   : 0.3618752956390381
# Assembly: 0.14081716537475586
#
# Array Functions:
# Array   : 0.6767127513885498
# Numpy   : 1.2847113609313965
# Assembly: 0.23765349388122559