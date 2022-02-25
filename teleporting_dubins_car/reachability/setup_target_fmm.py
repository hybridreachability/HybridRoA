#!/usr/bin/env python
import numpy as np
import scipy.io
import h5py
import skfmm

file = scipy.io.loadmat('dubins_target_binary_hybrid.mat')

grid_min = file['grid']['min']
grid_max = file['grid']['max']
grid_shape = file['grid']['shape']
grid_shape = grid_shape[0, 0].squeeze()
print(grid_shape)

M = int(.5 * grid_shape[2])
print(M)
grid_dx = np.asarray(file['grid']['dx'][0, 0]).squeeze().tolist()
print(grid_dx)

target_binary = file['binary_target']
print(target_binary.shape)
print(target_binary[9, 0, int(M/2)])

target_fun = skfmm.distance(target_binary, dx=grid_dx)

file_result = h5py.File('dubins_target_hybrid_fmm.h5', 'w')
file_result.create_dataset('data', data=target_fun)
file_result.close()

print(target_fun.shape)
