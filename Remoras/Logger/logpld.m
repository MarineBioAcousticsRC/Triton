function logpld(action)
global PARAMS

if strcmp(action, 'low')
    PARAMS.numfreq = 2; 
elseif strcmp(action, 'mid')
    PARAMS.numfreq = 3; 
elseif strcmp(action, 'high')   
    PARAMS.numfreq = 4; 
end

initLogctrl