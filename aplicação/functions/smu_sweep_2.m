function [Ids, Vds, Igs, Vgs, t] = smu_sweep_2(smu, vGS_list, dwell_time, axes, curve_id, update_freq, x_var, y_var)
% SMU_SWEEP Performs a sweep, acquiring the curve and adding it to the same
% plot. Allows specifying an update frequency, with 0 disabling updates,
% and supports dynamic choice of x and y variables for plotting.

% Pre-allocate arrays
Ids = zeros(size(vGS_list));
Vds = zeros(size(vGS_list));
Igs = zeros(size(vGS_list));
Vgs = zeros(size(vGS_list));
t = zeros(size(vGS_list));

% Keep existing plots
hold(axes, 'on'); 

% Generate a new plot handle for this sweep
h = plot(axes, NaN, NaN, 'DisplayName', string(curve_id));  

% Define axis labels dynamically based on input
xlabel(axes, x_var);
ylabel(axes, y_var);
title(axes, ['Real-time ', y_var, ' vs ', x_var]);

counter = 1;

% Set initial voltage on the SMU
smu_dc_voltage(smu, 2, vGS_list(1));

% Stabilize initial measurement
smu_read(smu, 1);
smu_read(smu, 2);

pause(dwell_time);

for vgs = vGS_list
    start_time = tic;
    % Apply Vgs to the SMU
    smu_dc_voltage(smu, 2, vgs);

    % Measure the current and voltage
    [Ids(counter), Vds(counter)] = smu_read(smu, 1);
    [Igs(counter), Vgs(counter)] = smu_read(smu, 2);

    % Update the time
    t(counter) = toc(start_time);

    % Extract data for x and y axes dynamically
    x_data = eval(x_var); % e.g., 'Vgs'
    y_data = eval(y_var); % e.g., 'Ids'

    % Update plot dynamically based on update frequency
    if update_freq > 0 && mod(counter, update_freq) == 0
        set(h, 'XData', x_data(1:counter), 'YData', y_data(1:counter));
        drawnow limitrate;
    end

    counter = counter + 1;
end

% Final plot update after loop ends
x_data = eval(x_var);
y_data = eval(y_var);
set(h, 'XData', x_data, 'YData', y_data);

% Enable legend to track multiple sweeps
legend(axes, 'show');
end
