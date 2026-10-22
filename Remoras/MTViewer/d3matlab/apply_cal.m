function    X = apply_cal(X,CAL,p,t)
%
%    X = apply_cal(X,C,p,t)
%

if isfield(CAL,'POS'),  % check if this is bridge sense data
   % if so, there should be two columns in X
   X = polyval(CAL.POS.POLY,X(:,1))-polyval(CAL.NEG.POLY,X(:,2)) ;
   X(:,2) = polyval(CAL.TEMPR.POLY,X) ;
end

if isfield(CAL,'USE') && ischar(CAL.USE),
   eval(['X=' CAL.USE '(X,CAL);']) ;
   return
end

if isfield(CAL,'POLY'),
   for k=1:size(X,2),
      X(:,k) = polyval(CAL.POLY(k,:),X(:,k)) ;
   end
end

if isfield(CAL,'PC') && nargin>=3 && ~isempty(p),
   if isstruct(CAL.PC),
      for k=1:size(X,2),
         X(:,k) = X(:,k)+polyval(CAL.PC.POLY(k,:),p) ;
      end
   else
      for k=1:size(X,2),
         X(:,k) = X(:,k)+polyval(CAL.PC(k,:),p) ;
      end
   end
end

if isfield(CAL,'TC') && nargin>=4 && ~isempty(t),
   if length(t)<size(X,1),
      t(end+1:size(X,1)) = t(end) ;
   end

   for k=1:size(X,2),
      X(:,k) = X(:,k)+polyval(CAL.TC.POLY(k,:),t-CAL.TREF) ;
   end
end

if isfield(CAL,'XC'),
   X = X*(eye(size(X,2))+CAL.XC) ;
end

if isfield(CAL,'MAP'),
   X = X*CAL.MAP ;
end
