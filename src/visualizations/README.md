# Visualization Modules

This directory contains functions for visualizing BEC simulation results in 1D, 2D, and 3D.

## Core Visualization Functions

### 1. Density Plots

#### `plot_density_1d.m`
Visualizes 1D condensate density:
- Final density distribution
- Time evolution density map
````

```matlab
plot_density_1d(x, psi, results, config);
```

#### `plot_density_2d.m`
2D density visualization with:
- Surface plot of final density
- Cross-sectional plots
- Optional animation
````

```matlab
plot_density_2d(x, y, psi, results, config);
```

#### `plot_density_3d.m`
3D visualization features:
- Isosurface plots
- Density slices
- Cross-sections
````

### 2. Animation (`animate_simulation.m`)

Creates dynamic visualizations of time evolution:

#### Features:
- Dimension-specific animations (1D, 2D, 3D)
- Video saving capability
- Progress display

#### Usage:
````

```matlab
% Enable animation in config
config.visualization.animate = true;
config.visualization.save_video = true;  % Optional

% Call animation
animate_simulation(x, y, z, results, config);
```

### 3. Width Evolution (`plot_condensate_widths.m`)

Tracks condensate size over time:
- σx, σy, σz evolution
- Multi-dimensional support
- Automatic dimension detection

## Configuration Options

````

{
    "visualization": {
        "plot_density": true,      // Enable density plots
        "plot_widths": true,       // Enable width evolution plots
        "animate": true,           // Enable animation
        "save_video": false,       // Save animation to file
        "frame_rate": 20,          // Video frame rate
        "colormap": "jet"          // Plot colormap
    }
}
````

## Common Features

1. **Automatic Dimensionality**:
   - Adapts to 1D/2D/3D data
   - Appropriate plot types
   - Relevant cross-sections

2. **Interactive Elements**:
   - Rotatable 3D plots
   - Adjustable view angles
   - Colorbar scaling

3. **Export Options**:
   - Video saving (.avi)
   - Figure export
   - Data extraction

## Usage Examples

### 1. Basic Density Plot
````

```matlab
% 1D plot
plot_density_1d(x, psi, results, config);

% 2D plot
plot_density_2d(x, y, psi, results, config);

% 3D plot
plot_density_3d(x, y, z, psi, results, config);
```

### 2. Animated Evolution
````

```matlab
% Configure animation
config.visualization.animate = true;
config.visualization.save_video = true;

% Run animation
animate_simulation(x, y, z, results, config);
```

### 3. Width Analysis
````

```matlab
% Plot width evolution
plot_condensate_widths(results, config);
```

## Performance Tips

1. **Memory Management**:
   - Use `drawnow` sparingly
   - Clear figures in loops
   - Manage video frame storage

2. **Speed Optimization**:
   - Adjust frame rates
   - Control animation quality
   - Use appropriate plot types

3. **Large Dataset Handling**:
   - Downsample for animation
   - Use efficient plot updates
   - Clear unused variables

## Dependencies

- MATLAB Graphics
- Image Processing Toolbox (optional)
- VideoWriter for animations

## Error Handling

Each visualization function includes:
- Input validation
- Dimension checking
- Missing data warnings
- Graceful fallbacks
