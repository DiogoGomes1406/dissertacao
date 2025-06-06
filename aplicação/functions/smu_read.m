function [I,V] = smu_read(smu,channel)
%SMU_READ Reads channel voltage

if channel==1
    % Measure the current
    fprintf(smu, ':MEAS:CURR? (@1)');
    I = fscanf(smu, '%f');

    % Measure the voltage
    fprintf(smu, ':MEAS:VOLT? (@1)');
    V = fscanf(smu, '%f');

elseif channel==2
    % Measure the current
    fprintf(smu, ':MEAS:CURR? (@2)');
    I = fscanf(smu, '%f');

    % Measure the voltage
    fprintf(smu, ':MEAS:VOLT? (@2)');
    V = fscanf(smu, '%f');
end

end
