function [WindowedSignal] = spWindow(Signal, Method);
% [WindowedSignal] = spWindow(Signal, Method)
%	Applies a windowing function to Signal.  Signal can
%	contain either a column vector or a matrix.  If Signal
%	contains a matrix, the windowing function is applied
%	to each column.  This is useful for framed data.
%
%	Method is the window function to apply:
%	
%	'none' - no windowing
%	'hamming'
%	'hanning'
%
%       Method may also be a column vector which is the result of
%       a custom window function.
%
% This code is copyrighted 1997-2004 by Marie Roch.
% e-mail:  marie.roch@ieee.org
%
% Permission is granted to use this code for non-commercial research
% purposes.  Use of this code, or programs derived from this code for
% commercial purposes without the consent of the author is strictly
% prohibited. 

error(nargchk(1, 2, nargin));

if nargin < 2
  Method = 'hamming';
end

WindowLength=size(Signal, 1);

if ischar(Method)
  switch Method
   case 'none'
    
   case 'hamming'
    WindowFn = hamming(WindowLength);
    
   case 'hanning'
    WindowFn = hanning(WindowLength);
    
   otherwise
    error(sprintf('Bad window function "%s"', Method));
  end
else
  WindowFn = Method;
  Method = 'custom';
  if size(WindowFn, 2) ~= 1
    error('Custom window must be a column vector');
  end
end

if ~ strcmp(Method, 'none')
  % preallocate matrix
  WindowedSignal = zeros(size(Signal));
  
  % Apply window function to each frame
  for i = 1:size(Signal,2)
    WindowedSignal(:,i) = Signal(:,i) .* WindowFn;
  end
else
  % no windowing
  WindowedSignal = Signal;
end
