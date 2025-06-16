function [I1, V1, I2, V2, t] = smu_internal_sweep3( ...
    smu, Vgs_list, vDS, DS_comp, GS_comp, ...
    axes, curve_id, curve_color, x_var, y_var, fixed_channel, NPLC)

% Chunk configuration
chunk_size = 2000;  % Safe value well below 1000
n_total = numel(Vgs_list);
n_chunks = ceil(n_total / chunk_size);

% Output arrays
I1 = [];
V1 = [];
I2 = [];
V2 = [];
t = [];

% Process each chunk
for i = 1:n_chunks
    idx_start = (i-1)*chunk_size + 1;
    idx_end = min(i*chunk_size, n_total);
    idx = idx_start:idx_end;

    fprintf("Running chunk %d/%d (%d points)\n", i, n_chunks, numel(idx));

    % Call the original function (which does a safe single sweep)
    [cI1, cV1, cI2, cV2, ct] = smu_internal_sweep3_chunk( ...
        smu, Vgs_list(idx), vDS, DS_comp, GS_comp, ...
        axes, curve_id + "_chunk" + i, curve_color, x_var, y_var, fixed_channel, NPLC);

    % Force column vectors
    cI1 = cI1(:);
    cV1 = cV1(:);
    cI2 = cI2(:);
    cV2 = cV2(:);
    ct  = ct(:);

    % Concatenate with error check
    try
        I1 = [I1; cI1];
        V1 = [V1; cV1];
        I2 = [I2; cI2];
        V2 = [V2; cV2];
    catch ME
        fprintf("Concatenation failed on chunk %d\n", i);
        fprintf("I1 size: [%s], cI1 size: [%s]\n", num2str(size(I1)), num2str(size(cI1)));
        fprintf("V1 size: [%s], cV1 size: [%s]\n", num2str(size(V1)), num2str(size(cV1)));
        fprintf("I2 size: [%s], cI2 size: [%s]\n", num2str(size(I2)), num2str(size(cI2)));
        fprintf("V2 size: [%s], cV2 size: [%s]\n", num2str(size(V2)), num2str(size(cV2)));
        rethrow(ME);
    end

    % Time vector
    if isempty(t)
        t = ct;
    else
        t = [t; ct + t(end)];
    end
end

end
