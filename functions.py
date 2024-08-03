from ctypes import *

so_file = "./libpyfunctions.so.1.0.0"
nasmfunctions = CDLL(so_file)

###########################################################################################################
# integer-based functions
###########################################################################################################

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

def sortasc(arr):
    result = nasmfunctions.sortasc(arr, len(arr))
    return (result, [arr[i] for i in range(len(arr))])

def sortdsc(arr):
    result = nasmfunctions.sortdsc(arr, len(arr))
    return (result, [arr[i] for i in range(len(arr))])

def contains(arr, element):
    return nasmfunctions.contains(arr, len(arr), element)

def compare(arr1, arr2):
    return nasmfunctions.compare(arr1, len(arr1), arr2, len(arr2))

def add(arr1, arr2):
    result = nasmfunctions.add(arr1, len(arr1), arr2, len(arr2))
    return (result, [arr1[i] for i in range(len(arr1))])

def mul(arr1, arr2):
    result = nasmfunctions.mul(arr1, len(arr1), arr2, len(arr2))
    return (result, [arr1[i] for i in range(len(arr1))])

def dot(arr1, arr2):
    return nasmfunctions.dot(arr1, len(arr1), arr2, len(arr2))

def unique(arr):
    result = nasmfunctions.unique(arr, len(arr))
    new_array = [arr[i] for i in range(0,result)]
    return (result, new_array)

def mode(arr):
    return nasmfunctions.mode(arr, len(arr))

###########################################################################################################
# floating point functions - work in progress..
###########################################################################################################

nasmfunctions.d_square.restype = c_double
nasmfunctions.d_square.argtypes = [c_double]
def d_square(a):
    return nasmfunctions.d_square(a)

nasmfunctions.d_min.restype = c_double
def d_min(arr):
    return nasmfunctions.d_min(arr, len(arr)) 

nasmfunctions.d_max.restype = c_double
def d_max(arr):
    return nasmfunctions.d_max(arr, len(arr))

nasmfunctions.d_sum.restype = c_double
def d_sum(arr):
    return nasmfunctions.d_sum(arr, len(arr)) 