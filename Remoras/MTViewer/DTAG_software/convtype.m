function    [x,ss] = convtype(x,field,silent)
%
%     [x,ss] = convtype(x,field,silent)
%     Convert between string and numerical formats for various variable types
%     x can be a string, number, vector or cell array of these.
%     field must be a string with the type name or a structure containing a
%     type element (the structure can optionally also contain min, max and format
%     elements.
%

if nargin<2,
   help convtype
   return
end

if nargin<3 | isempty(silent),
   silent = 0 ;
end

if ~isstruct(field),
   type = field ;
   field = [] ;
else
   type = field.type ;
end

switch type
   case {'string','menu'}
      [x,ss] = convstring(x,field,silent) ;
   case 'number'
      [x,ss] = convnumber(x,field,silent) ;
   case 'heading'
      f.format = '%3.1f' ;
      f.min = 0 ;
      f.max = 360 ;
      [x,ss] = convnumber(x,f,silent) ;
   case 'latitude'
      if isfield(field,'format'),
         [x,ss] = convlatlong(x,'lat',field.format,silent) ;
      else
         [x,ss] = convlatlong(x,'lat',[],silent) ;
      end
   case 'longitude'
      if isfield(field,'format'),
         [x,ss] = convlatlong(x,'long',field.format,silent) ;
      else
         [x,ss] = convlatlong(x,'long',[],silent) ;
      end
   case 'date'
      [x,ss] = convdate(x,silent) ;
   case 'time'
      [x,ss] = convtime(x,silent) ;
   case 'button'
      [x,ss] = convbutton(x) ;
   otherwise
      if silent~=1,
         logtoolerror(sprintf('Unknown type %s',type)) ;
      end
end
