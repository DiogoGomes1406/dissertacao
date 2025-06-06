function smu_dc_voltage2(smu, channel, voltage, currProt)
    % smu_dc_voltage2: Set a channel to DC voltage mode, apply voltage, and set compliance
    %
    % Usage:
    %   smu_dc_voltage2(smu, channel, voltage, currProt)
    %
    % Inputs:
    %   - smu: VISA or SCPI instrument object
    %   - channel: integer channel number (e.g., 1 or 2)
    %   - voltage: desired DC voltage (in volts)
    %   - currProt: desired current compliance (in amperes)

    % Ensure output is in DC voltage (fixed) mode
    fprintf(smu, [':SOUR', num2str(channel), ':FUNC:MODE VOLT']);
    fprintf(smu, [':SOUR', num2str(channel), ':VOLT:MODE FIX']);

    % Set the actual voltage value
    fprintf(smu, [':SOUR', num2str(channel), ':VOLT ', num2str(voltage)]);

    % Apply user-specified current protection (compliance)
    fprintf(smu, [':SENS', num2str(channel), ':CURR:PROT ', num2str(currProt)]);

    % Configure to measure current on this channel
    fprintf(smu, [':SENS', num2str(channel), ':FUNC "CURR"']);

    % Query system error to verify successful configuration
    fprintf(smu, ':SYSTEM:ERROR?');
    err = readline(smu);
    if ~contains(err, '0,"No error"')
        warning('Error setting DC voltage (Ch %d = %.3f V, Prot=%.3g A): %s', channel, voltage, currProt, err);
    end
end
