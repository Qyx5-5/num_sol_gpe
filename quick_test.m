% Quick test script to verify the fixes
function quick_test()
    fprintf('=== Quick Test: GPE-TSSP Fixes ===\n');
    
    % Add source path
    addpath('src');
    
    try
        % Test 1: Simple 1D harmonic
        fprintf('Test 1: 1D Harmonic Trap...\n');
        helpers = utils();
        config = helpers.load_config('config/test_1d_harmonic.json');
        [x,y,z,kx,ky,kz,dx,dy,dz,params,psi0] = initialization(config,helpers);
        V = potentials(x,y,z,config);
        fprintf('✅ 1D Harmonic potential test passed!\n\n');
        
        % Test 2: Default config (should now work)
        fprintf('Test 2: Default Config...\n');
        config = helpers.load_config('config/default_config.json');
        [x,y,z,kx,ky,kz,dx,dy,dz,params,psi0] = initialization(config,helpers);
        V = potentials(x,y,z,config);
        fprintf('✅ Default config test passed!\n\n');
        
        % Test 3: Run a quick simulation
        fprintf('Test 3: Quick simulation...\n');
        config.simulation.T = 1;  % Short simulation
        config.simulation.Nt = 100;
        config.simulation.save_every = 50;
        [psi_final,results] = tssp_solver(psi0,V,kx,ky,kz,dx,dy,dz,params,config,x,y,z,helpers);
        fprintf('✅ Quick simulation completed!\n\n');
        
        fprintf('🎉 All quick tests passed! Ready for full test suite.\n');
        
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