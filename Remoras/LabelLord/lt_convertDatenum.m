function times = lt_convertDatenum(datenums,type);

DVs = datevec(datenums);

if contains(type,'hours')
    times = DVs(:,4) + DVs(:,5)./60 + DVs(:,6)./3600;

elseif contains(type,'minutes')
    times = DVs(:,4)*60 + DVs(:,5) + DVs(:,6)./60;

elseif contains(type,'seconds')
    times = DVs(:,4)*3600 + DVs(:,5)*60 + DVs(:,6);
    
else
    error('ERROR: Type used not acceptable format. Use hours, minutes, or seconds.')
end 