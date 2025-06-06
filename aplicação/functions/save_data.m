function  save_data(axis, hard_data, save_name)
%save_data Saves VISIBLE data on an axis.

% get curves of the axis
children = axis.Children;

% get the curves that are invisible
invisible_curves = {};
for i =1:numel(children)
    visibility = children(i).Visible;
    if visibility==0
        name = children(i).DisplayName;
        invisible_curves{end+1} = name;
    end
end

curve_labels = string(hard_data.Curve_id); %strinf of the curve labels
rows_to_keep = ~ismember(curve_labels, invisible_curves);

data = hard_data(rows_to_keep,:);

save(save_name, "data") %saves m file

save_json(save_name, data)  %saves json file



end

