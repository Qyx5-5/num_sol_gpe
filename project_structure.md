```
gpe-tssp-project/
├── src/
│   ├── initialization.m        # Grid, parameters, and initial wavefunction setup
│   ├── potentials.m            # Potential function definitions and selection
│   ├── tssp_solver.m           # Core TSSP time evolution solver
│   ├── ground_state.m          # Ground state calculation methods
│   ├── visualizations.m        # Plotting and animation functions
│   └── utils.m                 # Utility functions (config loading, kappa_d, normalization, etc.)
├── config/
│   └── default_config.json     # Simulation configuration file
├── main.m                      # Main script to run simulations
├── README.md                   # Project overview and usage guide
├── algorithm.md                # Details of the TSSP algorithm
├── potential.md                # Description of available potentials
├── project_structure.md        # This file
└── LICENSE                     # (Optional: Add a license file)
```

**Simplified Structure:**

All core MATLAB code is now located directly within the `src/` directory, reducing the number of subdirectories and files:

*   **`initialization.m`**: Consolidates `initialize_grid.m` and `initialize_wavefunction.m`. Also includes necessary local helper functions (`calculate_kappa_d`, `normalize_wavefunction`).
*   **`potentials.m`**: Consolidates all potential type functions (`harmonic.m`, `optical_lattice.m`, etc.) into one file with local functions for each type.
*   **`tssp_solver.m`**: Consolidates the core TSSP steps (`apply_potential_step.m`, `apply_kinetic_step.m`, `tssp_step.m`) as local functions within the main solver.
*   **`ground_state.m`**: Consolidates ground state calculation methods (`imaginary_time_evolution.m`, `direct_minimization.m`) and includes necessary local helper functions.
*   **`visualizations.m`**: Consolidates all plotting functions (`plot_density_1d/2d/3d`, `plot_condensate_widths`) and the animation function (`animate_simulation.m`).
*   **`utils.m`**: Consolidates utility functions (`load_config.m`, `calculate_kappa_d.m`, `calculate_condensate_widths.m`, `calculate_energy.m`, `normalize_wavefunction.m`). Note: some helpers were duplicated into `initialization.m` and `ground_state.m` as local functions to avoid dependency issues.

**Benefits:**

*   **Reduced File Count:** Significantly fewer `.m` files.
*   **Simplified Navigation:** Easier to find relevant code as it's grouped into fewer, larger files based on core functionality.

**Drawbacks:**

*   **Larger Files:** Individual files are now larger, which might make them slightly harder to read through initially.
*   **Code Duplication:** Some helper functions (like normalization, energy calculation) were duplicated as local functions in `initialization.m` and `ground_state.m` to maintain encapsulation within those files. This was done to avoid making `utils.m` functions globally accessible or requiring complex function handle passing.

**Configuration:**

The simulation is still configured through `config/default_config.json`. Example:

```json
{
    "simulation": {
        "dimension": 2,
        "dt": 0.001,
        "T": 10,
        "Nt": 10000,
        "save_every": 100,
        "mode": "evolution" // "evolution" or "ground_state"
    },
    "grid": {
        "Nx": 128,
        "Ny": 128,
        "Nz": 1,
        "Lx": 10,
        "Ly": 10,
        "Lz": 1
    },
    "parameters": {
        "epsilon": 0.01,
        "kappa": 1,
        "gamma_y": 1,
        "gamma_z": 1
    },
    "potential": {
        "type": "harmonic", // e.g., harmonic, optical_lattice, double_well
        "parameters": {} // Potential-specific parameters here
    },
    "initial_condition": {
        "type": "gaussian", // e.g., gaussian, thomas_fermi
        "parameters": {
            "sigma_x": 1,
            "sigma_y": 1
        }
    },
    "ground_state": {
        "method": "imaginary_time", // "imaginary_time" or "direct_minimization"
        "dt_imag": 0.01,
        "tolerance": 1e-8,
        "max_iter": 10000,
        "minimization_step": 0.01 // Step size for direct_minimization
    },
    "visualization": {
        "plot_density": true,
        "plot_widths": true,
        "animate": false,
        "save_video": false,
        "calculate_observables": true // Needed for plotting widths/energy
    }
}
```

**Running the Simulation:**

1.  Edit `config/default_config.json`.
2.  Run `main.m` from the project root directory in MATLAB.

