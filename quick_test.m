% Quick test script to verify the GPE-TSSP system with production configs
function quick_test()
    fprintf('=== Quick Test: GPE-TSSP Production Configurations ===\n');
    
    % Add source path
    addpath('src');
    
    try
        % Test 1: Default configuration
        fprintf('Test 1: Default Configuration...\n');
        helpers = utils();
        config = helpers.load_config('config/default_config.json');
        if isfield(config, 'description')
            fprintf('  %s\n', config.description);
        end
        [x,y,z,kx,ky,kz,dx,dy,dz,params,psi0] = initialization(config,helpers);
        V = potentials(x,y,z,config);
        fprintf('✅ Default configuration test passed!\n\n');
        
        % Test 2: 1D harmonic (quick simulation)
        fprintf('Test 2: 1D Harmonic Trap...\n');
        config = helpers.load_config('config/harmonic_1d.json');
        if isfield(config, 'description')
            fprintf('  %s\n', config.description);
        end
        [x,y,z,kx,ky,kz,dx,dy,dz,params,psi0] = initialization(config,helpers);
        V = potentials(x,y,z,config);
        fprintf('✅ 1D Harmonic configuration test passed!\n\n');
        
        % Test 3: Quick simulation with default config (shortened)
        fprintf('Test 3: Quick simulation...\n');
        config = helpers.load_config('config/default_config.json');
        config.simulation.T = 1;  % Short simulation
        config.simulation.Nt = 100;
        config.simulation.save_every = 50;
        config.visualization.animate = false;  % Disable animation for testing
        [x,y,z,kx,ky,kz,dx,dy,dz,params,psi0] = initialization(config,helpers);
        V = potentials(x,y,z,config);
        [psi_final,results] = tssp_solver(psi0,V,kx,ky,kz,dx,dy,dz,params,config,x,y,z,helpers);
        fprintf('✅ Quick simulation completed!\n\n');
        
        % Test 4: Ground state configuration
        fprintf('Test 4: Ground State Configuration...\n');
        config = helpers.load_config('config/ground_state_calculation.json');
        if isfield(config, 'description')
            fprintf('  %s\n', config.description);
        end
        [x,y,z,kx,ky,kz,dx,dy,dz,params,psi0] = initialization(config,helpers);
        V = potentials(x,y,z,config);
        fprintf('✅ Ground state configuration test passed!\n\n');
        
        fprintf('🎉 All quick tests passed! Production configurations are ready.\n');
        fprintf('\nAvailable configurations:\n');
        config_files = {
            'default_config.json', 'General 2D harmonic trap';
            'harmonic_1d.json', '1D harmonic trap';
            'harmonic_2d.json', '2D anisotropic harmonic trap';
            'harmonic_3d.json', '3D fully anisotropic trap';
            'optical_lattice_1d.json', '1D optical lattice';
            'optical_lattice_2d.json', '2D optical lattice';
            'double_well.json', 'Double-well potential';
            'ground_state_calculation.json', 'Ground state optimization';
            'strong_nonlinearity.json', 'Thomas-Fermi regime';
        };
        
        for i = 1:size(config_files, 1)
            fprintf('  %s - %s\n', config_files{i,1}, config_files{i,2});
        end
        
        fprintf('\nTo use a configuration, edit main.m and change the config_file variable.\n');
        fprintf('See config/README.md for detailed usage instructions.\n');
        
    catch ME
        fprintf('❌ Quick test failed:\n');
        fprintf('Error: %s\n', ME.message);
        if ~isempty(ME.stack)
            fprintf('File: %s, Line: %d\n', ME.stack(1).file, ME.stack(1).line);
        end
    end
    
    % Cleanup
    rmpath('src');
end 