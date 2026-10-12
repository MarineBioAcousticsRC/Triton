function    X = sensor_subset(X,t)
%
%    X = sensor_subset(X,t)
%

fs = X.fs ;
for k=1:length(X.x),
   x = X.x{k} ;
   X.x{k} = x(round(fs(k)*t(1))+1:round(fs(k)*t(2))) ;
end

