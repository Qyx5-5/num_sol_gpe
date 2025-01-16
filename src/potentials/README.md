# Potential Functions Documentation

This directory contains various trapping potential implementations for the GPE-TSSP solver. Each potential can be used in 1D, 2D, or 3D simulations.

## Available Potentials

### 1. Harmonic Trap (`harmonic.m`)
Standard harmonic oscillator potential: V = ½(x² + γy²y² + γz²z²)

```matlab
params = struct('gamma_y', 1.0, 'gamma_z', 1.0);
V = harmonic(x, y, z, params);
```

### 2. Anharmonic Trap (`anharmonic.m`)
Harmonic + quartic terms: V = ½(x² + γy²y²) + λ(x⁴ + y⁴)

```matlab
params = struct('lambda', 0.1, 'gamma_y', 1.0, 'gamma_z', 1.0);
V = anharmonic(x, y, z, params);
```

### 3. Optical Lattice (`optical_lattice.m`)
Periodic potential with optional harmonic trap:
V = V₀[sin²(kLx) + sin²(kLy) + sin²(kLz)]

```matlab
params = struct('V0', 5.0, 'kL', 1.0, 'harmonic_trap', true);
V = optical_lattice(x, y, z, params);
```

### 4. Double Well (`double_well.m`)
Two implementation methods:
1. Gaussian barrier: V = ½x² + V₀exp(-x²/σ²)
2. Quartic potential: V = Ax⁴ - Bx²

```matlab
% Gaussian barrier method
params = struct('method', 'gaussian_barrier', 'V0', 10, 'sigma', 1.0);
% OR Quartic method
params = struct('method', 'quartic', 'A', 1.0, 'B', 2.0);
V = double_well(x, y, z, params);
```

### 5. Box Potential (`box.m`)
Hard or smooth-walled box:

```matlab
params = struct('V0', 100, 'Lx', 10, 'Ly', 10, 'smoothing', 0.1);
V = box(x, y, z, params);
```

### 6. Disordered Potential (`disordered.m`)
Random potential with controlled correlation length:

```matlab
params = struct('V0', 1.0, 'correlation_length', 0.5, ...
                'seed', 42, 'include_harmonic', true);
V = disordered(x, y, z, params);
```

### 7. Rotating Trap (`rotating_trap.m`)
2D rotating potential with stirring beam:

```matlab
params = struct('omega_x', 1.0, 'omega_y', 1.0, ...
                'Ws', 1.0, 'Vs', 0.5, 'r0', 2.0, ...
                'omega_s', 0.5, 't', t);
V = rotating_trap(x, y, [], params);
```

## Common Features

All potential functions:
1. Support 1D, 2D, and 3D configurations
2. Handle empty y/z inputs appropriately
3. Include parameter validation
4. Support optional harmonic confinement

## Dimension Handling

```matlab
% 1D case
V = potential(x, [], [], params);

% 2D case
V = potential(x, y, [], params);

% 3D case
V = potential(x, y, z, params);
```

## Configuration Examples

### 1. Basic Harmonic Trap
```json
{
    "potential": {
        "type": "harmonic",
        "parameters": {
            "gamma_y": 1.0,
            "gamma_z": 1.0
        }
    }
}
```

### 2. Complex Optical Lattice
```json
{
    "potential": {
        "type": "optical_lattice",
        "parameters": {
            "V0": 5.0,
            "kL": 1.0,
            "harmonic_trap": true,
            "gamma_y": 1.5,
            "gamma_z": 2.0
        }
    }
}
```
## Implementation Notes

### 1. Coordinate Systems
- Uses meshgrid for 2D/3D potentials
- Assumes uniform grid spacing
- Supports arbitrary domain sizes

### 2. Numerical Considerations
- Smooth potentials preferred for stability
- Box potential offers smoothing option
- Disordered potential includes correlation length control

### 3. Performance Optimization
- Vectorized operations
- Minimal memory allocation
- Efficient grid generation

## Usage Guidelines

1. **Choosing a Potential**:
   - Harmonic: Standard starting point
   - Optical Lattice: Periodic systems
   - Double Well: Tunneling studies
   - Box: Confined systems
   - Disordered: Localization studies
   - Rotating: Vortex generation

2. **Parameter Selection**:
   - V₀: Typically 1-10 in natural units
   - γy, γz: Usually 0.5-2.0
   - Smoothing: ~0.1 grid spacing

3. **Common Issues**:
   - Ensure potential matches boundary conditions
   - Check normalization with strong potentials
   - Monitor energy conservation

