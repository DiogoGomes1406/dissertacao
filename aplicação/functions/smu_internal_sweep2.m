function [I1,V1,I2,V2,t]=smu_internal_sweep2(smu, Vgs_list, vDS, DS_comp, GS_comp, ...
    axes, curve_id, curve_color,x_var, y_var,fixed_channel,NPLC)
%SMU_INTERNAL_SWEEP Summary of this function goes here
%   Detailed explanation goes here

% Keep existing plots
hold(axes, 'on');

% Generate a new plot handle for this sweep
h = plot(axes, NaN, NaN, 'DisplayName', curve_id, 'Color', curve_color, 'LineWidth', 1.5);
visaTimeout = numel(Vgs_list);  % Gives 1 second per point (should be more than enough!)
smu.Timeout = visaTimeout;
t1 = tic;

% NPLC = 0.01;


sweep_voltages = Vgs_list;
fixed_voltages = vDS*ones(1,numel(sweep_voltages));

try
    if fixed_channel ==1
        % Build comma-separated list strings more efficiently
        ch1_voltListStr = sprintf('%.6g,', fixed_voltages);
        ch1_voltListStr = ch1_voltListStr(1:end-1);  % Remove trailing comma

        ch2_voltListStr = sprintf('%.6g,', sweep_voltages);
        ch2_voltListStr = ch2_voltListStr(1:end-1);  % Remove trailing comma


    else
        ch1_voltListStr = sprintf('%.6g,', sweep_voltages);
        ch1_voltListStr = ch1_voltListStr(1:end-1);  % Remove trailing comma

        ch2_voltListStr = sprintf('%.6g,', fixed_voltages);
        ch2_voltListStr = ch2_voltListStr(1:end-1);  % Remove trailing comma

    end

    %--- Channel 1 configuration ---
    sendCommandWithCheck(smu, ':SOUR1:FUNC:MODE VOLT');           % Voltage source
    sendCommandWithCheck(smu, ':SOUR1:VOLT:MODE LIST');           % LIST mode
    sendCommandWithCheck(smu, [':SOUR1:LIST:VOLT ', ch1_voltListStr]);% Define list
    sendCommandWithCheck(smu, ':SENS1:FUNC "CURR"');              % Measure current
    %sendCommandWithCheck(smu, ':SENS1:CURR:NPLC 1');              % 1 PLC
    sendCommandWithCheck(smu, [':SENS1:CURR:NPLC ', num2str(NPLC)]);
    sendCommandWithCheck(smu, [':SENS1:CURR:PROT ', num2str(DS_comp)]); % Compliance
    sendCommandWithCheck(smu, ':TRIG1:SOUR AINT');                % Internal trigger
    sendCommandWithCheck(smu, [':TRIG1:COUN ', num2str(numel(fixed_voltages))]);    % Count

    %--- Channel 2 configuration ---
    sendCommandWithCheck(smu, ':SOUR2:FUNC:MODE VOLT');
    sendCommandWithCheck(smu, ':SOUR2:VOLT:MODE LIST');
    sendCommandWithCheck(smu, [':SOUR2:LIST:VOLT ', ch2_voltListStr]);
    sendCommandWithCheck(smu, ':SENS2:FUNC "CURR"');
    %sendCommandWithCheck(smu, ':SENS2:CURR:NPLC 1');
    sendCommandWithCheck(smu, [':SENS2:CURR:NPLC ', num2str(NPLC)]);
    sendCommandWithCheck(smu, [':SENS2:CURR:PROT ', num2str(GS_comp)]);
    sendCommandWithCheck(smu, ':TRIG2:SOUR AINT');
    sendCommandWithCheck(smu, [':TRIG2:COUN ', num2str(numel(sweep_voltages))]);




    % Clear any previous measurement data
    sendCommandWithCheck(smu, ':TRAC:CLE');

    % Turn on outputs
    sendCommandWithCheck(smu, ':OUTP1 ON');
    sendCommandWithCheck(smu, ':OUTP2 ON');

    % Let both channels settle - dynamic settling time based on point count
    settleTime = min(0.5, 0.01 * numel(sweep_voltages));
    pause(settleTime);

    %--- Initiate both channels together ---
    sendCommandWithCheck(smu, ':INIT (@1,2)');  % Synchronized start

    sendCommandWithCheck(smu, '*WAI');   % wait until both list-sweeps finish

    if fixed_channel ==1
        %--- Fetch results ---
        % Preallocate arrays for speed
        I1 = zeros(numel(fixed_voltages), 1);
        I2 = zeros(numel(sweep_voltages), 1);

        raw1 = query(smu, ':FETC:ARR:CURR? (@1)');
        I1 = str2num(raw1);
        raw2 = query(smu, ':FETC:ARR:CURR? (@2)');
        I2 = str2num(raw2);

        %--- Display & plot ---
        V1 = fixed_voltages(:);
        V2 = sweep_voltages(:);

    else
        I2 = zeros(numel(fixed_voltages), 1);
        I1 = zeros(numel(sweep_voltages), 1);

        raw1 = query(smu, ':FETC:ARR:CURR? (@2)');
        I1 = str2num(raw1);
        raw2 = query(smu, ':FETC:ARR:CURR? (@1)');
        I2 = str2num(raw2);

        %--- Display & plot ---
        V2 = fixed_voltages(:);
        V1 = sweep_voltages(:);

    end

    t2 = toc(t1);

    t = linspace(0,t2,numel(V2));
    % close
    % plot(t, I1, 'DisplayName', 'I1')
    % hold on
    % plot(t, I2, 'DisplayName', 'I2')
    % plot(t, V1, 'DisplayName', 'V1')
    % plot(t, V2, 'DisplayName', 'V2')
    %
    % xlabel('Time (s)')
    % ylabel('Amplitude')
    % title('Currents and Voltages over Time')
    % legend('show')
    % grid on



    % Map x_var and y_var to the corresponding data arrays
    switch x_var
        case 'Vgs'
            x_data = V2;
            x_label = 'Vgs (V)';
        case 'Igs'
            x_data = I2;
            x_label = 'Igs (A)';
        case 'Vds'
            x_data = V1;
            x_label = 'Vds (V)';
        case 'Ids'
            x_data = I1;
            x_label = 'Ids (A)';
        case 't'
            x_data = t;
            x_label = 'Time (s)';
        otherwise
            error('Invalid x_var. Must be one of: Vgs, Igs, Vds, Ids, t.');
    end

    switch y_var
        case 'Vgs'
            y_data = V2;
            y_label = 'Vgs (V)';
        case 'Igs'
            y_data = I2;
            y_label = 'Igs (A)';
        case 'Vds'
            y_data = V1;
            y_label = 'Vds (V)';
        case 'Ids'
            y_data = I1;
            y_label = 'Ids (A)';
        case 't'
            y_data = t;
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

catch ME
    % Error handling
    fprintf('Error: %s\n', ME.message);
    % Display the full error stack
    disp(getReport(ME,'extended'));
end
end