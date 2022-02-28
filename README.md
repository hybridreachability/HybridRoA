![Main Thumbnail](/multimedia/main_banner.png)

# HybridRoA

- Source code for J. Choi, A. Agrawal, K. Sreenath, C. J. Tomlin, and S. Bansal, ["Computation of Regions of Attraction for Hybrid Limit Cycles Using Reachability: An Application to Walking Robots"](https://arxiv.org/pdf/2201.08538.pdf) **[[Project Hompage](https://hybridreachability.github.io/website-hybrid-roa/)]**

- Contributors: [Jason Choi](https://jay-choi.me/), [Ayush Agrawal](https://www.linkedin.com/in/ayushagrawal1/), [Somil Bansal](https://smlbansal.github.io/)

## Dependencies

- **[Level Set Toolbox](https://www.cs.ubc.ca/~mitchell/ToolboxLS/)**: Level set methods are a class of numerical algorithms for simulation of dynamic implicit surfaces and approximation of solutions to the Hamilton-Jacobi (HJ) partial differential equation (PDE). This is the main library we use to solve the HJ reachability problems.

- **[HelperOC](https://github.com/HJReachability/helperOC)**: This is a library that is used to interface with the Level Set Toolbox. Implementation of the value remapping in the paper is based on [`HJIPDE_solve.m`](https://github.com/HJReachability/helperOC/blob/master/valFuncs/HJIPDE_solve.m) in this library.

- **[mufun](https://github.com/ChoiJangho/mufun)**: This library supports python-like input-output argument syntax in matlab and cool visualizations. 

The following python packages are required to set up the target functions for the teleporting dubins car example.

- scipy.io: to load `.mat` files.

- [scikit-fmm](https://pythonhosted.org/scikit-fmm/): python extension module which implements the fast marching method.

- [HDF5](https://docs.h5py.org/en/stable/): python library to save data to `.h5` format.

## Quick navigation

- The main reachability algorithm (Algorithm 1 in the paper) incorporating the value remapping is implemented in [`HJIPDE_solve_with_reset_map.m`](/HJIPDE_solve_with_reset_map.m) 

- Computing the value functions for the BRTs take some time. If you just want to play around with the optimal controllers, you can download the **precomputed value functions [here](https://drive.google.com/drive/folders/1xlu5wDWFpEuowMRS4W2vOJWn6iHFQN0a?usp=sharing)**.

- More explanations are provided in the directories for each example:
  - **[Rimless Wheel](/rimless_wheel)**
  
  ![Rimless Wheel](/multimedia/demo-rimless-wheel.png)
   Description: Regions of Attraction (RoA) for the rimless wheel limit cycle (black). (Left and center reproduced from [Manchester et al., Regions of attraction for hybrid limit cycles of walking robots](https://arxiv.org/pdf/1010.2247.pdf).) (Left) Configuration of the rimless wheel system. (Center) The true RoA is shown in light pink. RoA obtained using SOS programming is shown in purple. (Right) RoA computed using our approach. The proposed approach is able to recover the entire RoA.
  - **[Teleporting Dubins Car](/teleporting_dubins_car)**
  
  ![Teleporting Dubins Car](/multimedia/demo-teleporting-dubins-car.gif)
  
  - **[Compass Gait Walker](/compass_gait_walker)**
  
  ![Compass Gait Walker](/multimedia/demo-compass-gait.gif)
