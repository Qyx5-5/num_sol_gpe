
**I. Fundamental Trapping Potentials**

1. **Harmonic Potential:**
    *   **Formula:**
        *   **1D:**  `V(x) = 0.5 * ω_x² * x²`
        *   **2D:**  `V(x, y) = 0.5 * (ω_x² * x² + ω_y² * y²) `
        *   **3D:** `V(x, y, z) = 0.5 * (ω_x² * x² + ω_y² * y² + ω_z² * z²) `
        *   In the dimensionless form used in the paper, these become:
        *   **1D:** `V(x) = 0.5 * x²`
        *   **2D:** `V(x, y) = 0.5 * (x² + γ_y² * y²) `
        *   **3D:** `V(x, y, z) = 0.5 * (x² + γ_y² * y² + γ_z² * z²) `
            where `γ_y = ω_y / ω_x` and `γ_z = ω_z / ω_x`.
    *   **Description:** This is the most common and fundamental trapping potential. It arises from magnetic fields used to trap atoms in many BEC experiments. The `ω` values represent the trap frequencies in each direction.
    *   **Typical Use:** Modeling the basic confinement of atoms in a BEC. Anisotropic traps (`ω_x ≠ ω_y ≠ ω_z`) can lead to interesting shapes (cigar-shaped, disc-shaped) and dynamics.

2. **Anharmonic Potential (e.g., Quartic):**
    *   **Formula:**
        *   **1D:** `V(x) = 0.5 * ω_x² * x² + λ * x⁴` (where `λ` is a constant controlling the anharmonicity)
        *   **2D/3D:** Similar extensions with `y⁴`, `z⁴` terms.
    *   **Description:**  Adds a higher-order term to the harmonic potential. This can model deviations from a purely harmonic trap or be used to study the effects of stronger confinement.
    *   **Typical Use:**  Investigating the stability of condensates, particularly in the focusing case, or exploring situations with tighter confinement.

**II. Potentials for Specific Phenomena**

1. **Optical Lattice Potential:**
    *   **Formula:**
        *   **1D:** `V(x) = V_0 * sin²(k_L * x)` (where `V_0` is the lattice depth and `k_L` is the wave number of the laser creating the lattice)
        *   **2D/3D:**  `V(x, y) = V_0 * (sin²(k_L * x) + sin²(k_L * y))` (similarly for 3D).
    *   **Description:** Created by interfering laser beams, this potential forms a periodic array of potential wells.
    *   **Typical Use:** Studying phenomena like superfluidity, Mott insulator transitions, Bloch oscillations, and the behavior of BECs in periodic structures.

2. **Double-Well Potential:**
    *   **Formula:**
        *   **1D:** Can be modeled in various ways, for example:
            *   `V(x) = 0.5 * ω_x² * x² + V_0 * exp(-x²/σ²) ` (harmonic potential with a Gaussian barrier)
            *   `V(x) = A * x⁴ - B * x²` (quartic double-well)
            *   `V(x) = -V_0 * (sech²(a*(x - x_0)) + sech²(a*(x + x_0)))` (two attractive potential wells)
        *   **2D/3D:**  Extensions involving `y` and `z` coordinates.
    *   **Description:** Two potential minima separated by a barrier.
    *   **Typical Use:** Investigating Josephson oscillations, tunneling phenomena, macroscopic quantum coherence, and the dynamics of two coupled BECs.

3. **Rotating Trap Potential (for Vortex Creation):**
    *   **Formula:** Often a harmonic trap with an added time-dependent term:
        *   **2D:** `V(x, y, t) = 0.5 * (ω_x² * x² + ω_y² * y²) + W(x, y, t)`
            where `W(x, y, t)` is a stirring potential, like the Gaussian beam described in Example 5 of the paper:
            `W(x, y, t) = W_s(t) * exp(-4 * |r - r_s(t)|² / V_s²)`, with `r_s(t) = (r_0 * cos(ω_s * t), r_0 * sin(ω_s * t))`
    *   **Description:** A rotating potential can impart angular momentum to the condensate, leading to the formation of quantized vortices.
    *   **Typical Use:** Studying vortex nucleation, dynamics, and the formation of vortex lattices.

4. **Disordered Potential:**
    *   **Formula:**
        *   `V(x) = V_0 * ξ(x)` (where `ξ(x)` is a random function, often with a specified correlation length)
        *   **2D/3D:** Similar extensions.
    *   **Description:** Introduces randomness into the potential, which can model impurities or imperfections in the trap.
    *   **Typical Use:** Investigating the effects of disorder on BEC dynamics, localization phenomena, and the stability of condensates.

5. **Box Potential:**
    *   **Formula:**
        *   `V(x) = 0` for `|x| < L` and `V(x) = ∞` for `|x| ≥ L`
        *   **2D/3D:** Similar with hard walls in `y` and `z` directions.
    *   **Description:**  A potential with hard walls, confining the condensate to a finite region. Less common in actual experiments but useful for theoretical studies and simplified models.
    *   **Typical use:** Investigating finite-size effects. It is also used in optical trap experiments.

**III. Other Potentials and Combinations**

*   **Time-Dependent Potentials:** Any of the above potentials can be made time-dependent by making their parameters functions of time (e.g., changing trap frequencies, lattice depth, barrier height). This allows you to study a wide range of dynamic phenomena.
*   **Combined Potentials:** You can combine different potentials to create more complex trapping environments. For example, you could have a harmonic trap with an added optical lattice or a double-well potential superimposed on a broader harmonic trap.

**IV. Dimensionless Form**

Remember that in your numerical simulations, you'll likely be working with the dimensionless form of the GPE. Make sure to convert the potentials to their dimensionless forms using the scaling relations from the paper (Eq. 2.5 and subsequent definitions).

