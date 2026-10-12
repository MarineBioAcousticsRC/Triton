function   y = interp2length(x,fsin,fsout,nout)
%
%   y = interp2length(x,fsin,fsout,nout)
%

if fsin==fsout,     % if sampling rates are the same, no need to interpolate,
                    % just make sure the length is right
   y = x ;
   if size(y,1)<nout,
      y(end+1:nout,:) = y(end,:) ;
   elseif size(y,1)>nout,
      y = y(1:nout,:) ;
   end
   return
end

intf = fsout/fsin ;
if intf == round(intf), % if the sampling rate ratio is an integer,
                        % use integer-ratio interpolation
   y = zeros(intf*size(x,1),size(x,2)) ;
   for k=1:size(x,2),
      y(:,k) = interp(x(:,k),intf) ;
   end
   if size(y,1)<nout,       % make sure the resulting size is right
      y(end+1:nout,:) = repmat(y(end,:),nout-size(y,1),1) ;
   elseif size(y,1)>nout,
      y = y(1:nout,:) ;
   end
else                    % if interpolation factor is not an integer,
                        % use linear interpolation
   y = interp1((0:size(x,1)-1)'*(1/fsin),x,(0:nout-1)'*(1/fsout)) ;
end
