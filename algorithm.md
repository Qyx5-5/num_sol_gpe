# Time-Splitting Spectral (TSSP) Algorithm

This document describes the mathematical foundation and numerical implementation of the Time-Splitting Spectral method used in this GPE solver.

## Mathematical Background

### Gross-Pitaevskii Equation

The time-dependent Gross-Pitaevskii equation in dimensionless form is:

```
iε ∂ψ/∂t = -ε²/2 ∇²ψ + V(x,y,z)ψ + κ|ψ|²ψ
```

Where:
- `ψ(x,y,z,t)` is the condensate wave function
- `ε` is the dimensionless Planck constant
- `κ` is the interaction strength parameter
- `V(x,y,z)` is the external trapping potential

### TSSP Decomposition

The TSSP method splits the GPE into kinetic and potential evolution operators:

```
H = T + V
T = -ε²/2 ∇²         (kinetic energy)
V = V(x,y,z) + κ|ψ|² (potential + nonlinear interaction)
```

## Core Algorithm

### One TSSP Time Step

Each time step `dt` is split into three sub-steps:

1. **Potential Half-Step**: `ψ ← ψ × exp(-i dt V/(2ε))`
2. **Kinetic Full-Step**: `ψ ← IFFT[exp(-i ε dt k²/2) × FFT[ψ]]`  
3. **Potential Half-Step**: `ψ ← ψ × exp(-i dt V/(2ε))`

This corresponds to the operator splitting:
```
ψ(t+dt) ≈ exp(-i dt V/(2ε)) exp(-i dt T/ε) exp(-i dt V/(2ε)) ψ(t)
```

### Implementation Details

#### Potential Evolution Step
```matlab
function psi = apply_potential_step(psi, V, dt_half, params)
    kappa = params.kappa;
    epsilon = params.epsilon;
    
    % Apply potential and nonlinear evolution
    psi = psi .* exp(-1i * dt_half / epsilon * (V + kappa * abs(psi).^2));
end
```

#### Kinetic Evolution Step  
```matlab
function psi = apply_kinetic_step(psi, kx, ky, kz, dt, params, dimension)
    epsilon = params.epsilon;
    
    switch dimension
        case 1
            psi_hat = fft(psi);
            K = kx.^2;
            psi = ifft(exp(-1i * epsilon * dt * K / 2) .* psi_hat);
            
        case 2
            psi_hat = fft2(psi);
            [KX, KY] = meshgrid(kx, ky);
            K = KX.^2 + KY.^2;
            psi = ifft2(exp(-1i * epsilon * dt * K / 2) .* psi_hat);
            
        case 3
            psi_hat = fftn(psi);
            [KX, KY, KZ] = meshgrid(kx, ky, kz);
            K = KX.^2 + KY.^2 + KZ.^2;
            psi = ifftn(exp(-1i * epsilon * dt * K / 2) .* psi_hat);
    end
end
```

## Dimension-Specific Implementations

### 1D Case

**Spatial Grid**:
```matlab
x = linspace(-Lx/2, Lx/2, Nx);
dx = Lx/Nx;
kx = 2*pi*[0:Nx/2-1, -Nx/2:-1]/Lx;
```

**Potential Example** (Harmonic trap):
```matlab
V = 0.5 * x.^2;
```

**Condensate Width**:
```matlab
rho = abs(psi).^2;
x_mean = sum(x .* rho) * dx;
sigma_x = sqrt(sum((x - x_mean).^2 .* rho) * dx);
```

### 2D Case

**Spatial Grid**:
```matlab
x = linspace(-Lx/2, Lx/2, Nx);
y = linspace(-Ly/2, Ly/2, Ny);
[X, Y] = meshgrid(x, y);
kx = 2*pi*[0:Nx/2-1, -Nx/2:-1]/Lx;
ky = 2*pi*[0:Ny/2-1, -Ny/2:-1]/Ly;
```

**Potential Example** (Anisotropic harmonic):
```matlab
V = 0.5 * (X.^2 + gamma_y^2 * Y.^2);
```

**Condensate Widths**:
```matlab
rho = abs(psi).^2;
total_norm = sum(rho(:)) * dx * dy;
x_mean = sum(X(:) .* rho(:)) * dx * dy / total_norm;
y_mean = sum(Y(:) .* rho(:)) * dx * dy / total_norm;
sigma_x = sqrt(sum((X(:) - x_mean).^2 .* rho(:)) * dx * dy / total_norm);
sigma_y = sqrt(sum((Y(:) - y_mean).^2 .* rho(:)) * dx * dy / total_norm);
```

### 3D Case

**Spatial Grid**:
```matlab
x = linspace(-Lx/2, Lx/2, Nx);
y = linspace(-Ly/2, Ly/2, Ny);  
z = linspace(-Lz/2, Lz/2, Nz);
[X, Y, Z] = meshgrid(x, y, z);
kx = 2*pi*[0:Nx/2-1, -Nx/2:-1]/Lx;
ky = 2*pi*[0:Ny/2-1, -Ny/2:-1]/Ly;
kz = 2*pi*[0:Nz/2-1, -Nz/2:-1]/Lz;
```

**Potential Example** (Triaxial harmonic):
```matlab
V = 0.5 * (X.^2 + gamma_y^2 * Y.^2 + gamma_z^2 * Z.^2);
```

## Ground State Calculation

### Imaginary Time Evolution

To find the ground state, replace `dt → -i dt` in the TSSP algorithm:

```matlab
function psi = apply_potential_step_imaginary(psi, V, dt_half, params)
    kappa = params.kappa;
    epsilon = params.epsilon;
    
    % Apply imaginary time evolution
    psi = psi .* exp(-dt_half / epsilon * (V + kappa * abs(psi).^2));
end

function psi = apply_kinetic_step_imaginary(psi, kx, ky, kz, dt, params, dimension)
    epsilon = params.epsilon;
    
    switch dimension
        case 1
            psi_hat = fft(psi);
            K = kx.^2;
            psi = ifft(exp(-epsilon * dt * K / 2) .* psi_hat);
            
        % Similar for 2D and 3D...
    end
end
```

**Convergence Criterion**:
```matlab
E_old = calculate_energy(psi, V, kx, ky, kz, dx, dy, dz, params, config);
% ... perform TSSP step ...
E_new = calculate_energy(psi, V, kx, ky, kz, dx, dy, dz, params, config);

if abs(E_new - E_old) < tolerance
    converged = true;
end
```

## Potential Functions

### Harmonic Trap
```matlab
function V = harmonic_potential(x, y, z, gamma_y, gamma_z, dimension)
    switch dimension
        case 1
            V = 0.5 * x.^2;
        case 2
            [X, Y] = meshgrid(x, y);
            V = 0.5 * (X.^2 + gamma_y^2 * Y.^2);
        case 3
            [X, Y, Z] = meshgrid(x, y, z);
            V = 0.5 * (X.^2 + gamma_y^2 * Y.^2 + gamma_z^2 * Z.^2);
    end
end
```

### Optical Lattice
```matlab
function V = optical_lattice_potential(x, y, z, V0, kL, use_harmonic, gamma_y, gamma_z, dimension)
    switch dimension
        case 1
            V_lattice = V0 * cos(kL * x).^2;
            if use_harmonic
                V = V_lattice + 0.5 * x.^2;
            else
                V = V_lattice;
            end
            
        case 2
            [X, Y] = meshgrid(x, y);
            V_lattice = V0 * (cos(kL * X).^2 + cos(kL * Y).^2);
            if use_harmonic
                V = V_lattice + 0.5 * (X.^2 + gamma_y^2 * Y.^2);
            else
                V = V_lattice;
            end
            
        % Similar for 3D...
    end
end
```

### Double Well
```matlab
function V = double_well_potential(x, barrier_height, barrier_width, well_separation)
    % Gaussian barrier at center
    V_barrier = barrier_height * exp(-(x / barrier_width).^2);
    
    % Harmonic wells at ±well_separation/2
    x_left = x + well_separation/2;
    x_right = x - well_separation/2;
    V_wells = 0.5 * min(x_left.^2, x_right.^2);
    
    V = V_barrier + V_wells;
end
```

## Initial Conditions

### Gaussian Wave Packet
```matlab
function psi = gaussian_initial_condition(x, y, z, sigma_x, sigma_y, sigma_z, dimension)
    switch dimension
        case 1
            psi = exp(-(x / sigma_x).^2);
            
        case 2
            [X, Y] = meshgrid(x, y);
            psi = exp(-(X / sigma_x).^2 - (Y / sigma_y).^2);
            
        case 3
            [X, Y, Z] = meshgrid(x, y, z);
            psi = exp(-(X / sigma_x).^2 - (Y / sigma_y).^2 - (Z / sigma_z).^2);
    end
    
    % Normalize
    norm_factor = calculate_norm(psi, dx, dy, dz, dimension);
    psi = psi / sqrt(norm_factor);
end
```

### Thomas-Fermi Approximation
```matlab
function psi = thomas_fermi_initial_condition(x, y, z, V, kappa, dimension)
    % Thomas-Fermi profile: |ψ|² = max(0, (μ - V)/κ)
    % where μ is the chemical potential
    
    mu = max(V(:));  % Initial guess for chemical potential
    
    switch dimension
        case 1
            rho_tf = max(0, (mu - V) / kappa);
            psi = sqrt(rho_tf);
            
        case 2
            [X, Y] = meshgrid(x, y);
            rho_tf = max(0, (mu - V) / kappa);
            psi = sqrt(rho_tf);
            
        % Similar for 3D...
    end
    
    % Normalize
    norm_factor = calculate_norm(psi, dx, dy, dz, dimension);
    psi = psi / sqrt(norm_factor);
end
```

## Energy Calculation

The total energy consists of kinetic, potential, and interaction contributions:

```matlab
function E = calculate_energy(psi, V, kx, ky, kz, dx, dy, dz, params, config)
    epsilon = params.epsilon;
    kappa = params.kappa;
    dimension = config.simulation.dimension;
    
    % Density
    rho = abs(psi).^2;
    
    % Kinetic energy: ε²/2 ∫ |∇ψ|² dx
    switch dimension
        case 1
            psi_hat = fft(psi);
            grad_psi_sq = sum(kx.^2 .* abs(psi_hat).^2) * (2*pi/length(kx))^2;
            E_kinetic = epsilon^2 / 2 * grad_psi_sq;
            
        case 2
            psi_hat = fft2(psi);
            [KX, KY] = meshgrid(kx, ky);
            K = KX.^2 + KY.^2;
            grad_psi_sq = sum(K(:) .* abs(psi_hat(:)).^2) * (2*pi/length(kx))^2 * (2*pi/length(ky))^2;
            E_kinetic = epsilon^2 / 2 * grad_psi_sq;
            
        % Similar for 3D...
    end
    
    % Potential energy: ∫ V|ψ|² dx
    E_potential = sum(V(:) .* rho(:)) * dx * dy * dz;
    
    % Interaction energy: κ/2 ∫ |ψ|⁴ dx
    E_interaction = kappa / 2 * sum(rho(:).^2) * dx * dy * dz;
    
    E = E_kinetic + E_potential + E_interaction;
end
```

## Numerical Considerations

### Stability Criteria

1. **Time Step Constraint**: 
   ```
   dt ≤ min(dx², dy², dz²) / (2ε)
   ```

2. **Grid Resolution**:
   ```
   dx ≤ π / k_max
   ```
   where `k_max` is the maximum wave number of interest.

3. **Domain Size**: 
   The computational domain should be large enough that `|ψ(boundary)| ≈ 0`.

### Conservation Laws

The TSSP method preserves:

1. **Norm Conservation**: `∫ |ψ|² dx = constant`
2. **Energy Conservation**: For time-independent potentials

### Error Analysis

The TSSP method has:
- **Temporal Accuracy**: Second-order in `dt`
- **Spatial Accuracy**: Spectral (exponential convergence for smooth solutions)

## Performance Optimization

### Memory Efficiency
- Use in-place FFT operations when possible
- Store only necessary time snapshots
- Efficient array operations in MATLAB

### Computational Efficiency
- Vectorized operations
- Pre-computed exponential factors
- Optimal FFT sizes (powers of 2)

### Parallel Computing
The algorithm is naturally parallelizable:
- Spatial domain decomposition
- Independent frequency components in FFT
- Multiple parameter sweeps

## Implementation Notes

### MATLAB-Specific Optimizations

1. **FFT Functions**:
   - Use `fft`, `fft2`, `fftn` for forward transforms
   - Use `ifft`, `ifft2`, `ifftn` for inverse transforms

2. **Array Operations**:
   - Vectorized `.*` for element-wise multiplication
   - `meshgrid` for coordinate arrays
   - Broadcasting for efficient operations

3. **Memory Management**:
   - Pre-allocate result arrays
   - Clear large temporary variables
   - Use appropriate data types

### Numerical Stability

1. **Roundoff Errors**: Use double precision throughout
2. **Aliasing**: Ensure adequate grid resolution
3. **Boundary Conditions**: Periodic boundary conditions via FFT

This implementation provides a robust, efficient, and accurate solution to the Gross-Pitaevskii equation across multiple dimensions and physical regimes.


