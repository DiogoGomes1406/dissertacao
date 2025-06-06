function [Ids, Vds, Igs, Vgs, t] = smu_sweep(smu, vGS_list, dwell_time, axes, curve_id)
% SMU_SWEEP Performs a sweep, acquiring the curve and adding it to the same
% plot. tem aquela cena da update_freq.


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
xlabel(axes, 'Vgs (V)');
ylabel(axes, 'Ids (A)');
title(axes, 'Real-time Ids vs Vgs');

counter = 1;

% Set initial voltage on the SMU
smu_dc_voltage(smu, 2, vGS_list(1));

% this must be done so the initial measurment stabilizes
smu_read(smu, 1);
smu_read(smu, 2);

pause(dwell_time);

% Update frequency
update_freq = 2;


for vgs = vGS_list
    start_time = tic;
    % Apply Vgs to the SMU
    smu_dc_voltage(smu, 2, vgs);

    % Measure the current and voltage
    [Ids(counter), Vds(counter)] = smu_read(smu, 1);
    [Igs(counter), Vgs(counter)] = smu_read(smu, 2);

    % Update the time
    t(counter) = toc(start_time);

    % Update plot dynamically
    if mod(counter, update_freq) == 0
        set(h, 'XData', Vgs(1:counter), 'YData', Ids(1:counter));
        drawnow limitrate;
    end

    counter = counter + 1;
end

% Final plot update after loop ends
set(h, 'XData', Vgs, 'YData', Ids);

% Enable legend to track multiple sweeps
legend(axes, 'show');
end
