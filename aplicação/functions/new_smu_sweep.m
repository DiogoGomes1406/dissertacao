function [Ids, Vds, Igs, Vgs, t] = new_smu_sweep(app, smu, ...
    vGS_list, dwell_time,dwell_voltage, ...
    axes, x_var, y_var, curve_id, ...
    fixed_chanel, sweep_chanel,update_freq, ...
    curve_color)


% SMU_SWEEP Performs a sweep, acquiring the curve and adding it to the same
% plot. Allows dynamic selection of x and y variables for plotting.

% Pre-allocate arrays
Ids = zeros(size(vGS_list));
Vds = zeros(size(vGS_list));
Igs = zeros(size(vGS_list));
Vgs = zeros(size(vGS_list));
t = zeros(size(vGS_list));

% Keep existing plots
hold(axes, 'on');

% Generate a new plot handle for this sweep
h = plot(axes, NaN, NaN, 'DisplayName', curve_id, 'Color', curve_color, 'LineWidth', 1.5);

% Set initial voltage on the SMU
smu_dc_voltage(smu, sweep_chanel, dwell_voltage);

% Stabilize initial measurement
smu_read(smu, fixed_chanel);
smu_read(smu, sweep_chanel);
pause(dwell_time);

% Start timer for time measurement
start_time = tic;

for counter = 1:length(vGS_list)
    if app.interrupt_flag == 1
        break
    end


    % Apply Vgs to the SMU
    smu_dc_voltage(smu, sweep_chanel, vGS_list(counter));

    
    % Measure the current and voltage
    if fixed_chanel==1
    [Ids(counter), Vds(counter)] = smu_read(smu, fixed_chanel);
    [Igs(counter), Vgs(counter)] = smu_read(smu, sweep_chanel);
    else
    [Igs(counter), Vgs(counter)] = smu_read(smu, fixed_chanel);
    [Ids(counter), Vds(counter)] = smu_read(smu, sweep_chanel);
    end

    % Update the time
    t(counter) = toc(start_time);

    % Map x_var and y_var to the corresponding data arrays
    switch x_var
        case 'Vgs'
            x_data = Vgs(1:counter);
            x_label = 'Vgs (V)';
        case 'Igs'
            x_data = Igs(1:counter);
            x_label = 'Igs (A)';
        case 'Vds'
            x_data = Vds(1:counter);
            x_label = 'Vds (V)';
        case 'Ids'
            x_data = Ids(1:counter);
            x_label = 'Ids (A)';
        case 't'
            x_data = t(1:counter);
            x_label = 'Time (s)';
        otherwise
            error('Invalid x_var. Must be one of: Vgs, Igs, Vds, Ids, t.');
    end

    switch y_var
        case 'Vgs'
            y_data = Vgs(1:counter);
            y_label = 'Vgs (V)';
        case 'Igs'
            y_data = Igs(1:counter);
            y_label = 'Igs (A)';
        case 'Vds'
            y_data = Vds(1:counter);
            y_label = 'Vds (V)';
        case 'Ids'
            y_data = Ids(1:counter);
            y_label = 'Ids (A)';
        case 't'
            y_data = t(1:counter);
            y_label = 'Time (s)';
        otherwise
            error('Invalid y_var. Must be one of: Vgs, Igs, Vds, Ids, t.');
    end

    % Update plot dynamically with selected data
    set(h, 'XData', x_data, 'YData', y_data);
    xlabel(axes, x_label);
    ylabel(axes, y_label);
    title(axes, ['Real-time ' y_var ' vs ' x_var]);
%     drawnow; % Update the plot in real time

if mod(counter, update_freq) == 0  % Update every update_freq points
    drawnow;
end
end


% Enable legend to track multiple sweeps
%legend(axes, 'show');
end