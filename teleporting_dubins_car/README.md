# Example: Teleporting Dubins Car

## Main scripts

### BRT Computation

1. To set up a target function, run [setup_target_binary.m](reachability/setup_target_binary.m).
Make sure you saved the target function data to `.mat` file.

2. You have to run FMM (in python) to convert this binary target function to a signed distance function. Run [setup_target_fmm.py](reachability/setup_target_fmm.py).
The result will be saved in `.h5` format.

3. Finally, for the BRT computation, run [calc_brt_teleporting_dubins_car.m](reachability/calc_brt_teleporting_dubins_car.m).

### Precompted Data
You can download the precomputed value functions [here](https://drive.google.com/drive/folders/13dQVn9KpzpXO5skMapiiGxC1FSDTTlhr?usp=sharing).
These BRTs are computed for T=6.3s, under various values of alphas. (0.01 * the value after `alpha_` in the file name indicates the value of alpha in use.)

### Evaluations

For visualization of the BRT, run [compare_brts_between_parametrized_reset_map.m](visualize/compare_brts_between_parametrized_reset_map.m).

For evaulation of the optimal trajectories, run [simulate_optimal_traj.m](demos/simulate_optimal_traj.m).

## Quick navigation.

- `@ModifiedDubinsCar` is the helperOC dynsys class that implements the dubins car in the transformed coordinate system. 

- `conversion` contains functions that transform data between original coordinates and the transformed coordinates.

- `demos` contains scripts and functions that are used to evaluate the controllers.

- `reachability` contains scripts and functions that are used to compute the value functions.

- `visualize` contains scripts and functions that visualize the value functions and the trajectories.
