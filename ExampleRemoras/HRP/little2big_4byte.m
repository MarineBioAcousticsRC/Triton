function b = little2big_4byte(a)
%
% useage: >> b = little2big_4byte(a)
%
% function reads N x 4 array (a) and converts the 4 values from each row 
% from little endian format to big endian format - array (b)
%
% 050916 smw
%
flag = 0;

if isempty(a)
    disp('Error - useage: >> b = little2big_4byte(a)')
    return
end

[r,c] = size(a);

if c ~= 4 && r ~= 4
    disp('Error - need 4 elements')
    return
elseif c ~=4 && r == 4
    flag = 1;
    a = a';
end

b = a(:,4) + 2^8 * a(:,3) + 2^16 * a(:,2) + 2^24 * a(:,1);

if flag
    b = b';
end
