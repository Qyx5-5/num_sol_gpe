function V = anharmonic(x, y, z, params)
% Anharmonic potential (harmonic + quartic terms).
%
% Args:
%     x, y, z: Spatial coordinate arrays.
%     params: A structure containing potential parameters.
%             params.lambda: Anharmonicity strength.
%             params.gamma_y: Trap frequency ratio in y-direction.
%             params.gamma_z: Trap frequency ratio in z-direction.
%
% Returns:
%     V: The anharmonic potential energy array.

lambda = params.lambda;

if isempty(y) && isempty(z) % 1D
    V = 0.5 * x.^2 + lambda * x.^4;
elseif isempty(z) % 2D
    gamma_y = params.gamma_y;
    [X, Y] = meshgrid(x, y);
    V = 0.5 * (X.^2 + gamma_y^2 * Y.^2) + lambda * (X.^4 + Y.^4);
else % 3D
    gamma_y = params.gamma_y;
    gamma_z = params.gamma_z;
    [X, Y, Z] = meshgrid(x, y, z);
    V = 0.5 * (X.^2 + gamma_y^2 * Y.^2 + gamma_z^2 * Z.^2) + ...
        lambda * (X.^4 + Y.^4 + Z.^4);
end

end 