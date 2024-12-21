function V = optical_lattice(x, y, z, params)
% Optical lattice potential.
%
% Args:
%     x, y, z: Spatial coordinate arrays.
%     params: A structure containing potential parameters.
%             params.V0: Lattice depth.
%             params.kL: Lattice wave number.
%             params.harmonic_trap: Boolean to include harmonic trap (default: false).
%             params.gamma_y: Trap frequency ratio in y-direction (if harmonic_trap).
%             params.gamma_z: Trap frequency ratio in z-direction (if harmonic_trap).
%
% Returns:
%     V: The optical lattice potential energy array.

V0 = params.V0;
kL = params.kL;
include_harmonic = isfield(params, 'harmonic_trap') && params.harmonic_trap;

if isempty(y) && isempty(z) % 1D
    V = V0 * sin(kL * x).^2;
    if include_harmonic
        V = V + 0.5 * x.^2;
    end
elseif isempty(z) % 2D
    [X, Y] = meshgrid(x, y);
    V = V0 * (sin(kL * X).^2 + sin(kL * Y).^2);
    if include_harmonic
        gamma_y = params.gamma_y;
        V = V + 0.5 * (x.^2 + gamma_y^2 * y.^2);
    end
else % 3D
    [X, Y, Z] = meshgrid(x, y, z);
    V = V0 * (sin(kL * X).^2 + sin(kL * Y).^2 + sin(kL * Z).^2);
    if include_harmonic
        gamma_y = params.gamma_y;
        gamma_z = params.gamma_z;
        V = V + 0.5 * (x.^2 + gamma_y^2 * y.^2 + gamma_z^2 * z.^2);
    end
end

end 