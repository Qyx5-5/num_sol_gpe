# GPE-TSSP Configuration Files

This directory contains production-ready configuration files for various BEC simulation scenarios. Each configuration is optimized for specific physical phenomena and computational requirements.

## Available Configurations

### 1. **default_config.json**
- **Purpose**: General-purpose starting configuration
- **Dimension**: 2D
- **Potential**: Harmonic trap
- **Use Case**: First-time users, general exploration
- **Features**: Balanced parameters for stable simulations

### 2. **harmonic_1d.json**
- **Purpose**: One-dimensional harmonic trap simulations
- **Dimension**: 1D
- **Potential**: Harmonic trap (`V = 0.5 * x²`)
- **Use Case**: Basic 1D BEC dynamics, breathing modes
- **Features**: High resolution (Nx=256), extended domain

### 3. **harmonic_2d.json**
- **Purpose**: Two-dimensional anisotropic harmonic trap
- **Dimension**: 2D
- **Potential**: Anisotropic harmonic (`γ_y = 1.5`)
- **Use Case**: Cigar-shaped condensates, aspect ratio studies
- **Features**: Anisotropic trapping ratios

### 4. **harmonic_3d.json**
- **Purpose**: Three-dimensional fully anisotropic trap
- **Dimension**: 3D
- **Potential**: 3D harmonic (`γ_y = 1.2, γ_z = 0.8`)
- **Use Case**: Realistic 3D BEC simulations
- **Features**: Lower resolution (64³) for computational efficiency

### 5. **optical_lattice_1d.json**
- **Purpose**: One-dimensional optical lattice potential
- **Dimension**: 1D
- **Potential**: Periodic lattice with harmonic confinement
- **Use Case**: Superfluid-Mott transitions, Bloch oscillations
- **Features**: Deep lattice (V₀=5.0), smaller time steps

### 6. **optical_lattice_2d.json**
- **Purpose**: Two-dimensional optical lattice
- **Dimension**: 2D
- **Potential**: 2D periodic lattice structure
- **Use Case**: 2D lattice physics, vortex pinning
- **Features**: Moderate lattice depth (V₀=4.0)

### 7. **double_well.json**
- **Purpose**: Double-well potential studies
- **Dimension**: 1D
- **Potential**: Barrier-separated double well
- **Use Case**: Josephson oscillations, tunneling dynamics
- **Features**: Configurable barrier height and separation

### 8. **ground_state_calculation.json**
- **Purpose**: Optimized ground state finding
- **Dimension**: 2D
- **Mode**: Ground state calculation
- **Use Case**: Finding equilibrium states, initial conditions
- **Features**: High tolerance (1e-10), extended iterations

### 9. **strong_nonlinearity.json**
- **Purpose**: Thomas-Fermi regime simulations
- **Dimension**: 2D
- **Potential**: Harmonic with strong interactions (κ=10.0)
- **Use Case**: Strongly interacting BECs, collapse dynamics
- **Features**: Small time steps (dt=0.0002), Thomas-Fermi initial condition

## Parameter Guidelines

### Time Step Selection
- **Standard**: `dt = 0.001` (most configurations)
- **Fine**: `dt = 0.0005` (optical lattices)
- **Ultra-fine**: `dt = 0.0002` (strong nonlinearity)

### Grid Resolution
- **1D**: 256 points for detailed features
- **2D**: 128×128 for balance of speed/accuracy
- **3D**: 64³ for computational feasibility

### Domain Size
- **Standard**: L = 10-12 (most cases)
- **Extended**: L = 15-20 (optical lattices, double wells)
- **Compact**: L = 8-10 (strong interactions)

## Usage Examples

### Basic Simulation
```matlab
config = load_config('config/default_config.json');
```

### Ground State Calculation
```matlab
config = load_config('config/ground_state_calculation.json');
% Run ground state finding, then switch to evolution
config.simulation.mode = 'evolution';
config.simulation.T = 5.0;
```

### Parameter Modification
```matlab
config = load_config('config/harmonic_2d.json');
% Increase interaction strength
config.parameters.kappa = 5.0;
% Enable animation
config.visualization.animate = true;
```

## Physical Regimes

### Weak Interactions (κ ≤ 1.0)
- Use: `harmonic_1d.json`, `harmonic_2d.json`
- Gaussian-like profiles
- Linear regime approximations valid

### Moderate Interactions (1.0 < κ ≤ 5.0)
- Use: `default_config.json`, `optical_lattice_*.json`
- Nonlinear effects important
- Typical experimental conditions

### Strong Interactions (κ > 5.0)
- Use: `strong_nonlinearity.json`
- Thomas-Fermi profiles
- Requires smaller time steps

## Customization Tips

1. **Increase Resolution**: Double `Nx`, `Ny`, `Nz` for finer details
2. **Extend Domain**: Increase `Lx`, `Ly`, `Lz` if condensate hits boundaries
3. **Animation**: Set `animate: true` for real-time visualization
4. **Save Video**: Set `save_video: true` for movie export
5. **Faster Computation**: Increase `save_every` to skip frames

## Troubleshooting

- **Instability**: Reduce `dt` or increase grid resolution
- **Slow Convergence**: Increase `max_iter` in ground state settings
- **Memory Issues**: Reduce grid size or use 2D instead of 3D
- **Boundary Effects**: Increase domain size (`Lx`, `Ly`, `Lz`) 