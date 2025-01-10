
# Core Modules Documentation

The core modules implement the fundamental components of the Time-Splitting Spectral (TSSP) method for solving the Gross-Pitaevskii Equation.

## initialize_grid.m

Initializes the computational grid and wave numbers for the simulation.

### Inputs:
- `config`: Configuration structure containing grid parameters
  - `grid.Nx`, `grid.Ny`, `grid.Nz`: Number of grid points
  - `grid.Lx`, `grid.Ly`, `grid.Lz`: Domain sizes

### Outputs:
- `x`, `y`, `z`: Spatial coordinate arrays
- `kx`, `ky`, `kz`: Wave number arrays
- `dx`, `dy`, `dz`: Grid spacings
- `params`: Structure containing derived parameters

### Algorithm:
```markdown:algorithm.md
startLine: 7
endLine: 13
```

## initialize_wavefunction.m

Creates the initial wave function based on configuration settings.

### Supported Initial Conditions:
1. **Gaussian**:
   - Parameters: `sigma_x`, `sigma_y`, `sigma_z`
   - Used for ground state calculations
   
2. **Thomas-Fermi**:
   - Approximate solution for strong interactions
   - Valid when interaction energy dominates kinetic energy


## tssp_step.m

Implements a single step of the TSSP method.

### Algorithm:
1. **Potential Evolution (Half-Step)**:
   - Apply potential operator for dt/2
   - Includes both external potential and nonlinear interaction

2. **Kinetic Evolution (Full-Step)**:
   - Transform to Fourier space
   - Apply kinetic operator
   - Transform back to real space

3. **Potential Evolution (Half-Step)**:
   - Repeat first step


## tssp_solver.m

Main solver that evolves the system in time using the TSSP method.

### Features:
- Adaptive time-stepping (optional)
- Progress monitoring
- Result storage at specified intervals
- Error checking and validation

## apply_potential_step.m

Applies the potential evolution operator.

### Mathematical Form:
```
ψ = ψ * exp(-i * dt / (2 * ε) * (V + κ_d * |ψ|²))
```

### Key Considerations:
- Handles both external potential V and nonlinear interaction term
- Preserves normalization
- Efficient implementation for different dimensions

## apply_kinetic_step.m

Applies the kinetic evolution operator in Fourier space.

### Dimension-Specific Implementation:
1. **1D**: Uses `fft`/`ifft`
2. **2D**: Uses `fft2`/`ifft2`
3. **3D**: Uses `fftn`/`ifftn`

### Kinetic Operator Forms:
- 1D: `K = kx.^2`
- 2D: `K = kx.^2 + ky.'.^2`
- 3D: `K = kx.^2 + ky.^2 + kz.^2`

### Performance Considerations:
- Uses efficient array operations
- Minimizes memory allocation
- Handles boundary conditions correctly

## Error Handling

All core modules include:
- Input validation
- Dimension checking
- Numerical stability monitoring
- Informative error messages

## Dependencies

The core modules depend on:
- MATLAB's FFT functions
- Configuration loading utilities
- Wave function normalization utilities

## Usage Example

```matlab
% Load configuration
config = load_config('config/default_config.json');

% Initialize system
[x, y, z, kx, ky, kz, dx, dy, dz, params] = initialize_grid(config);
psi = initialize_wavefunction(x, y, z, dx, dy, dz, config);

% Create potential
V = potential_func(x, y, z, config.potential.parameters);

% Run simulation
[psi_final, results] = tssp_solver(psi, V, kx, ky, kz, dx, dy, dz, params, config, x, y, z);
```

## References

For detailed mathematical background and algorithm derivation:
```markdown:README.md
startLine: 223
endLine: 224
```
