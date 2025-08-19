function [I1, V1, V1_expected, I2, V2, V2_expected, t] = smu_internal_sweep3( ...
    smu, Vgs_list, vDS, DS_comp, GS_comp, ...
    axes, curve_id, curve_color, x_var, y_var, fixed_channel, NPLC)

chunk_size = 500;
n_total = numel(Vgs_list);

% --- STEP 1: Infer cycle_len ---
% Try to detect a repeating cycle
cycle_len = NaN;
for i = 2:floor(n_total / 2)
    if isequal(Vgs_list(1:i), Vgs_list(i+1:2*i))
        cycle_len = i;
        break;
    end
end

% If no repetition found, treat whole list as one cycle (valid case!)
if isnan(cycle_len)
    warning("No repeating cycle found. Treating entire Vgs_list as one sweep.");
    cycle_len = n_total;
end


flag =0;
% --- STEP 2: Setup chunking by full cycles ---
n_cycles = floor(n_total / cycle_len);
I1 = []; V1 = []; V1_expected=[]; I2 = []; V2 = []; V2_expected=[]; t = [];
x_all = []; y_all = [];

chunk_idx = 1;
cycle_ptr = 1;

while cycle_ptr <= n_cycles
    chunk_cycles = 0;
    idx_list = [];

    while (chunk_cycles + 1) * cycle_len <= chunk_size && cycle_ptr <= n_cycles
        start_idx = (cycle_ptr - 1) * cycle_len + 1;
        end_idx = cycle_ptr * cycle_len;
        idx_list = [idx_list, start_idx:end_idx];
        chunk_cycles = chunk_cycles + 1;
        cycle_ptr = cycle_ptr + 1;
    end

    fprintf("Running chunk %d (%d points, %d cycles)\n", chunk_idx, numel(idx_list), chunk_cycles);

    [cI1, cV1,cV1_expected, cI2, cV2, cV2_expected, ct, cx, cy, cx_label, cy_label] = smu_internal_sweep3_chunk( ...
        smu, Vgs_list(idx_list), vDS, DS_comp, GS_comp, ...
        axes, curve_id + "_chunk" + chunk_idx, curve_color, x_var, y_var, fixed_channel, NPLC,flag);
    flag=flag+1;

    I1 = [I1; cI1(:)];
    V1 = [V1; cV1(:)];
    V1_expected = [V1_expected; cV1_expected(:)];
    I2 = [I2; cI2(:)];
    V2 = [V2; cV2(:)];
    V2_expected = [V2_expected; cV2_expected(:)];
    if isempty(t)
        t = ct(:);
    else
        t = [t; ct(:) + t(end)];
    end

    x_all = [x_all; cx(:)];
    y_all = [y_all; cy(:)];

    if chunk_idx == 1
        x_label = cx_label;
        y_label = cy_label;
    end

    chunk_idx = chunk_idx + 1;
    pause(0.1); 
end

% Final plot
hold(axes, 'on');
plot(axes, x_all, y_all, 'DisplayName', curve_id, 'Color', curve_color, 'LineWidth', 1.5);
xlabel(axes, x_label);
ylabel(axes, y_label);
title(axes, ['Final Plot: ' y_label ' vs ' x_label]);
legend(axes, 'show');

end
