function b = little2big_2byte(a)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% little2big_2byte.m
%
% function reads N x 2 array (a) and converts the 2 values from each row 
% from little endian format to big endian format - array (b)
% 
% Parameters: 
%       a - the n x 2 array that will be converted to big endian format
%
% Return:
%       b - the big endian version of the array passed in
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
flag = 0;

if isempty(a)
    disp('Error - useage: >> b = little2big_2byte(a)')
    return
end

[r,c] = size(a);

if c ~= 2 && r ~= 2
    disp('Error - need 2 elements')
    return
elseif c ~=2 && r == 2
    flag = 1;
    a = a';
end

b = a(:,2) + 2^8 * a(:,1);

if flag
    b = b';
end
