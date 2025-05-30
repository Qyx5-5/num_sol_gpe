# GPE-TSSP Configuration Files

This directory contains production-ready configuration files for various BEC simulation scenarios. Each configuration is optimized for specific physical phenomena and computational requirements.

## Available Configurations

### 1. **default_config.json**
- **Purpose**: General-purpose starting configuration
- **Dimension**: 2D
- **Potential**: Harmonic trap
- **Parameters**: κ=1.0, γy=1.0, ε=0.01
- **Grid**: 128×128, domain 12×12
- **Use Case**: First-time users, general exploration
- **Features**: Balanced parameters for stable simulations

### 2. **harmonic_1d.json**
- **Purpose**: One-dimensional harmonic trap simulations
- **Dimension**: 1D
- **Potential**: Harmonic trap (`V = 0.5 * x²`)
- **Parameters**: κ=1.0, ε=0.01
- **Grid**: 256 points, domain L=15
- **Use Case**: Basic 1D BEC dynamics, breathing modes
- **Features**: High resolution, extended domain for detailed 1D dynamics

### 3. **harmonic_2d.json**
- **Purpose**: Two-dimensional anisotropic harmonic trap
- **Dimension**: 2D
- **Potential**: Anisotropic harmonic (γy=1.5)
- **Parameters**: κ=1.0, γy=1.5, ε=0.01
- **Grid**: 128×128, domain 12×12
- **Use Case**: Cigar-shaped condensates, aspect ratio studies
- **Features**: Anisotropic trapping ratios for elongated BECs

### 4. **harmonic_3d.json**
- **Purpose**: Three-dimensional fully anisotropic trap
- **Dimension**: 3D
- **Potential**: 3D harmonic (γy=1.2, γz=0.8)
- **Parameters**: κ=2.0, γy=1.2, γz=0.8, ε=0.01
- **Grid**: 64×64×64, domain 10×10×10
- **Use Case**: Realistic 3D BEC simulations
- **Features**: Triaxial ellipsoidal condensates, moderate resolution for efficiency

### 5. **optical_lattice_1d.json**
- **Purpose**: One-dimensional optical lattice potential
- **Dimension**: 1D
- **Potential**: Periodic lattice + harmonic confinement
- **Parameters**: V₀=8.0, kL=1.0, κ=1.0, harmonic overlay
- **Grid**: 256 points, domain L=20
- **Use Case**: Superfluid-Mott transitions, Bloch oscillations
- **Features**: Deep lattice potential, fine time stepping (dt=0.0005)

### 6. **optical_lattice_2d.json**
- **Purpose**: Two-dimensional optical lattice
- **Dimension**: 2D
- **Potential**: 2D periodic lattice + harmonic confinement
- **Parameters**: V₀=5.0, kL=1.0, κ=1.0, γy=γz=1.5
- **Grid**: 128×128, domain 15×15
- **Use Case**: 2D lattice physics, vortex pinning
- **Features**: Moderate lattice depth, harmonic background trap

### 7. **double_well.json**
- **Purpose**: Double-well potential studies
- **Dimension**: 1D
- **Potential**: Gaussian barrier creating double well
- **Parameters**: Barrier height=1.0, width=0.5, separation=2.0, κ=1.0
- **Grid**: 256 points, domain L=20
- **Use Case**: Josephson oscillations, tunneling dynamics
- **Features**: Symmetric double well with tunable barrier properties

### 8. **ground_state_calculation.json**
- **Purpose**: Optimized ground state finding
- **Dimension**: 2D
- **Mode**: Ground state calculation (imaginary time evolution)
- **Parameters**: κ=2.0, tolerance=1e-8, max_iter=10000
- **Grid**: 128×128, domain 12×12
- **Use Case**: Finding equilibrium states for initial conditions
- **Features**: Imaginary time evolution with high convergence tolerance

### 9. **strong_nonlinearity.json**
- **Purpose**: Thomas-Fermi regime simulations
- **Dimension**: 2D
- **Potential**: Harmonic with strong interactions
- **Parameters**: κ=10.0 (strong interactions), ε=0.01
- **Grid**: 128×128, domain 10×10
- **Use Case**: Strongly interacting BECs, Thomas-Fermi profiles
- **Features**: High interaction strength, Thomas-Fermi initial condition

## Parameter Reference

### Core Parameters

| Parameter | Symbol | Description | Typical Range |
|-----------|--------|-------------|---------------|
| `epsilon` | ε | Dimensionless Planck constant | 0.001 - 0.1 |
| `kappa` | κ | Interaction strength | 0.1 - 20.0 |
| `gamma_y` | γy | Trap frequency ratio (y/x) | 0.5 - 3.0 |
| `gamma_z` | γz | Trap frequency ratio (z/x) | 0.5 - 3.0 |
| `dt` | Δt | Time step | 0.0001 - 0.002 |

### Grid Parameters

| Parameter | Description | 1D | 2D | 3D |
|-----------|-------------|----|----|-----|
| `Nx`, `Ny`, `Nz` | Grid points | 128-512 | 64-256 | 32-128 |
| `Lx`, `Ly`, `Lz` | Domain size | 10-25 | 8-20 | 6-15 |

### Time Step Guidelines

| Regime | dt | Use Case |
|--------|-----|----------|
| **Standard** | 0.001 | Most simulations |
| **Fine** | 0.0005 | Optical lattices, fast dynamics |
| **Ultra-fine** | 0.0002 | Strong nonlinearity, instabilities |

### Grid Resolution Guidelines

| Dimension | Resolution | Features Resolved |
|-----------|------------|-------------------|
| **1D** | 256-512 pts | Fine structure, oscillations |
| **2D** | 128²-256² | Vortices, interference patterns |
| **3D** | 64³-128³ | Basic 3D structure |

## Configuration File Format

Each configuration file follows this JSON structure:

```json
{
    "description": "Human-readable description",
    "simulation": {
        "dimension": 1/2/3,
        "dt": 0.001,
        "T": 8.0,
        "Nt": 8000,
        "save_every": 100,
        "mode": "evolution" or "ground_state"
    },
    "grid": {
        "Nx": 128, "Ny": 128, "Nz": 1,
        "Lx": 12.0, "Ly": 12.0, "Lz": 1.0
    },
    "parameters": {
        "epsilon": 0.01,
        "kappa": 1.0,
        "gamma_y": 1.0,
        "gamma_z": 1.0
    },
    "potential": {
        "type": "harmonic/optical_lattice/double_well",
        "parameters": { /* type-specific parameters */ }
    },
    "initial_condition": {
        "type": "gaussian/thomas_fermi",
        "parameters": { /* initial condition parameters */ }
    },
    "ground_state": {
        "method": "imaginary_time",
        "dt_imag": 0.01,
        "tolerance": 1e-8,
        "max_iter": 10000
    },
    "visualization": {
        "animate": true/false,
        "calculate_observables": true/false,
        "save_video": false,
        "frame_rate": 25
    }
}
```

## Usage Examples

### Load and Run Configuration
```matlab
% Method 1: Edit main.m
config_file = 'config/harmonic_2d.json';  % Change this line in main.m
main

% Method 2: Direct loading (for custom scripts)
addpath('src');
helpers = utils();
config = helpers.load_config('config/harmonic_2d.json');
```

### Modify Parameters
```matlab
% Load base configuration
config = helpers.load_config('config/default_config.json');

% Modify interaction strength
config.parameters.kappa = 5.0;

% Change time evolution parameters
config.simulation.T = 15.0;
config.simulation.dt = 0.0005;

% Enable video saving
config.visualization.save_video = true;
```

### Ground State → Evolution Workflow
```matlab
% Step 1: Calculate ground state
config = helpers.load_config('config/ground_state_calculation.json');
[x,y,z,kx,ky,kz,dx,dy,dz,params,psi0] = initialization(config, helpers);
V = potentials(x,y,z,config);
[psi_gs, results_gs] = ground_state(psi0, V, kx,ky,kz, dx,dy,dz, params, config, helpers);

% Step 2: Use ground state for time evolution
config.simulation.mode = 'evolution';
config.simulation.T = 10.0;
% Use psi_gs as initial condition for evolution...
```

## Physical Regimes

### Weak Interactions (κ ≤ 1.0)
- **Configs**: `harmonic_1d.json`, `harmonic_2d.json`, `default_config.json`
- **Physics**: Gaussian-like profiles, linear Schrödinger limit
- **Features**: Large time steps allowed, fast computation

### Moderate Interactions (1.0 < κ ≤ 5.0)
- **Configs**: `optical_lattice_*.json`, `double_well.json`
- **Physics**: Nonlinear effects important, realistic experimental conditions
- **Features**: Standard resolution and time stepping

### Strong Interactions (κ > 5.0)
- **Configs**: `strong_nonlinearity.json`
- **Physics**: Thomas-Fermi profiles, potential for collapse
- **Features**: Requires fine time stepping and careful monitoring

## Potential Types

### Harmonic Trap
```json
{
    "type": "harmonic",
    "parameters": {
        "gamma_y": 1.5,  // Optional anisotropy
        "gamma_z": 2.0   // Optional for 3D
    }
}
```
- **Formula**: V = ½(x² + γy²y² + γz²z²)
- **Use**: Standard BEC trapping

### Optical Lattice
```json
{
    "type": "optical_lattice",
    "parameters": {
        "V0": 5.0,           // Lattice depth
        "kL": 1.0,           // Lattice wave number  
        "use_harmonic": true, // Include harmonic envelope
        "gamma_y": 1.5,      // Harmonic anisotropy
        "gamma_z": 2.0
    }
}
```
- **Formula**: V = V₀ cos²(kL x) + harmonic background
- **Use**: Periodic potentials, lattice physics

### Double Well
```json
{
    "type": "double_well", 
    "parameters": {
        "barrier_height": 1.0,    // Central barrier height
        "barrier_width": 0.5,     // Barrier width
        "well_separation": 2.0    // Distance between wells
    }
}
```
- **Formula**: Gaussian barrier + harmonic wells
- **Use**: Tunneling dynamics, Josephson oscillations

## Initial Conditions

### Gaussian
```json
{
    "type": "gaussian",
    "parameters": {
        "sigma_x": 1.0,  // Width in each direction
        "sigma_y": 1.0,
        "sigma_z": 1.0
    }
}
```

### Thomas-Fermi
```json
{
    "type": "thomas_fermi", 
    "parameters": {}
}
```
- **Use**: Strong interaction regime initial state
- **Note**: Automatically calculated based on potential and κ

## Customization Guidelines

### Performance Optimization
1. **Faster Computation**: 
   - Increase `save_every` (save less frequently)
   - Reduce grid size (`Nx`, `Ny`, `Nz`)
   - Disable animation: `"animate": false`

2. **Higher Accuracy**:
   - Decrease `dt` time step
   - Increase grid resolution
   - Extend domain size if needed

3. **Memory Management**:
   - Use 2D instead of 3D when possible
   - Reduce total simulation time `T`
   - Set `calculate_observables: false` if not needed

### Stability Tips
- **For new potentials**: Start with `dt = 0.0005`
- **For strong interactions**: Use `dt ≤ 0.0002`
- **For high resolution**: Ensure domain contains wave function
- **For ground states**: Increase `max_iter` if convergence fails

## Troubleshooting

| Problem | Solution |
|---------|----------|
| **Instability/Blowup** | Reduce `dt`, increase grid resolution |
| **Slow convergence** | Increase `max_iter`, improve initial guess |
| **Memory errors** | Reduce grid size, shorten simulation |
| **Boundary artifacts** | Increase domain size (`Lx`, `Ly`, `Lz`) |
| **Poor visualization** | Enable `animate`, check MATLAB version |
| **No ground state convergence** | Reduce `tolerance`, check potential parameters |

## Testing Configurations

Use these commands to verify configurations work correctly:

```matlab
quick_test       % Test all configurations quickly
test_configs     % Detailed validation of all config files
```

Both scripts will report any issues with configuration files or parameter ranges. 