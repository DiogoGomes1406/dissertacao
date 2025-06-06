function log_message(textArea, message)
    % Get the current time as a formatted string
    timestamp = string(datetime("now")).extractAfter(12);
    
    % Append message with timestamp to the text area
    textArea.Value = [textArea.Value; timestamp + "  -  " + message];
    
    % Scroll to the bottom
    scroll(textArea, 'bottom');
end
