function [I1, V1, I2, V2, t] = smu_internal_sweep3( ...
    smu, Vgs_list, vDS, DS_comp, GS_comp, ...
    axes, curve_id, curve_color, x_var, y_var, fixed_channel, NPLC)

% Chunk configuration
chunk_size = 2000;
n_total = numel(Vgs_list);
n_chunks = ceil(n_total / chunk_size);

% Output arrays
I1 = [];
V1 = [];
I2 = [];
V2 = [];
t = [];

% Data for final plot
x_all = [];
y_all = [];

for i = 1:n_chunks
    idx_start = (i-1)*chunk_size + 1;
    idx_end = min(i*chunk_size, n_total);
    idx = idx_start:idx_end;

    fprintf("Running chunk %d/%d (%d points)\n", i, n_chunks, numel(idx));

    [cI1, cV1, cI2, cV2, ct, cx, cy, cx_label, cy_label] = smu_internal_sweep3_chunk( ...
        smu, Vgs_list(idx), vDS, DS_comp, GS_comp, ...
        axes, curve_id + "_chunk" + i, curve_color, x_var, y_var, fixed_channel, NPLC);

    % Concatenate measurement data
    I1 = [I1; cI1(:)];
    V1 = [V1; cV1(:)];
    I2 = [I2; cI2(:)];
    V2 = [V2; cV2(:)];
    if isempty(t)
        t = ct(:);
    else
        t = [t; ct(:) + t(end)];
    end


    % Save plotting data
    x_all = [x_all; cx(:)];
    y_all = [y_all; cy(:)];

    if i == 1
        x_label = cx_label;
        y_label = cy_label;
    end
end

% Plot after all data is acquired
hold(axes, 'on');
plot(axes, x_all, y_all, 'DisplayName', curve_id, 'Color', curve_color, 'LineWidth', 1.5);
xlabel(axes, x_label);
ylabel(axes, y_label);
title(axes, ['Final Plot: ' y_label ' vs ' x_label]);
legend(axes, 'show');

end
