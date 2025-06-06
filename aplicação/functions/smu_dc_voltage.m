function smu_dc_voltage(smu, channel, voltage)
%SMU_DC_VOLTAGE Change channel voltage

if channel ==1
    fprintf(smu, [':sour1:volt ' num2str(voltage)]);
elseif channel ==2
    fprintf(smu, [':sour2:volt ' num2str(voltage)]);
end
end

