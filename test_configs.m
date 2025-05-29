% Test script for running various GPE configurations
% Run this script in MATLAB to test different configurations

function test_configs()
    % Navigate to project directory and setup
    fprintf('=== GPE-TSSP Configuration Test Suite ===\n\n');
    
    % Add source path
    addpath('src');
    
    % Define test configurations
    test_files = {
        'config/test_1d_harmonic.json', '1D Harmonic Trap';
        'config/test_2d_harmonic.json', '2D Harmonic Trap';
        'config/test_ground_state.json', 'Ground State Calculation';
        'config/test_optical_lattice.json', 'Optical Lattice';
        'config/default_config.json', 'Original Disordered Potential'
    };
    
    % Test each configuration
    for i = 1:size(test_files, 1)
        config_file = test_files{i, 1};
        test_name = test_files{i, 2};
        
        fprintf('=== Test %d: %s ===\n', i, test_name);
        fprintf('Config file: %s\n', config_file);
        
        try
            % Check if config file exists
            if ~exist(config_file, 'file')
                fprintf('❌ Config file not found: %s\n\n', config_file);
                continue;
            end
            
            % Load and run configuration
            fprintf('Loading configuration...\n');
            run_single_test(config_file, test_name);
            fprintf('✅ Test completed successfully!\n\n');
            
        catch ME
            fprintf('❌ Test failed with error:\n');
            fprintf('   %s\n', ME.message);
            fprintf('   File: %s, Line: %d\n\n', ME.stack(1).file, ME.stack(1).line);
        end
        
        % Clear figures to prevent accumulation
        close all;
        
        % Pause between tests
        pause(1);
    end
    
    % Cleanup
    rmpath('src');
    fprintf('=== All tests completed ===\n');
end

function run_single_test(config_file, test_name)
    % Run a single test with the specified config file
    
    % Get helper functions
    helpers = utils();
    
    % Load configuration
    config = helpers.load_config(config_file);
    
    % Print key parameters
    fprintf('  Dimension: %d\n', config.simulation.dimension);
    fprintf('  Mode: %s\n', config.simulation.mode);
    fprintf('  Potential: %s\n', config.potential.type);
    fprintf('  Grid size: %dx%dx%d\n', config.grid.Nx, config.grid.Ny, config.grid.Nz);
    
    % Initialize simulation
    fprintf('  Initializing...\n');
    [x, y, z, kx, ky, kz, dx, dy, dz, params, psi0] = initialization(config, helpers);
    
    % Calculate potential
    fprintf('  Calculating potential...\n');
    V = potentials(x, y, z, config);
    
    % Run simulation
    fprintf('  Running simulation...\n');
    results = [];
    psi_final = [];
    
    if strcmpi(config.simulation.mode, 'evolution')
        [psi_final, results] = tssp_solver(psi0, V, kx, ky, kz, dx, dy, dz, params, config, x, y, z, helpers);
    elseif strcmpi(config.simulation.mode, 'ground_state')
        [psi_final, results] = ground_state(psi0, V, kx, ky, kz, dx, dy, dz, params, config, helpers);
    else
        error('Unknown simulation mode: %s', config.simulation.mode);
    end
    
    % Visualize results
    fprintf('  Generating plots...\n');
    visualizations(x, y, z, psi_final, results, config);
    
    % Add title to distinguish plots
    sgtitle(sprintf('Test: %s', test_name), 'FontSize', 14, 'FontWeight', 'bold');
end 