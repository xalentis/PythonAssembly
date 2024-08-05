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

def sub(arr1, arr2):
    result = nasmfunctions.sub(arr1, len(arr1), arr2, len(arr2))
    return (result, [arr1[i] for i in range(len(arr1))])

def mul(arr1, arr2):
    result = nasmfunctions.mul(arr1, len(arr1), arr2, len(arr2))
    return (result, [arr1[i] for i in range(len(arr1))])

def dot(arr1, arr2):
    return nasmfunctions.dot(arr1, len(arr1), arr2, len(arr2))

def unique(arr):
    result = nasmfunctions.unique(arr, len(arr))
    new_array = [arr[i] for i in range(result)]
    return (result, new_array)

###########################################################################################################
# floating point functions
###########################################################################################################

nasmfunctions.d_square.restype = c_double
nasmfunctions.d_square.argtypes = [c_double]
def d_square(a):
    return nasmfunctions.d_square(a)

nasmfunctions.d_mean.restype = c_double
def d_mean(arr):
    return nasmfunctions.d_mean(arr, len(arr))

nasmfunctions.d_max.restype = c_double
def d_max(arr):
    return nasmfunctions.d_max(arr, len(arr))

nasmfunctions.d_min.restype = c_double
def d_min(arr):
    return nasmfunctions.d_min(arr, len(arr)) 

nasmfunctions.d_sum.restype = c_double
def d_sum(arr):
    return nasmfunctions.d_sum(arr, len(arr))

def d_add(arr1, arr2):
    result = nasmfunctions.d_add(arr1, len(arr1), arr2, len(arr2))
    return (result, [arr1[i] for i in range(len(arr1))])

def d_sub(arr1, arr2):
    result = nasmfunctions.d_sub(arr1, len(arr1), arr2, len(arr2))
    return (result, [arr1[i] for i in range(len(arr1))])

def d_mul(arr1, arr2):
    result = nasmfunctions.d_mul(arr1, len(arr1), arr2, len(arr2))
    return (result, [arr1[i] for i in range(len(arr1))])

nasmfunctions.d_dot.restype = c_double
def d_dot(arr1, arr2):
    return nasmfunctions.d_dot(arr1, len(arr1), arr2, len(arr2))

def d_compare(arr1, arr2):
    return nasmfunctions.d_compare(arr1, len(arr1), arr2, len(arr2))

nasmfunctions.d_contains.argtypes = [POINTER(c_double), c_int, c_double]
nasmfunctions.d_contains.restype = c_int
def d_contains(arr, element):
    return nasmfunctions.d_contains(arr, len(arr), element)

nasmfunctions.d_sortasc.argtypes = [POINTER(c_double), c_int]
nasmfunctions.d_sortasc.restype = c_int
def d_sortasc(arr):
    result = nasmfunctions.d_sortasc(arr, len(arr))
    return (result, [arr[i] for i in range(len(arr))])

nasmfunctions.d_sortdsc.argtypes = [POINTER(c_double), c_int]
nasmfunctions.d_sortdsc.restype = c_int
def d_sortdsc(arr):
    result = nasmfunctions.d_sortdsc(arr, len(arr))
    return (result, [arr[i] for i in range(len(arr))])

nasmfunctions.d_median.argtypes = [POINTER(c_double), c_int]
nasmfunctions.d_median.restype = c_double
def d_median(arr):
    return nasmfunctions.d_median(arr, len(arr))

nasmfunctions.d_unique.argtypes = [POINTER(c_double), c_int]
nasmfunctions.d_unique.restype = c_int
def d_unique(arr):
    result = nasmfunctions.d_unique(arr, len(arr))
    return (result, [arr[i] for i in range(result)])
