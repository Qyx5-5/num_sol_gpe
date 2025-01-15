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

## Step-by-Step Guide

### 1. Basic Setup
1. Install MATLAB (R2019b or later)
2. Clone the repository:
```bash
git clone https://github.com/yourusername/gpe-tssp-solver.git
cd gpe-tssp-solver
```

### 2. Configure Your Simulation

1. Navigate to `config/default_config.json`
2. Set basic parameters:
```json
{
    "simulation": {
        "dimension": 2,          // Choose 1, 2, or 3
        "mode": "evolution",     // or "ground_state"
        "dt": 0.001,            // Time step
        "T": 10                 // Total time
    }
}
```

3. Choose your potential (e.g., harmonic trap):
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

4. Set initial condition (e.g., Gaussian):
```json
{
    "initial_condition": {
        "type": "gaussian",
        "parameters": {
            "sigma_x": 1.0,
            "sigma_y": 1.0
        }
    }
}
```

### 3. Run Simulation

1. Open MATLAB
2. Navigate to project directory
3. Run the main script:
```matlab
>> main
```

### 4. Understanding Results

The simulation produces several visualizations:

1. **Density Plots**
   - 1D: Line plot of |ψ|²
   - 2D: Surface plot with cross-sections
   - 3D: Isosurfaces and slices

2. **Width Evolution**
   - Shows condensate size over time
   - Different lines for each dimension

3. **Animation** (if enabled)
   - Real-time density evolution
   - Can be saved as video

### 5. Common Configurations

1. **Ground State Calculation**:
```json
{
    "simulation": {
        "mode": "ground_state",
        "dimension": 1
    },
    "ground_state": {
        "method": "imaginary_time",
        "tolerance": 1e-8
    }
}
```

2. **2D Optical Lattice**:
```json
{
    "simulation": {
        "dimension": 2,
        "mode": "evolution"
    },
    "potential": {
        "type": "optical_lattice",
        "parameters": {
            "V0": 5.0,
            "kL": 1.0
        }
    }
}
```

### 6. Visualization Options

Control output through visualization settings:
```json
{
    "visualization": {
        "plot_density": true,
        "plot_widths": true,
        "animate": true,
        "save_video": false,
        "frame_rate": 20
    }
}
```

### 7. Tips for Good Results

1. **Grid Resolution**
   - Start with Nx = Ny = 128
   - Increase if solution shows artifacts

2. **Time Step**
   - Start with dt = 0.001
   - Decrease if simulation becomes unstable

3. **Domain Size**
   - Choose Lx, Ly ≈ 5-10 times the condensate size
   - Adjust based on potential type

### 8. Troubleshooting

1. **Unstable Evolution**
   - Decrease time step
   - Increase grid points
   - Check normalization

2. **Slow Performance**
   - Reduce grid points
   - Increase save_every
   - Disable animation

3. **Memory Issues**
   - Reduce simulation time
   - Save fewer snapshots
   - Use 2D instead of 3D

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

