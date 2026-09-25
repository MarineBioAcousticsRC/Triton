function h = tr_hash(x)
%TR_HASH  Stable MD5 of a numeric array or string, as a lowercase hex string.
%
%   h = tr_hash(x)
%
% Used by triton_baseline to fingerprint large outputs (audio segments,
% spectrograms, LTSA power) without storing them. Two runs that produce the
% same hash produced identical bytes; a changed hash means something moved.
%
% Numeric input is compared as double, so an int16 array and the same values
% as double hash alike -- which is what we want, since readseg returns double
% regardless of the file's bit depth.
%
% Empty input hashes to the string 'empty' rather than a digest, so an empty
% result is obvious in a diff instead of looking like an arbitrary value.

if isempty(x)
    h = 'empty';
    return
end

if ischar(x)
    bytes = uint8(x);
elseif islogical(x)
    bytes = typecast(double(x(:)), 'uint8');
else
    bytes = typecast(double(x(:)), 'uint8');
end

md = java.security.MessageDigest.getInstance('MD5');
md.update(bytes);
digest = typecast(md.digest(), 'uint8');          % java returns int8
h = lower(reshape(dec2hex(digest, 2).', 1, []));
end
