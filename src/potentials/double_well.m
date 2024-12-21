function V = double_well(x, y, z, params)
% Double-well potential.
%
% Args:
%     x, y, z: Spatial coordinate arrays.
%     params: A structure containing potential parameters.
%             params.method: Type of double-well ('gaussian_barrier' or 'quartic').
%             For 'gaussian_barrier':
%                 params.V0: Barrier height.
%                 params.sigma: Barrier width.
%             For 'quartic':
%                 params.A: Coefficient of quartic term.
%                 params.B: Coefficient of quadratic term.
%             params.gamma_y: Trap frequency ratio in y-direction (for 2D/3D).
%             params.gamma_z: Trap frequency ratio in z-direction (for 3D).
%
% Returns:
%     V: The double-well potential energy array.

if ~isfield(params, 'method')
    error('Must specify double-well method: ''gaussian_barrier'' or ''quartic''');
end

if isempty(y) && isempty(z) % 1D
    if strcmp(params.method, 'gaussian_barrier')
        V0 = params.V0;
        sigma = params.sigma;
        V = 0.5 * x.^2 + V0 * exp(-x.^2 / sigma^2);
    elseif strcmp(params.method, 'quartic')
        A = params.A;
        B = params.B;
        V = A * x.^4 - B * x.^2;
    else
        error('Invalid double-well method: %s', params.method);
    end
elseif isempty(z) % 2D
    gamma_y = params.gamma_y;
    [X, Y] = meshgrid(x, y);
    if strcmp(params.method, 'gaussian_barrier')
        V0 = params.V0;
        sigma = params.sigma;
        V = 0.5 * (X.^2 + gamma_y^2 * Y.^2) + ...
            V0 * exp(-(X.^2 + Y.^2) / sigma^2);
    elseif strcmp(params.method, 'quartic')
        A = params.A;
        B = params.B;
        V = A * (X.^4 + Y.^4) - B * (X.^2 + Y.^2);
    else
        error('Invalid double-well method: %s', params.method);
    end
else % 3D
    gamma_y = params.gamma_y;
    gamma_z = params.gamma_z;
    [X, Y, Z] = meshgrid(x, y, z);
    if strcmp(params.method, 'gaussian_barrier')
        V0 = params.V0;
        sigma = params.sigma;
        V = 0.5 * (X.^2 + gamma_y^2 * Y.^2 + gamma_z^2 * Z.^2) + ...
            V0 * exp(-(X.^2 + Y.^2 + Z.^2) / sigma^2);
    elseif strcmp(params.method, 'quartic')
        A = params.A;
        B = params.B;
        V = A * (X.^4 + Y.^4 + Z.^4) - B * (X.^2 + Y.^2 + Z.^2);
    else
        error('Invalid double-well method: %s', params.method);
    end
end

end 