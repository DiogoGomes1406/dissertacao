function [I1,V1,V1_expected,I2,V2,V2_expected,t,x_data,y_data,x_label,y_label] = smu_internal_sweep3_chunk(smu, Vgs_list, vDS, DS_comp, GS_comp, ...
    axes, curve_id, curve_color,x_var, y_var,fixed_channel,NPLC,flag)


visaTimeout = numel(Vgs_list);

smu.Timeout = visaTimeout;


t1 = tic;

sweep_voltages = Vgs_list;
fixed_voltages = vDS*ones(1,numel(sweep_voltages));

try
    tic
    if fixed_channel == 1
        ch1_voltListStr = sprintf('%.6g,', fixed_voltages); ch1_voltListStr(end) = [];
        ch2_voltListStr = sprintf('%.6g,', sweep_voltages); ch2_voltListStr(end) = [];
    else
        ch1_voltListStr = sprintf('%.6g,', sweep_voltages); ch1_voltListStr(end) = [];
        ch2_voltListStr = sprintf('%.6g,', fixed_voltages); ch2_voltListStr(end) = [];
    end

    % Channel 1 config
    sendCommandWithCheck(smu, ':SOUR1:FUNC:MODE VOLT');
    sendCommandWithCheck(smu, ':SOUR1:VOLT:MODE LIST');
    sendCommandWithCheck(smu, [':SOUR1:LIST:VOLT ', ch1_voltListStr]);
    sendCommandWithCheck(smu, ':SENS1:FUNC "CURR"');
    sendCommandWithCheck(smu, [':SENS1:CURR:NPLC ', num2str(NPLC)]);
    sendCommandWithCheck(smu, [':SENS1:CURR:PROT ', num2str(DS_comp)]);

    sendCommandWithCheck(smu, ':TRIG1:SOUR AINT');
    sendCommandWithCheck(smu, [':TRIG1:COUN ', num2str(numel(fixed_voltages))]);




    % Channel 2 config
    sendCommandWithCheck(smu, ':SOUR2:FUNC:MODE VOLT');
    sendCommandWithCheck(smu, ':SOUR2:VOLT:MODE LIST');
    sendCommandWithCheck(smu, [':SOUR2:LIST:VOLT ', ch2_voltListStr]);
    sendCommandWithCheck(smu, ':SENS2:FUNC "CURR"');
    sendCommandWithCheck(smu, [':SENS2:CURR:NPLC ', num2str(NPLC)]);
    sendCommandWithCheck(smu, [':SENS2:CURR:PROT ', num2str(GS_comp)]);

    sendCommandWithCheck(smu, ':TRIG2:SOUR AINT');
    sendCommandWithCheck(smu, [':TRIG2:COUN ', num2str(numel(sweep_voltages))]);




    sendCommandWithCheck(smu, ':TRAC:CLE');
    sendCommandWithCheck(smu, ':OUTP1 ON');
    sendCommandWithCheck(smu, ':OUTP2 ON');

    pause(min(0.5, 0.01 * numel(sweep_voltages)));  % settle time
    


    sendCommandWithCheck(smu, ':INIT (@1,2)');
    sendCommandWithCheck(smu, '*WAI');

     sendCommandWithCheck(smu, ':OUTP1 OFF');
     sendCommandWithCheck(smu, ':OUTP2 OFF');
     

if fixed_channel == 1
    rawI1 = query(smu, ':FETC:ARR:CURR? (@1)');
    rawI2 = query(smu, ':FETC:ARR:CURR? (@2)');
    rawV1 = query(smu, ':FETC:ARR:VOLT? (@1)');
    rawV2 = query(smu, ':FETC:ARR:VOLT? (@2)');
    raw_stat = query(smu, ':FETC:ARR:VOLT? (@2)');


    

    I1 = str2num(rawI1);
    I2 = str2num(rawI2);
    V1 = str2num(rawV1);  % actual measured Vds
    V2 = str2num(rawV2);  % actual measured Vgs
    stat = str2num(raw_stat);

    if any(I1 >0.9*  DS_comp)
        disp('Compliance at channel 1 was hit!');
    end
    if any(I2 > 0.9* GS_comp)
        disp('Compliance at channel 2 was hit!');
    end


    
    % these are the EXPECTED arrays. Previously i only used these ones, not
    % the measured ones. Why? Cause I'm an idiot, that's why. Sorry guys.
    V1_expected = fixed_voltages(:);
    V2_expected = sweep_voltages(:);

else
    rawI1 = query(smu, ':FETC:ARR:CURR? (@2)');
    rawI2 = query(smu, ':FETC:ARR:CURR? (@1)');
    rawV1 = query(smu, ':FETC:ARR:VOLT? (@2)');
    rawV2 = query(smu, ':FETC:ARR:VOLT? (@1)');

    I1 = str2num(rawI1);
    I2 = str2num(rawI2);
    V1 = str2num(rawV1);  % actual measured Vds
    V2 = str2num(rawV2);  % actual measured Vgs
    % these are the EXPECTED arrays. Previously i only used these ones, not
    % the measured ones. Why? Cause I'm an idiot, that's why. Sorry guys.
    V1_expected = fixed_voltages(:);
    V2_expected = sweep_voltages(:);
end


    t2 = toc(t1);
    t = linspace(0, t2, numel(V2))';

    % Map x_var and y_var to the corresponding data arrays
    switch x_var
        case 'Vgs', x_data = V2; x_label = 'Vgs (V)';
        case 'Igs', x_data = I2; x_label = 'Igs (A)';
        case 'Vds', x_data = V1; x_label = 'Vds (V)';
        case 'Ids', x_data = I1; x_label = 'Ids (A)';
        case 't',   x_data = t;  x_label = 'Time (s)';
        otherwise, error('Invalid x_var.');
    end

    switch y_var
        case 'Vgs', y_data = V2; y_label = 'Vgs (V)';
        case 'Igs', y_data = I2; y_label = 'Igs (A)';
        case 'Vds', y_data = V1; y_label = 'Vds (V)';
        case 'Ids', y_data = I1; y_label = 'Ids (A)';
        case 't',   y_data = t;  y_label = 'Time (s)';
        otherwise, error('Invalid y_var.');
    end

catch ME
    fprintf('Error: %s\n', ME.message);
    disp(getReport(ME, 'extended'));
    rethrow(ME);
end
toc
end
