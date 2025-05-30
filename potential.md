# Potential Functions Reference

This document describes all potential functions implemented in the GPE-TSSP solver, including their mathematical formulations, parameters, and typical use cases.

## Overview

The GPE solver supports three main categories of potentials:
1. **Harmonic Traps** - Standard quadratic confinement
2. **Optical Lattices** - Periodic potential arrays 
3. **Double Wells** - Two-well systems for tunneling studies

All potentials are implemented in dimensionless form and can be configured through JSON configuration files.

## Implemented Potentials

### 1. Harmonic Trap

The most fundamental trapping potential for BEC experiments.

#### Mathematical Form

**1D**: `V(x) = ½x²`

**2D**: `V(x,y) = ½(x² + γᵧ²y²)`

**3D**: `V(x,y,z) = ½(x² + γᵧ²y² + γᵤ²z²)`

Where `γᵧ = ωᵧ/ωₓ` and `γᵤ = ωᵤ/ωₓ` are the trap frequency ratios.

#### Configuration

```json
{
    "potential": {
        "type": "harmonic",
        "parameters": {
            "gamma_y": 1.5,    // Optional: y-direction anisotropy (default: 1.0)
            "gamma_z": 2.0     // Optional: z-direction anisotropy (default: 1.0)
        }
    }
}
```

#### Implementation Details

```matlab
function V = harmonic_potential(X, Y, Z, gamma_y, gamma_z, dimension)
    switch dimension
        case 1
            V = 0.5 * X.^2;
        case 2
            V = 0.5 * (X.^2 + gamma_y^2 * Y.^2);
        case 3
            V = 0.5 * (X.^2 + gamma_y^2 * Y.^2 + gamma_z^2 * Z.^2);
    end
end
```

#### Physical Characteristics

- **Shape**: Ellipsoidal energy surfaces
- **Typical γ Values**: 0.5-3.0 (common experimental range)
- **Ground State**: Gaussian profile for weak interactions
- **Use Cases**: 
  - Basic BEC confinement
  - Aspect ratio studies (γᵧ ≠ 1)
  - Breathing mode oscillations
  - Ground state calculations

#### Example Configurations

**Isotropic 2D Trap**:
```json
{"type": "harmonic", "parameters": {}}
```

**Cigar-shaped Trap** (tight in y):
```json
{"type": "harmonic", "parameters": {"gamma_y": 2.0}}
```

**Pancake-shaped Trap** (loose in z):
```json
{"type": "harmonic", "parameters": {"gamma_y": 1.0, "gamma_z": 0.5}}
```

### 2. Optical Lattice

Periodic potential created by interfering laser beams.

#### Mathematical Form

**1D**: `V(x) = V₀cos²(kₗx) + V_harmonic(x)`

**2D**: `V(x,y) = V₀[cos²(kₗx) + cos²(kₗy)] + V_harmonic(x,y)`

**3D**: `V(x,y,z) = V₀[cos²(kₗx) + cos²(kₗy) + cos²(kₗz)] + V_harmonic(x,y,z)`

The harmonic background is optional and provides overall confinement.

#### Configuration

```json
{
    "potential": {
        "type": "optical_lattice",
        "parameters": {
            "V0": 5.0,              // Lattice depth (dimensionless)
            "kL": 1.0,              // Lattice wave number
            "use_harmonic": true,   // Include harmonic background trap
            "gamma_y": 1.5,         // Background trap anisotropy
            "gamma_z": 2.0          // (only if use_harmonic = true)
        }
    }
}
```

#### Implementation Details

```matlab
function V = optical_lattice_potential(X, Y, Z, V0, kL, use_harmonic, gamma_y, gamma_z, dimension)
    switch dimension
        case 1
            V_lattice = V0 * cos(kL * X).^2;
            if use_harmonic
                V = V_lattice + 0.5 * X.^2;
            else
                V = V_lattice;
            end
            
        case 2
            V_lattice = V0 * (cos(kL * X).^2 + cos(kL * Y).^2);
            if use_harmonic
                V_harmonic = 0.5 * (X.^2 + gamma_y^2 * Y.^2);
                V = V_lattice + V_harmonic;
            else
                V = V_lattice;
            end
            
        case 3
            V_lattice = V0 * (cos(kL * X).^2 + cos(kL * Y).^2 + cos(kL * Z).^2);
            if use_harmonic
                V_harmonic = 0.5 * (X.^2 + gamma_y^2 * Y.^2 + gamma_z^2 * Z.^2);
                V = V_lattice + V_harmonic;
            else
                V = V_lattice;
            end
    end
end
```

#### Physical Characteristics

- **Lattice Spacing**: `a = π/kₗ`
- **Well Depth**: Proportional to `V₀`
- **Regime Classification**:
  - **Weak Lattice** (V₀ < 1): Small perturbation to harmonic trap
  - **Moderate Lattice** (1 ≤ V₀ ≤ 10): Band structure effects
  - **Deep Lattice** (V₀ > 10): Tight-binding regime
- **Use Cases**:
  - Superfluid-Mott insulator transitions
  - Bloch oscillations
  - Quantum phase transitions
  - Many-body localization studies

#### Example Configurations

**Shallow 1D Lattice**:
```json
{
    "type": "optical_lattice",
    "parameters": {
        "V0": 2.0,
        "kL": 1.0,
        "use_harmonic": true
    }
}
```

**Deep 2D Lattice**:
```json
{
    "type": "optical_lattice", 
    "parameters": {
        "V0": 8.0,
        "kL": 1.0,
        "use_harmonic": false
    }
}
```

### 3. Double Well

Two-well potential for studying tunneling dynamics and Josephson oscillations.

#### Mathematical Form

The implementation creates a symmetric double well using a Gaussian barrier:

`V(x) = V_barrier(x) + V_wells(x)`

Where:
- **Barrier**: `V_barrier(x) = h × exp(-(x/w)²)`
- **Wells**: Harmonic wells centered at `x = ±d/2`

#### Configuration

```json
{
    "potential": {
        "type": "double_well",
        "parameters": {
            "barrier_height": 1.0,      // Central barrier height
            "barrier_width": 0.5,       // Barrier width parameter
            "well_separation": 2.0      // Distance between well centers
        }
    }
}
```

#### Implementation Details

```matlab
function V = double_well_potential(x, barrier_height, barrier_width, well_separation)
    % Central Gaussian barrier
    V_barrier = barrier_height * exp(-(x / barrier_width).^2);
    
    % Harmonic wells at ±well_separation/2
    x_left = x + well_separation/2;
    x_right = x - well_separation/2;
    
    % Choose the closer well at each point
    dist_left = abs(x_left);
    dist_right = abs(x_right);
    use_left = (dist_left <= dist_right);
    
    V_wells = use_left .* (0.5 * x_left.^2) + (~use_left) .* (0.5 * x_right.^2);
    
    V = V_barrier + V_wells;
end
```

#### Physical Characteristics

- **Tunnel Coupling**: Depends on barrier height and width
- **Asymmetry**: Can be introduced by modifying well depths
- **Typical Parameters**:
  - Barrier height: 0.5-5.0 (relative to well depth)
  - Well separation: 1.0-4.0 (in dimensionless units)
  - Barrier width: 0.2-1.0
- **Use Cases**:
  - Josephson oscillations
  - Macroscopic quantum tunneling
  - Two-mode dynamics
  - Quantum coherence studies

#### Example Configurations

**Weak Barrier** (strong coupling):
```json
{
    "type": "double_well",
    "parameters": {
        "barrier_height": 0.5,
        "barrier_width": 0.8,
        "well_separation": 2.0
    }
}
```

**Strong Barrier** (weak coupling):
```json
{
    "type": "double_well",
    "parameters": {
        "barrier_height": 3.0,
        "barrier_width": 0.3,
        "well_separation": 3.0
    }
}
```

## Parameter Guidelines

### Scaling and Units

All potentials are implemented in dimensionless form where:
- **Energy Scale**: Set by the harmonic oscillator frequency `ωₓ`
- **Length Scale**: Harmonic oscillator length `aₓ = √(ℏ/mωₓ)`
- **Time Scale**: `1/ωₓ`

### Typical Parameter Ranges

| Potential Type | Parameter | Typical Range | Physical Meaning |
|---------------|-----------|---------------|------------------|
| **Harmonic** | γᵧ, γᵤ | 0.5 - 3.0 | Trap aspect ratios |
| **Optical Lattice** | V₀ | 0.5 - 20.0 | Lattice depth (in ℏωₓ) |
| | kₗ | 0.5 - 2.0 | Lattice wave number |
| **Double Well** | barrier_height | 0.1 - 10.0 | Barrier height |
| | barrier_width | 0.1 - 2.0 | Barrier width |
| | well_separation | 1.0 - 5.0 | Well separation |

### Computational Considerations

#### Domain Size Requirements

- **Harmonic**: Domain should extend to ~3-5 times the classical turning point
- **Optical Lattice**: Include multiple lattice periods, typically Lₓ > 10π/kₗ
- **Double Well**: Domain should contain both wells plus decay regions

#### Grid Resolution

- **Harmonic**: Standard resolution (dx ~ 0.1) sufficient
- **Optical Lattice**: Requires fine resolution to resolve oscillations: dx ≤ π/(4kₗ)
- **Double Well**: Resolution depends on barrier width: dx ≤ barrier_width/10

#### Stability Considerations

- **Deep Potentials**: May require smaller time steps
- **Sharp Features**: Need adequate spatial resolution
- **Time-dependent**: Additional stability constraints

## Advanced Usage

### Custom Potential Development

To add new potential types:

1. **Add case to `potentials.m`**:
```matlab
case 'my_potential'
    V = my_potential_function(X, Y, Z, config.potential.parameters, dimension);
```

2. **Implement potential function**:
```matlab
function V = my_potential_function(X, Y, Z, params, dimension)
    % Extract parameters
    param1 = params.param1;
    param2 = params.param2;
    
    % Calculate potential based on dimension
    switch dimension
        case 1
            V = % Your 1D potential formula
        case 2  
            V = % Your 2D potential formula
        case 3
            V = % Your 3D potential formula
    end
end
```

3. **Create configuration template**:
```json
{
    "type": "my_potential",
    "parameters": {
        "param1": 1.0,
        "param2": 2.0
    }
}
```

### Time-Dependent Potentials

While not currently implemented in the configuration system, time-dependent potentials can be added by:

1. Modifying the potential calculation in the main time loop
2. Making potential parameters functions of time
3. Recalculating the potential at each time step

Example structure:
```matlab
for n = 1:Nt
    t = n * dt;
    V = calculate_time_dependent_potential(X, Y, Z, t, config);
    % ... TSSP evolution with updated V
end
```

### Multi-Component Potentials

For studying coupled BEC systems:
```matlab
V_total = V_trap + V_coupling + V_external;
```

## Validation and Testing

### Energy Conservation

Monitor total energy for time-independent potentials:
```matlab
E_total = E_kinetic + E_potential + E_interaction;
```

### Virial Theorem

For harmonic potentials, the virial theorem provides a check:
```matlab
2*E_kinetic = sum(γ²)*E_potential  % For anisotropic harmonic trap
```

### Ground State Properties

Compare with analytical results where available:
- **Harmonic trap**: Gaussian profile
- **Thomas-Fermi limit**: Inverted parabola for strong interactions

## Troubleshooting

### Common Issues

1. **Boundary Effects**: Increase domain size if wave function reaches boundaries
2. **Insufficient Resolution**: Decrease grid spacing for sharp potential features  
3. **Instability**: Reduce time step for deep or rapidly varying potentials
4. **Unphysical Results**: Check parameter units and scaling

### Parameter Validation

The solver includes built-in parameter validation:
- Positive definite requirements
- Reasonable range checks
- Dimension consistency
- Grid resolution warnings

For detailed implementation examples, see the configuration files in `config/` and the source code in `src/potentials.m`.