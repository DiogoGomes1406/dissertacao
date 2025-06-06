function [Ids, Vds, Igs, Vgs, t] = dummy_smu_sweep(app,vds, vGS_list, dwell_time, axes, curve_id, x_var, y_var, curve_color)
% DUMMY_SMU_SWEEP Simulates a DC sweep with random noise, supporting dynamic plotting.

%% Constants
mu = 700.0e-4;
Rs = 800.0;
Ec = 4.5e5;
beta = 1.4;
q = 1.60217646e-19;
vf = 1e6;
epsr = 8.85418782e-12;
h = 6.62668e-34;
Hsub = 285e-9;
tox = 15e-9;
L = 1e-6;
W = 1.1e-6;
Cgio = 0.8072;
ntop = 0.5e16;
k_sub = 3.9;
k = 3.9;
h_ba = h / (2 * pi);

%% User-defined parameters
Vbs = 5; % Fixed back-gate voltage
Vds_fixed = vds; % Fixed Vds for this example
noise_level = vds*0.000001; % Noise amplitude for Ids

%% Computed Values
Cq = sqrt(ntop / pi) * (q^2 / (vf * h_ba));
Ce = Cgio * epsr * k / tox;
Ctop = Cq * Ce / (Cq + Ce);
Cback = epsr * k_sub / Hsub;
Vgs0 = 1.45;
Vbs0 = 2.7;
Vo = Vgs0 + (Cback / Ctop) * (Vbs0 - Vbs);
Vc = Ec * L;
Y = beta * W * mu * Ec * Ctop * Rs;

%% Pre-allocate arrays
Ids = zeros(size(vGS_list));
Vds = zeros(size(vGS_list));
Igs = zeros(size(vGS_list));
Vgs = zeros(size(vGS_list));
t = zeros(size(vGS_list));

%% plotting
% Keep existing plots
hold(axes, 'on');

% Generate a new plot handle for this sweep
h = plot(axes, NaN, NaN, 'DisplayName', curve_id, 'Color', curve_color, 'LineWidth', 1.5);

% Define axis labels dynamically based on input
xlabel(axes, x_var);
ylabel(axes, y_var);
title(axes, ['Real-time ', y_var, ' vs ', x_var]);

% Simulated time tracking
start_time = tic;

for counter = 1:length(vGS_list)
    if app.interrupt_flag == 1
        break
    end
    Vgs(counter) = vGS_list(counter);
    Vg0 = Vgs(counter) - Vo;

    %% calculation
    if Vg0 <= 0 % Hole conduction
        Vdsat1h = (1 / (Y + 1)^2) * (2 * Vg0 * Y * (1 + Y) + (1 - Y) * (Vc - sqrt((Vc^2) - 2 * Vc * Vg0 * (Y + 1))));
        Vdsat2h = Vdsat1h - 0.5 * abs(Vg0 - Vdsat1h);
        if Vds_fixed > Vdsat1h
            Ids(counter) = -(1.0 / (4.0 * Rs)) * (Vc - Vds_fixed + 2.0 * Y * (Vds_fixed / 2.0 - Vg0) - sqrt((Vc + Vds_fixed + 2.0 * Y * (Vds_fixed / 2.0 - Vg0))^2 - 4.0 * Vc * Vds_fixed));
        elseif (Vds_fixed >= Vdsat1h) && (Vds_fixed <= Vdsat2h)
            Ids(counter) = (Y / (Rs * (1 + Y)^2)) * (-Vc + (1 + Y) * Vg0 + sqrt(Vc^2 - 2 * (1 + Y) * Vc * Vg0));
        else
            Ids(counter) = -(W / (2.0 * L)) * mu * Ctop * Vdsat2h^2 * ((Vds_fixed / Vdsat2h - 1)^2) + (Y / (Rs * (1 + Y)^2)) * (-Vc + (1 + Y) * Vg0 + sqrt(Vc^2 - 2 * (1 + Y) * Vc * Vg0));
        end
    else % Electron conduction
        Vdsat1e = (1.0 / (Y + 1)^2) * (2.0 * Vg0 * Y * (1 + Y) + (Y - 1) * (Vc - sqrt(Vc^2 + 2.0 * Vc * Vg0 * (Y + 1))));
        Vdsat2e = Vdsat1e + 0.5 * abs(Vg0 - Vdsat1e);
        if Vds_fixed < Vdsat1e
            Ids(counter) = (1.0 / (4.0 * Rs)) * (Vc + Vds_fixed - 2.0 * Y * (Vds_fixed / 2.0 - Vg0) - sqrt((-Vc + Vds_fixed + 2.0 * Y * (Vds_fixed / 2.0 - Vg0))^2 + 4.0 * Vc * Vds_fixed));
        elseif (Vds_fixed >= Vdsat1e) && (Vds_fixed <= Vdsat2e)
            Ids(counter) = (Y / (Rs * (1 + Y)^2)) * (Vc + (1 + Y) * Vg0 - sqrt(Vc^2 + 2 * (1 + Y) * Vc * Vg0));
        else
            Ids(counter) = (W / (2.0 * L)) * mu * Ctop * Vdsat2e^2 * (((Vds_fixed / Vdsat2e) - 1)^2) + (Y / (Rs * (1 + Y)^2)) * (Vc + (1 + Y) * Vg0 - sqrt(Vc^2 + 2 * (1 + Y) * Vc * Vg0));
        end
    end

    %%
    % Add random noise to Ids
    Ids(counter) = Ids(counter) + noise_level * randn;

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


    drawnow;

    % Pause for dwell time (simulate measurement delay)
    pause(0.00001);
end



% Enable legend to track multiple sweeps
%legend(axes, 'show');
end