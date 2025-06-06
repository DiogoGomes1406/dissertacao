function updated_hard_data= delete_curves(axis, hard_data, curve_id_table)
%delete_curves Deletes hidden curves from an axis

children = axis.Children;

% get the curves that are invisible
invisible_curves = {};
visible_curves = {};
for i =1:numel(children)
    visibility = children(i).Visible;
    if visibility==0
        invisible_curves{end+1} = children(i).DisplayName;
        delete(children(i));
    else
        visible_curves{end+1} = children(i).DisplayName;
    end
end

curve_labels = string(hard_data.Curve_id); %string of the curve labels
rows_to_keep = ~ismember(curve_labels, invisible_curves);

updated_hard_data = hard_data(rows_to_keep,:);

rows_to_delete = [];  % Store indices of rows to delete

for i = 1:height(curve_id_table.Data)
    for j = 1:length(invisible_curves)
        if strcmp(curve_id_table.Data{i, 1}, invisible_curves{j})  % Compare row with invisible_curves
            rows_to_delete(end+1) = i;  % Mark row for deletion
        end
    end
end

                for row = rows_to_delete
                    blackStyle = uistyle('FontColor', [0 0 0]);
                    addStyle(curve_id_table, blackStyle, 'cell', [row, 1]);
                end

                % Delete rows safely
                if ~isempty(rows_to_delete)
                    curve_id_table.Data(rows_to_delete, :) = [];
                end

end

