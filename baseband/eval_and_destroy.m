function [result] = eval_and_destroy(command, workspace_struct )
%eval_and_destroy Evaluates the given function within the given function's
%workspace (scope) while inheriting varibales from the base workspace.  
%Any variable changes should be discarded when the function returns.
%workplace_struct is optional; if not included no new variables are set.

%Get vars from base workspace
set_base_vars();

if(nargin > 1)
    set_vars(workspace_struct);
end

result = evaluate_command(command);

end

function set_base_vars()
    base_vars = evalin('base', 'who');
    
    for i = 1:1:length(base_vars)
       value = evalin('base', base_vars{i});
       assignin('caller', base_vars{i}, value);
    end
end


function set_vars(vars)
for i = 1:1:length(vars)
    assignin('caller', vars(i).Name, vars(i).Value);
end
end

function result = evaluate_command(command)
    result = evalin('caller', command);
end