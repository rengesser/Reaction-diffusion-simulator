# Reaction-diffusion-simulator

Small toolbox for simulating reaction diffusion equations of the type 

![RDE](/images/reactiondiffusionequations.png) 

with the diffusion matrix 

![DM](/images/diffusionmatrix.png) 

The space is discretized by finite differences and translated to a big ODE system which is solved using MATLABs `ode15s` solver.

## Features
* Simulation of reaction diffusion equations in one or two spatial dimensions. 
* Zeroflux and periodic boundary conditions. 
* Easy model setup.
* Spatially dependend parameter possible. 
* Import of D2D models (https://github.com/Data2Dynamics)
* 

## Setup models

The model is specified in a `.def` file in the subfolder `/Models` of the current MATLAB working directory. The model file is structured like:

```
STATES
...

EQUATIONS
...

PARAMETERFIELDS
...
```

The section `STATES` containes a list of the dynamical states together with a boolean variable if the state is diffusive. The section `EQUATIONS` contains a list with the ODE defining the reaction part `f(u(x,t))` of the reaction diffusion equations. The section `PARAMETERFIELDS` specifies all dynamical parameters which are spatially depend. See the example `Diffusion_from_Source` for some use cases. 


