function table = load_table(file_name)
%LOAD_TABLE Loads the excel table

table = readtable(file_name, VariableNamingRule="preserve");
end

