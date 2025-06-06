function smu_dc_params(smu, channel, comp, apperture)
% SMU_DC_PROP Change channel properties

fprintf(smu, [':SENS:CURR:APER ', num2str(apperture)]);
fprintf(smu, [':SENS:VOLT:APER ', num2str(apperture)]);

if channel==1
    % Set channel in voltage mode
    fprintf(smu, ':sour1:func:mode volt');

    % Set channel current compliance
    fprintf(smu, ':sens1:func "curr"');
    fprintf(smu, [':sens1:curr:prot ' num2str(comp)]);

elseif channel ==2
    % Set channel in voltage mode
    fprintf(smu, ':sour2:func:mode volt');

    % Set channel current compliance
    fprintf(smu, ':sens2:func "curr"');
    fprintf(smu, [':sens2:curr:prot ' num2str(comp)]);
end
end
