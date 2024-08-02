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