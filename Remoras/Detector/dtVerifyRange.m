function Value = dtVerifyRange(Label, Low, High, Value, Default, Handle)
% Value = dtVerifyRange(Label, Low, High, Value, Default)
% Verify that Value is in the closed interval [Low, High].
% If it is not, write a message prefixed by Label
% and set to the provided default value.
% When the optional Handle is included, it is assumed that the handle
% refers to a text widget and the value will be updated if it is changed
% from the user's entry

% value in range?
if isempty(Value) || Value < Low || Value > High
  % print warning and set to default
  disp_msg(sprintf('%s: %.3f outside [%.3f,%.3f], setting to %.3f', ...
                   Label, Value, Low, High, Default));
  Value = Default;
  
  % update text box if handle provided
  if nargin >= 5
    set(Handle, 'String', Value)
  end
end
