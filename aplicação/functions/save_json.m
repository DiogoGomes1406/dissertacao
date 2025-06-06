function  save_json(save_name, data)
%save_json saves data in json format

jsonData = jsonencode(data);
fid = fopen(save_name+".json","w");
fwrite(fid, jsonData,"char");
fclose(fid);
end

