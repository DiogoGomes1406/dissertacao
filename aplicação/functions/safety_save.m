function  safety_save(path, File_name,Curve_id,...
    DS_comp, GS_comp, Vgs_min, Vgs_max, ...
    vDS, N_points, Dwell_time, Dwell_voltage,N_cycles, Ids, Vds, Igs, Vgs, t)
%safety_save Creates a safe save, an automatic save after aquiring each curve

% see if file already exists
if isfile(fullfile(path, File_name + ".mat")) 
    file = load(fullfile(path, File_name + ".mat"));
    data = file.data;
    disp(data)
    data(end+1,:) = {{Curve_id},DS_comp, GS_comp, Vgs_min, Vgs_max,N_cycles, vDS, N_points, Dwell_time,Dwell_voltage, ...
        {Ids}, {Vds}, {Igs}, {Vgs}, {t}};

    save (path+ "\"+ File_name + ".mat","data")
    save_json(path+ "\"+ File_name, data)  %saves json file
    
else
    data = table({Curve_id}, DS_comp, GS_comp, Vgs_min, Vgs_max,N_cycles, vDS, N_points, Dwell_time,Dwell_voltage, ...
         {Ids}, {Vds}, {Igs}, {Vgs}, {t}, ...
        'VariableNames', {'Curve_id','DS_comp', 'GS_comp', 'Vgs_min', 'Vgs_max','N_cycles', ...
        'vDS', 'N_points', 'Dwell_time', 'Dwell_voltage', 'Ids', 'Vds', ...
        'Igs', 'Vgs', 't'});

    save (path+ "\"+ File_name + ".mat","data")
    save_json(path+ "\"+ File_name, data)  %saves json file
end

end