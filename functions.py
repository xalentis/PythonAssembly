from ctypes import *

so_file = "./libpyfunctions.so.1.0.0"
nasmfunctions = CDLL(so_file)

nasmfunctions.mean.argtypes = (POINTER(c_int), c_int)
nasmfunctions.mean.restype = c_int

def square(a):
    return nasmfunctions.square(a)

def mean(arr):
    c_arr = (c_int * len(arr))(*arr)
    return nasmfunctions.mean(c_arr, len(arr))

def max(arr):
    c_arr = (c_int * len(arr))(*arr)
    return nasmfunctions.max(c_arr, len(arr))   

def min(arr):
    c_arr = (c_int * len(arr))(*arr)
    return nasmfunctions.min(c_arr, len(arr))

def sum(arr):
    c_arr = (c_int * len(arr))(*arr)
    return nasmfunctions.sum(c_arr, len(arr))   