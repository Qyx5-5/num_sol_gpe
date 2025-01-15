# Utility Functions Documentation

This directory contains essential utility functions for the GPE-TSSP solver. These functions handle core calculations, normalization, and configuration management.

## Core Utilities

### 1. calculate_condensate_widths.m

Calculates the RMS widths of the condensate in each dimension.

#### Mathematical Background:
For dimension d, the width σ is calculated as:
```math
x_{mean} = ∫ x |ψ|² dx / ∫ |ψ|² dx
σ = √(∫ (x - x_{mean})² |ψ|² dx / ∫ |ψ|² dx)
```

#### Implementation Details:
```matlab
% 1D case
x_mean = sum(x .* rho) * dx / (sum(rho) * dx);
sigma_x = sqrt(sum((x - x_mean).^2 .* rho) * dx / (sum(rho) * dx));

% 2D/3D cases use meshgrid for coordinate arrays
```

### 2. calculate_energy.m

Computes the total energy of the system, including kinetic, potential, and interaction terms.

#### Energy Components:
1. **Kinetic Energy**: `E_kin = (ε/2) ∫ |∇ψ|² dx`
2. **Potential Energy**: `E_pot = ∫ V|ψ|² dx`
3. **Interaction Energy**: `E_int = (κ_d/2) ∫ |ψ|⁴ dx`

#### Implementation Notes:
- Uses FFT for kinetic energy calculation
- Handles 1D, 2D, and 3D cases efficiently
- Returns real part of total energy

### 3. calculate_kappa_d.m

Computes the dimension-dependent interaction parameter κ_d.

#### Formulas:
```matlab
case 1: kappa_d = kappa
case 2: kappa_d = kappa * sqrt(gamma_y) / (2 * pi * epsilon)
case 3: kappa_d = kappa * sqrt(gamma_y * gamma_z) / (4 * pi * epsilon^2)
```

### 4. normalize_wavefunction.m

Ensures the wave function satisfies the normalization condition: ∫|ψ|² dx = 1

#### Key Features:
- Dimension-aware normalization
- Preserves wave function phase
- Handles different grid spacings

## Configuration Management

### load_config.m

Manages simulation configuration with robust default values.

#### Default Parameters:
```json
{
    "simulation": {
        "dimension": 2,
        "dt": 0.001,
        "T": 10
    },
    "grid": {
        "Nx": 128,
        "Ny": 128,
        "Nz": 1
    },
    "parameters": {
        "epsilon": 0.01,
        "kappa": 1
    }
}
```

#### Features:
- JSON configuration file support
- Comprehensive default values
- Parameter validation
- Backwards compatibility

## Usage Examples

### 1. Energy Calculation
```matlab
% Calculate total energy
E = calculate_energy(psi, V, kx, ky, kz, dx, dy, dz, params, config);
fprintf('Total Energy: %.6f\n', E);
```

### 2. Width Calculation
```matlab
% Calculate and plot condensate widths
[sigma_x, sigma_y, sigma_z] = calculate_condensate_widths(psi, x, y, z, dx, dy, dz, dimension);
plot_condensate_widths(results, config);
```

### 3. Configuration Loading
```matlab
% Load and validate configuration
config = load_config('config/default_config.json');
```

## Error Handling

All utility functions include:
- Input validation
- Dimension checking
- Informative error messages
- NaN/Inf checking

## Performance Considerations

1. **Memory Efficiency**:
   - Avoid unnecessary array copies
   - Use in-place operations where possible
   - Handle large arrays efficiently

2. **Computational Optimization**:
   - Vectorized operations
   - Efficient FFT usage
   - Minimal loop usage

## Dependencies

- MATLAB's core functions
- Signal Processing Toolbox (for FFT)
- JSON parser (for configuration)
