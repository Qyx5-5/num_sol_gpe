**I. Core Algorithm: Time-Splitting Spectral Method (TSSP)**

The core algorithm remains the same across all dimensions. The differences will be in how you define the potential, the Laplacian, and how you perform the FFTs.

**Algorithm:**

1. **Initialization:**
    *   Define parameters: `ε`, `κ`, `γ_y`, `γ_z`, `d` (dimension), `Lx`, `Ly`, `Lz`, `Nx`, `Ny`, `Nz`, `T`, `dt`.
    *   Calculate derived parameters: `dx`, `dy`, `dz`, `Nt`, `kx`, `ky`, `kz`.
    *   Calculate `κ_d` based on `d`, `κ`, `γ_y`, `γ_z`, and `ε` (using the formulas from the paper, Eq. 2.37 or 2.38).
    *   Define the trap potential `V` as a function of `x` (1D), `x` and `y` (2D), or `x`, `y`, and `z` (3D), and the parameters `γ_y`, `γ_z`.
    *   Choose an initial wave function `ψ0` (e.g., Gaussian, approximate ground state, or a custom function).
    *   Normalize `ψ0` so that the integral of |ψ0|² over the domain is equal to 1.

2. **Time Loop (for n = 1 to Nt):**
    *   **Step 1: Potential Evolution (Half Time Step)**
        *   ```
            ψ = ψ * exp(-1i * dt / (2 * ε) * (V + κ_d * |ψ|²))
            ```
    *   **Step 2: Kinetic Evolution (Full Time Step)**
        *   Calculate the Fourier transform of `ψ`: `ψ_hat = FFT(ψ)` (using `fft` in 1D, `fft2` in 2D, `fftn` in 3D).
        *   Multiply `ψ_hat` by the kinetic evolution operator in Fourier space:
            ```
            ψ_hat = ψ_hat * exp(-1i * ε * dt * K / 2)
            ```
            where `K` is the kinetic operator in Fourier space, defined as:
                *   **1D:** `K = kx.^2`
                *   **2D:** `K = kx.^2 + ky.'.^2` (or use `bsxfun` for efficient calculation)
                *   **3D:** `K = kx.^2 + ky.^2 + kz.^2` (use `reshape` or `bsxfun` to handle the 3D array correctly)
        *   Calculate the inverse Fourier transform: `ψ = IFFT(ψ_hat)` (using `ifft` in 1D, `ifft2` in 2D, `ifftn` in 3D).
    *   **Step 3: Potential Evolution (Half Time Step)**
        *   ```
            ψ = ψ * exp(-1i * dt / (2 * ε) * (V + κ_d * |ψ|²))
            ```
    *   **(Optional) Monitoring/Output:**
        *   Calculate the density: `ρ = |ψ|²`
        *   Calculate condensate widths: `σ_x`, `σ_y`, `σ_z` (using formulas analogous to Eq. 4.2, adapted for each dimension).
        *   Plot the density, widths, or other quantities of interest.
        *   Store results for later analysis.

**II. Dimension-Specific Adaptations**

**1. 1D Case (d = 1):**

*   **Potential:** `V = 0.5 * x.^2` (or more complex forms)
*   **Laplacian:** `∇²ψ` becomes `∂²ψ/∂x²`
*   **FFT:** Use `fft` and `ifft`.
*   **Kinetic Operator:** `K = kx.^2`
*   **Condensate Width:**
    ```
    x_mean = ∫ x * ρ dx
    σ_x = √(∫ (x - x_mean)² * ρ dx)
    ```

**2. 2D Case (d = 2):**

*   **Potential:** `V = 0.5 * (x.^2 + γ_y^2 * y.^2)` (or more complex forms)
*   **Laplacian:** `∇²ψ` becomes `∂²ψ/∂x² + ∂²ψ/∂y²`
*   **FFT:** Use `fft2` and `ifft2`.
*   **Kinetic Operator:** `K = kx.^2 + ky.'.^2` (use broadcasting or `bsxfun` for efficiency)
*   **Condensate Widths:**
    ```
    x_mean = ∫∫ x * ρ dx dy
    y_mean = ∫∫ y * ρ dx dy
    σ_x = √(∫∫ (x - x_mean)² * ρ dx dy)
    σ_y = √(∫∫ (y - y_mean)² * ρ dx dy)
    ```

**3. 3D Case (d = 3):**

*   **Potential:** `V = 0.5 * (x.^2 + γ_y^2 * y.^2 + γ_z^2 * z.^2)` (or more complex forms)
*   **Laplacian:** `∇²ψ` becomes `∂²ψ/∂x² + ∂²ψ/∂y² + ∂²ψ/∂z²`
*   **FFT:** Use `fftn` and `ifftn`.
*   **Kinetic Operator:** `K = kx.^2 + ky.^2 + kz.^2` (use `reshape` or `bsxfun` to handle the 3D array correctly)
*   **Condensate Widths:**
    ```
    x_mean = ∫∫∫ x * ρ dx dy dz
    y_mean = ∫∫∫ y * ρ dx dy dz
    z_mean = ∫∫∫ z * ρ dx dy dz
    σ_x = √(∫∫∫ (x - x_mean)² * ρ dx dy dz)
    σ_y = √(∫∫∫ (y - y_mean)² * ρ dx dy dz)
    σ_z = √(∫∫∫ (z - z_mean)² * ρ dx dy dz)
    ```

**III. Handling Different Cases**

**1. Weak/Strong Interactions:**

*   **Weak:** `κ_d` will be small. You might be able to use larger time steps. The approximate ground state (Eq. 2.15) might be a good initial condition.
*   **Strong:** `κ_d` will be large. You might need smaller time steps for stability. The Thomas-Fermi approximation (Eq. 2.17) might be a useful starting point for the ground state.

**2. Defocusing/Focusing Nonlinearity:**

*   **Defocusing:** `κ_d` is positive. The TSSP is generally well-behaved.
*   **Focusing:** `κ_d` is negative. Be more cautious with the time step. The solution might develop singularities (collapse). Consider adding artificial dissipation or using more sophisticated numerical techniques to handle this case.

**3. Zero/Nonzero Initial Phase:**

*   **Zero Phase:** The initial condition `ψ0` is real-valued.
*   **Nonzero Phase:** The initial condition `ψ0` has a spatially varying phase (e.g., `ψ0 = A(x) * exp(i * S(x) / ε)`). This can lead to interesting dynamics, such as the formation of vortices.

**4. Changing Trap Frequency:**

*   Modify the potential `V` to include a time-dependent `γ_y` and/or `γ_z`. For example, you could make them functions of time: `γ_y(t)`, `γ_z(t)`.

**5. Stirring Potential (Vortex Creation):**

*   Add the time-dependent stirring potential `W(x, t)` (defined in Example 5) to the potential `V` in the first and third steps of the TSSP loop.

**IV. Ground State Calculation**

**1. Imaginary Time Evolution:**

*   Replace `dt` with `-1i * dt` in the TSSP algorithm.
*   Start with an initial guess for the ground state (e.g., the approximate ground state solutions from the paper or a Gaussian).
*   Iterate the TSSP loop until the solution converges to a steady state. This steady state will be the (unnormalized) ground state.
*   Normalize the ground state.

**2. Direct Minimization of Energy Functional:**

*   Define a MATLAB function that calculates the energy functional (Eq. 2.12) for a given wave function `ψ`.
*   Use an optimization algorithm (e.g., gradient descent, `fminunc` in MATLAB) to find the `ψ` that minimizes the energy functional, subject to the normalization constraint.

**V. Numerical Considerations**

1. **Computational Domain:** Choose `Lx`, `Ly`, and `Lz` large enough to contain the condensate throughout the simulation.
2. **Grid Resolution:**
    *   Start with a coarser grid and refine it (decrease `dx`, `dy`, `dz`) until the solution no longer changes significantly.
    *   The paper's suggestion `h = O(ε)` is a good starting point for the defocusing case.
    *   You might need a finer grid for strong interactions, focusing nonlinearity, or sharp features in the solution.
3. **Time Step:**
    *   Start with a larger time step and decrease it (reduce `dt`) until the solution is stable and accurate.
    *   The paper's suggestion `k = O(ε)` is a good starting point for the defocusing case.
    *   You might need a smaller time step for strong interactions or focusing nonlinearity.
4. **Adaptive Time-Stepping**:
    *   Monitor the change in psi and adjust dt during the simulation.


