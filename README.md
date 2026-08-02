# Catenary Lowest Point Solver

This Luau script provides a mathematically robust function to find the lowest point in 3D space of a hanging rope, cable, or chain suspended between two arbitrary anchor points.

Instead of relying on physics simulations or segmented approximations, this function uses the catenary equation (the geometric shape formed by an idealized hanging chain under its own weight) to calculate the exact coordinate of the lowest point.

## Usage

Drop the function into your script and call it by passing the two endpoints (Vector3) and the total length (number) of the rope.

```lua
local p1 = Vector3.new(0, 10, 0)
local p2 = Vector3.new(10, 15, 0)
local ropeLength = 20

local lowestPoint = getLowestRopePoint(p1, p2, ropeLength)
print("The lowest point is:", lowestPoint)
```

## How It Works

The script breaks down the 3D spatial problem into a 2D mathematical curve, solves for the catenary parameters, and maps the result back into 3D space.

1. Vector Projection & Edge Cases

Before tackling the complex math, the script flattens the problem. It isolates the vertical difference ($h$) and the horizontal distance ($d$) between the two anchors. It then checks for two physical edge cases:

Taut or Impossible Length: If the given length is less than or equal to the straight-line distance between the points, the rope cannot sag. The lowest point is simply the lower of the two endpoints.

Vertically Aligned Anchors: If horizontal distance ($d \approx 0$), the rope hangs straight down. The lowest point is the lowest anchor's Y-coordinate, minus half of the "excess" rope length.

2. The Catenary Equation & Root Finding

If the rope hangs freely, it forms a catenary curve. To find the parameters of this curve, we must solve a transcendental equation.

The script defines a constant $K$ based on the rope's length ($L$), horizontal distance ($d$), and vertical height difference ($h$):


$$K = \frac{\sqrt{L^2 - h^2}}{d}$$

The core challenge of the catenary is finding an unknown parameter $u$ such that:


$$\frac{\sinh(u)}{u} = K$$

Because this cannot be solved algebraically, the script uses the Newton-Raphson method to approximate the root numerically:

Initial Guess: It uses a Taylor series expansion ($\frac{\sinh(u)}{u} \approx 1 + \frac{u^2}{6}$) to seed a highly accurate initial guess: $u = \sqrt{6(K - 1)}$.

Iteration: It loops 10 times to refine $u$ using the formula $u_{n+1} = u_n - \frac{f(u_n)}{f'(u_n)}$, rapidly converging on the exact value.

3. Locating the Vertex

Once $u$ is found, the scaling parameter $a$ of the catenary is calculated as:


$$a = \frac{d}{2u}$$

Next, the script calculates $r_0$, which is the horizontal distance from the first point (p1) to the lowest point of the curve (the vertex):


$$r_0 = \frac{d}{2} - \frac{a}{2} \ln\left(\frac{L + h}{L - h}\right)$$

Note: If $r_0$ falls outside the range of $[0, d]$, it means the mathematical vertex of the curve lies outside the suspended segment (e.g., a highly asymmetric suspension where the curve strictly goes up). In this case, the lowest point is just the lowest anchor point.

4. 3D Re-Mapping

With the horizontal offset ($r_0$) known, the script calculates the exact Y-coordinate of the lowest point:


$$Y_{low} = Y_{p1} - a \left(\cosh\left(\frac{r_0}{a}\right) - 1\right)$$

Finally, it takes the normalized horizontal direction vector between the two original anchors, scales it by $r_0$, and combines it with $Y_{low}$ to return the final 3D Vector3 position.
