

# vector-field-calculus

vector field visualizer, using love2d

- Red channel represents relative divergence of the vector field

- Blue channel represents relative curl of the vector field

- Green channel represents relative magnitude of each vector


### Example of functions:
```lua
   P(x,y) = ( (x*y + x*x), (x*y - y*y) )
```

![field](https://i.ibb.co/BCsHvyY/screenshot.png)

```lua
    P(x,y)  =  ( x*sin(y/2),  y*cos(x/2) )
```
![field_0](https://i.ibb.co/RSXztK6/screenshot-0.png)

# Making your own functions
To see your own functions in action, set the values for F and G at the top
of `main.lua` as seen below.
The operations used must be valid lua AND valid GLSL.
(math module has been exported to global)

# list of cool-ish functions:
where vector field P is defined as:
```
P(x,y) = ( F(x,y),  G(x,y) )
```
```lua
local F = '  sin(y) - cos(x*x)  ' 
local G = '  cos(x) - sin(y*y)  '

local F = '  cos(x*x*y) + y/5   '
local G = '  sin(y*y*x) + x/5   '

```
# REALLY cool functions:
```lua
local F   =  ' x*y + x*x '
local G   =  ' x*y - y*y '


local F   =  ' x*sin(y/2) '
local G   =  ' y*cos(x/2) '


```

# how this works:
Component functions are defined as a string in lua, and loaded into shader
and as a lua function.

The divergence and curl is calculated naturally in the GPU using
finite difference to simulate derivatives.

In the CPU, the divergence, curl, and magnitude of vectors
are calculated with ~200,000 (x,y) positions over the given vector field.
The variance for each property is then calculated from all the positions iterated,
as is the mean value.
Variance and mean values for each property for vectors over the field are
sent to the GPU, and from there, the properties are used to offset the 
values that were calculated previously, and are reduced to a range of 0 -> 1.

# TODO:
Lots to do.

Particle sym maybe?

Normalize vectors in vector field, so if you scale up to 100 it doesnt look weird