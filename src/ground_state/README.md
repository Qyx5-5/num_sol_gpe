# Ground State Calculation Methods

This directory contains implementations of two methods for calculating the ground state of a Bose-Einstein condensate (BEC):

1. Imaginary Time Evolution
2. Direct Energy Minimization

## Why Ground States Matter

The ground state is crucial for BEC simulations because:
- It represents the lowest energy state of the system
- It's often used as an initial condition for dynamic simulations
- It helps validate the numerical implementation
- It provides insights into the condensate's static properties

## Methods Overview

### 1. Imaginary Time Evolution (`imaginary_time_evolution.m`)

This method evolves the wave function in imaginary time (t → -iτ) to find the ground state.

#### Advantages:
- Robust and reliable
- Simple implementation
- Works well for most potentials

#### Implementation Details:
```matlab
% Core evolution step
psi = apply_potential_step(psi, V, -1i*dt, params);
psi = apply_kinetic_step(psi, kx, ky, kz, -1i*dt, params, dimension);
psi = apply_potential_step(psi, V, -1i*dt, params);
```

### 2. Direct Minimization (`direct_minimization.m`)

This method directly minimizes the energy functional using gradient descent.

#### Advantages:
- Can be faster for some systems
- Provides explicit control over convergence
- Useful for more complex energy landscapes

#### Implementation Details:
```matlab
% Energy gradient calculation
grad = calculate_energy_gradient(psi, V, kx, ky, kz, params);
psi = psi - alpha * grad;  % Gradient descent step
```

## Usage Example

```matlab
% Load configuration
config = load_config('config/default_config.json');

% Choose ground state method
if strcmp(config.ground_state.method, 'imaginary_time')
    [psi, results] = imaginary_time_evolution(psi, V, kx, ky, kz, dx, dy, dz, params, config);
else
    [psi, results] = direct_minimization(psi, V, kx, ky, kz, dx, dy, dz, params, config);
end
```

## Configuration Parameters

In `config/default_config.json`:
```json
{
    "ground_state": {
        "method": "imaginary_time",  // or "direct_minimization"
        "dt_imag": 0.01,            // imaginary time step
        "tolerance": 1e-8           // convergence criterion
    }
}
```

## Convergence Monitoring

Both methods:
- Track energy convergence
- Provide progress updates
- Warn if maximum iterations reached
- Store convergence history

## When to Use Each Method

1. **Use Imaginary Time Evolution when:**
   - Working with standard harmonic traps
   - Need reliable convergence
   - Starting with Gaussian initial states

2. **Use Direct Minimization when:**
   - Working with complex potentials
   - Need faster convergence
   - Have a good initial guess

