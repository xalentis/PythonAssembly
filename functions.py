from ctypes import *

so_file = "./libpyfunctions.so.1.0.0"
nasmfunctions = CDLL(so_file)

def dummy(a):
    return nasmfunctions.dummy(a)

def square(a):
    return nasmfunctions.square(a)

def mean(arr):
    return nasmfunctions.mean(arr, len(arr))

def max(arr):
    return nasmfunctions.max(arr, len(arr))   

def min(arr):
    return nasmfunctions.min(arr, len(arr))

def sum(arr):
    return nasmfunctions.sum(arr, len(arr))

def median(arr):
    return nasmfunctions.median(arr, len(arr))
