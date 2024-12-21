# GPE-TSSP Solver

A MATLAB implementation of the Time-Splitting Spectral (TSSP) method for solving the Gross-Pitaevskii Equation (GPE) in 1D, 2D, and 3D.

## Overview

This solver implements the Time-Splitting Spectral method for simulating Bose-Einstein condensates using the Gross-Pitaevskii equation. It supports:
- 1D, 2D, and 3D simulations
- Various trapping potentials
- Ground state calculation
- Time evolution
- Real-time visualization

## Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/gpe-tssp-solver.git
cd gpe-tssp-solver
```

2. Make sure you have MATLAB installed (tested with R2019b and later)

## Quick Start

1. Edit `config/default_config.json` to set your simulation parameters
2. Run `main.m` in MATLAB
3. Results will be displayed according to visualization settings

## Configuration

The simulation is configured through `config/default_config.json`. Key parameters include:

### Simulation Parameters
```json
{
    "simulation": {
        "dimension": 2,          // Dimension (1, 2, or 3)
        "dt": 0.001,            // Time step
        "T": 10,                // Total simulation time
        "Nt": 10000,            // Number of time steps
        "save_every": 100,      // Save interval
        "mode": "evolution"     // "evolution" or "ground_state"
    }
}
```

### Available Potentials

1. **Harmonic Trap**
```json
{
    "type": "harmonic",
    "parameters": {
        "gamma_y": 1.0,
        "gamma_z": 1.0
    }
}
```

2. **Optical Lattice**
```json
{
    "type": "optical_lattice",
    "parameters": {
        "V0": 5.0,              // Lattice depth
        "kL": 1.0,              // Lattice wave number
        "use_harmonic": true,   // Include harmonic trap
        "gamma_y": 1.5,         // Trap frequency ratio y
        "gamma_z": 2.0          // Trap frequency ratio z
    }
}
```

3. **Double Well**
```json
{
    "type": "double_well",
    "parameters": {
        "barrier_height": 1.0,
        "barrier_width": 0.5,
        "well_separation": 2.0
    }
}
```

### Initial Conditions

1. **Gaussian**
```json
{
    "type": "gaussian",
    "parameters": {
        "sigma_x": 1.0,
        "sigma_y": 1.0,
        "sigma_z": 1.0
    }
}
```

2. **Thomas-Fermi**
```json
{
    "type": "thomas_fermi",
    "parameters": {}
}
```

## Project Structure

```
gpe-tssp-project/
├── src/
│   ├── core/           # Core solver functions
│   ├── utils/          # Utility functions
│   ├── potentials/     # Potential functions
│   ├── ground_state/   # Ground state calculation
│   ├── visualizations/ # Plotting functions
├── config/             # Configuration files
└── main.m             # Main script
```

## Implementation Details

### TSSP Method

The solver uses the Time-Splitting Spectral method, which splits the GPE into:
1. Potential evolution (half-step)
2. Kinetic evolution (full-step)
3. Potential evolution (half-step)

```matlab
% One TSSP step
function psi = tssp_step(psi, V, kx, ky, kz, dt, params)
    % 1. Potential half-step
    psi = apply_potential_step(psi, V, dt/2, params);
    
    % 2. Kinetic full-step
    psi = apply_kinetic_step(psi, kx, ky, kz, dt, params);
    
    % 3. Potential half-step
    psi = apply_potential_step(psi, V, dt/2, params);
end
```

### Ground State Calculation

Two methods are available:
1. **Imaginary Time Evolution**: Replaces `dt` with `-i*dt`
2. **Direct Minimization**: Minimizes the energy functional

### Visualization

The package includes functions for:
- Density plots (1D, 2D, 3D)
- Condensate width evolution
- Real-time animation
- Energy evolution (optional)

## Examples

### 1. 2D Harmonic Trap
```json
{
    "simulation": {
        "dimension": 2,
        "mode": "evolution"
    },
    "potential": {
        "type": "harmonic",
        "parameters": {
            "gamma_y": 1.0
        }
    }
}
```

### 2. 1D Double Well Ground State
```json
{
    "simulation": {
        "dimension": 1,
        "mode": "ground_state"
    },
    "potential": {
        "type": "double_well",
        "parameters": {
            "barrier_height": 2.0,
            "well_separation": 3.0
        }
    }
}
```

## Numerical Considerations

1. **Grid Resolution**
   - Use `dx ≈ O(ε)` for defocusing case
   - Finer grid needed for focusing case or strong interactions

2. **Time Step**
   - Use `dt ≈ O(ε)` for defocusing case
   - Smaller time steps needed for focusing case

3. **Domain Size**
   - Choose `Lx`, `Ly`, `Lz` large enough to contain the condensate
   - Periodic boundary conditions are assumed

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## References

1. Bao, W., & Cai, Y. (2013). Mathematical theory and numerical methods for Bose-Einstein condensation. Kinetic & Related Models, 6(1), 1-135.
2. Bao, W., Du, Q., & Zhang, Y. (2006). Dynamics of rotating Bose-Einstein condensates and its efficient and accurate numerical computation. SIAM Journal on Applied Mathematics, 66(3), 758-786.

