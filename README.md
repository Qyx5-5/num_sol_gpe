# GPE-TSSP Solver

A MATLAB implementation of the Time-Splitting Spectral (TSSP) method for solving the Gross-Pitaevskii Equation (GPE) in 1D, 2D, and 3D.

## Overview

This solver implements the Time-Splitting Spectral method for simulating Bose-Einstein condensates using the Gross-Pitaevskii equation. It supports:
- 1D, 2D, and 3D simulations
- Various trapping potentials (harmonic, optical lattice, double well)
- Ground state calculation using imaginary time evolution
- Time evolution simulations
- Real-time interactive visualization with dashboard
- Multiple pre-configured simulation scenarios

## Installation

1. Clone or download the repository
2. Make sure you have MATLAB installed (tested with R2019b and later)
3. Navigate to the project directory in MATLAB

## Quick Start

### Method 1: Run with Default Configuration
```matlab
% Simply run the main script - it's pre-configured with a 3D harmonic trap
main
```

### Method 2: Test Different Configurations  
```matlab
% Run quick test to verify all configurations work
quick_test
```

### Method 3: Choose a Specific Configuration
1. Edit `main.m` and change the `config_file` variable (line 27):
```matlab
config_file = 'config/harmonic_2d.json';  % Choose your desired config
```
2. Run:
```matlab
main
```

## Available Configurations

The project includes 9 ready-to-use simulation configurations in the `config/` directory:

| Configuration File | Description |
|-------------------|-------------|
| `default_config.json` | General 2D harmonic trap |
| `harmonic_1d.json` | 1D harmonic trap simulation |
| `harmonic_2d.json` | 2D anisotropic harmonic trap |
| `harmonic_3d.json` | 3D fully anisotropic trap |
| `optical_lattice_1d.json` | 1D optical lattice |
| `optical_lattice_2d.json` | 2D optical lattice |
| `double_well.json` | Double-well potential |
| `ground_state_calculation.json` | Ground state optimization |
| `strong_nonlinearity.json` | Thomas-Fermi regime |

## Project Structure

```
num_sol_gpe/
├── src/                          # Source code
│   ├── initialization.m          # Grid setup and initial conditions
│   ├── tssp_solver.m             # Core TSSP time evolution
│   ├── ground_state.m            # Ground state calculation
│   ├── potentials.m              # Potential energy functions
│   ├── visualizations.m          # Interactive dashboard and plots
│   └── utils.m                   # Utility functions and helpers
├── config/                       # Configuration files
│   ├── README.md                 # Configuration documentation
│   ├── default_config.json       # Default simulation
│   ├── harmonic_1d.json          # 1D harmonic trap
│   ├── harmonic_2d.json          # 2D harmonic trap
│   ├── harmonic_3d.json          # 3D harmonic trap
│   ├── optical_lattice_1d.json   # 1D optical lattice
│   ├── optical_lattice_2d.json   # 2D optical lattice
│   ├── double_well.json          # Double well potential
│   ├── ground_state_calculation.json  # Ground state finder
│   └── strong_nonlinearity.json  # Strong coupling regime
├── main.m                        # Main simulation script
├── quick_test.m                  # Quick validation test
├── test_configs.m                # Configuration testing
├── algorithm.md                  # Technical algorithm details
├── potential.md                  # Potential function documentation
└── README.md                     # This file
```

## Configuration Format

All simulations are configured through JSON files with the following structure:

```json
{
    "description": "Description of this configuration",
    "simulation": {
        "dimension": 2,              // 1, 2, or 3D
        "dt": 0.001,                // Time step  
        "T": 8.0,                   // Total simulation time
        "Nt": 8000,                 // Number of time steps
        "save_every": 100,          // Save data every N steps
        "mode": "evolution"         // "evolution" or "ground_state"
    },
    "grid": {
        "Nx": 128, "Ny": 128, "Nz": 1,    // Grid points
        "Lx": 12.0, "Ly": 12.0, "Lz": 1.0  // Domain size
    },
    "parameters": {
        "epsilon": 0.01,            // Dimensionless Planck constant
        "kappa": 1.0,               // Interaction strength
        "gamma_y": 1.0,             // Trap frequency ratio y/x
        "gamma_z": 1.0              // Trap frequency ratio z/x
    },
    "potential": {
        "type": "harmonic",         // Potential type
        "parameters": {}            // Type-specific parameters
    },
    "initial_condition": {
        "type": "gaussian",         // Initial wave function
        "parameters": {
            "sigma_x": 1.0,         // Gaussian width parameters
            "sigma_y": 1.0
        }
    },
    "visualization": {
        "animate": true,            // Enable interactive dashboard
        "calculate_observables": true,  // Track widths and energy
        "save_video": false         // Export animation to file
    }
}
```

## Supported Potentials

### 1. Harmonic Trap
```json
{
    "type": "harmonic",
    "parameters": {
        "gamma_y": 1.0,     // Optional: y-direction frequency ratio
        "gamma_z": 1.0      // Optional: z-direction frequency ratio  
    }
}
```

### 2. Optical Lattice
```json
{
    "type": "optical_lattice", 
    "parameters": {
        "V0": 5.0,              // Lattice depth
        "kL": 1.0,              // Lattice wave number
        "use_harmonic": true,   // Include harmonic confinement
        "gamma_y": 1.5,         // Harmonic trap frequency ratios
        "gamma_z": 2.0
    }
}
```

### 3. Double Well
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

## Initial Conditions

### Gaussian Wave Packet
```json
{
    "type": "gaussian",
    "parameters": {
        "sigma_x": 1.0,     // Width in x-direction
        "sigma_y": 1.0,     // Width in y-direction (2D/3D)
        "sigma_z": 1.0      // Width in z-direction (3D)
    }
}
```

### Thomas-Fermi Approximation
```json
{
    "type": "thomas_fermi",
    "parameters": {}
}
```

## Visualization Features

The solver includes an interactive visualization dashboard with:

### Interactive Controls
- ▶️ Play/Pause buttons for animation control
- 🔄 Time navigation slider 
- 📊 Real-time parameter display
- 🎬 Optional video export

### Multi-Panel Display
- **Main Plot**: Adapts automatically to 1D (line), 2D (surface), or 3D (isosurfaces)
- **Cross-Sections**: 1D slices through the density
- **Condensate Widths**: Evolution of spatial extent over time
- **Energy**: Total energy conservation monitoring

### Dimension-Specific Views
- **1D**: Line plot with width evolution
- **2D**: Surface plot with x/y cross-sections  
- **3D**: Multiple isosurface levels with slice views

Configure visualization through the config file:
```json
{
    "visualization": {
        "animate": true,                    // Enable interactive dashboard
        "calculate_observables": true,      // Track condensate properties
        "save_video": false,               // Export to video file
        "frame_rate": 25                   // Animation frame rate
    }
}
```

## Algorithm Details

### TSSP Method Implementation

The Time-Splitting Spectral method splits each time step into three operations:

1. **Potential Half-Step**: `ψ ← ψ × exp(-i dt V/(2ε))`
2. **Kinetic Full-Step**: `ψ ← IFFT[exp(-i ε dt k²/2) × FFT[ψ]]`  
3. **Potential Half-Step**: `ψ ← ψ × exp(-i dt V/(2ε))`

Where:
- `V = V_trap(x,y,z) + κ|ψ|²` (includes nonlinear interaction)
- `k²` is the kinetic energy operator in Fourier space
- `ε` is the dimensionless Planck constant
- `κ` is the interaction strength parameter

### Ground State Calculation

Ground states are found using imaginary time evolution:
- Replace `dt → -i dt` in the TSSP algorithm
- Evolve until convergence (typically `|δE| < 10⁻⁸`)
- Automatically normalizes the final state

## Performance Tips

### For Large Simulations
1. **Increase save interval**: Set `save_every = 200` or higher
2. **Optimize grid**: Use minimum resolution that captures physics
3. **Disable real-time updates**: Set `animate = false` during long runs

### For Stability
1. **Reduce time step**: Decrease `dt` if solution oscillates
2. **Check domain size**: Ensure `Lx, Ly, Lz` contain the wave function
3. **Monitor energy**: Should be approximately conserved

### Memory Optimization
1. **Frame-by-frame video saving**: Enabled automatically for long simulations
2. **Selective observables**: Set `calculate_observables = false` if not needed
3. **Efficient plot updates**: Dashboard optimizes refresh rates automatically

## Example Workflows

### 1. Ground State → Time Evolution
```matlab
% Step 1: Find ground state
main  % Run with ground_state_calculation.json

% Step 2: Use result as initial condition for evolution
% (Modify config to use calculated ground state)
main  % Run with evolution config
```

### 2. Parameter Sweep
```matlab
% Test different interaction strengths
for kappa = [0.5, 1.0, 2.0, 5.0]
    % Modify config.parameters.kappa
    % Run simulation
    % Save results
end
```

### 3. Multi-Dimensional Comparison
```matlab
% Compare 1D, 2D, 3D versions of same system
quick_test  % Verifies all configurations work
% Run harmonic_1d.json, harmonic_2d.json, harmonic_3d.json
```

## Troubleshooting

### Common Issues

1. **Simulation Unstable**
   - ✅ Reduce `dt` (try `dt = 0.0005`)
   - ✅ Increase grid resolution (`Nx = 256`)
   - ✅ Check domain size covers wave function

2. **Slow Performance**
   - ✅ Reduce grid points or domain size
   - ✅ Increase `save_every` to save less frequently
   - ✅ Disable animation: `"animate": false`

3. **Memory Issues**
   - ✅ Reduce total simulation time `T`
   - ✅ Increase `save_every` interval
   - ✅ Use smaller grid (`Nx = 64`)

4. **Visualization Problems**
   - ✅ Update MATLAB (requires R2019b+)
   - ✅ Close extra figures before running
   - ✅ Try `"animate": false` for static plots

### Validation

Run the test suite to verify installation:
```matlab
quick_test      % Tests all configurations
test_configs    % Detailed configuration validation  
```

## Technical Documentation

- **algorithm.md**: Detailed TSSP implementation and mathematical background
- **potential.md**: Complete documentation of all potential functions
- **config/README.md**: Configuration file format and parameter ranges

## References

1. Bao, W., & Cai, Y. (2013). Mathematical theory and numerical methods for Bose-Einstein condensation. *Kinetic & Related Models*, 6(1), 1-135.

2. Bao, W., Du, Q., & Zhang, Y. (2006). Dynamics of rotating Bose-Einstein condensates and its efficient and accurate numerical computation. *SIAM Journal on Applied Mathematics*, 66(3), 758-786.

3. Antoine, X., Bao, W., & Besse, C. (2013). Computational methods for the dynamics of the nonlinear Schrödinger/Gross–Pitaevskii equations. *Computer Physics Communications*, 184(12), 2621-2633.

## License

This project is available under the MIT License - see the LICENSE file for details.

