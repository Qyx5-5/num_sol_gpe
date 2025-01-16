# Visualization Modules

This directory contains functions for visualizing BEC simulation results in 1D, 2D, and 3D.

## Core Visualization Functions

### 1. Density Plots

#### `plot_density_1d.m`
Visualizes 1D condensate density:
- Final density distribution
- Time evolution density map
```matlab
plot_density_1d(x, psi, results, config);
```

#### `plot_density_2d.m`
2D density visualization with:
- Surface plot of final density
- Cross-sectional plots
- Optional animation
```matlab
plot_density_2d(x, y, psi, results, config);
```

#### `plot_density_3d.m`
3D visualization features:
- Isosurface plots
- Density slices
- Cross-sections
- Multiple isosurface levels with transparency

### 2. Interactive Animation (`animate_simulation.m`)

Creates an interactive visualization dashboard with multiple synchronized plots:

#### Features:
- Interactive controls (Play/Pause, time slider)
- Multi-panel display:
  * Main density plot (1D/2D/3D)
  * Cross-section view
  * Condensate widths evolution
  * Energy evolution
- Video saving capability
- Progress display
- Automatic cleanup on close

#### Usage:
```matlab
% Enable animation in config
config.visualization.animate = true;
config.visualization.save_video = true;  % Optional
config.visualization.calculate_observables = true;  % For width/energy plots

% Call animation
animate_simulation(x, y, z, results, config);
```

### 3. Width Evolution (`plot_condensate_widths.m`)

Tracks condensate size over time:
- σx, σy, σz evolution
- Multi-dimensional support
- Automatic dimension detection

## Configuration Options

```json
{
    "visualization": {
        "plot_density": false,      // Enable separate density plots
        "plot_widths": false,       // Enable separate width evolution plots
        "animate": true,            // Enable interactive animation
        "save_video": false,        // Save animation to file
        "calculate_observables": true, // Calculate widths and energy
    }
}
```

## Common Features

1. **Interactive Elements**:
   - Play/Pause controls
   - Time navigation slider
   - Rotatable 3D plots
   - Synchronized multi-panel updates

2. **Real-time Visualization**:
   - Dynamic density evolution
   - Live width tracking
   - Energy monitoring
   - Cross-section updates

3. **Export Options**:
   - Video saving (.avi)
   - Figure export
   - Data extraction

## Performance Tips

1. **Memory Management**:
   - Efficient frame-by-frame video saving
   - Proper cleanup of resources
   - Automatic figure closure

2. **Speed Optimization**:
   - Rate-limited display updates
   - Efficient plot updates
   - Optimized animation loop

3. **Large Dataset Handling**:
   - On-the-fly video saving
   - Memory-efficient plotting
   - Resource cleanup

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
- Proper cleanup on exit
