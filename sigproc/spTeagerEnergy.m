function Energy = spTeagerEnergy(signal)
% Energy = spTeagerEnergy(signal)
% Compute the Teager/Kaiser energy of the given signal
% Returns the per sample energy for all samples except the first & last
%
% signal may either be a column vector or a matrix whose columns are
% signals.  The first and last columns of the energy signal are not
% defined.


Energy = zeros(size(signal));

[rows, cols] = size(signal);
if rows <= 1
    error('signal must be 1 or more column vectors')
end
Energy(2:rows-1, :) = signal(2:rows-1,:).^2 - ...
    signal(1:rows-2,:) .* signal(3:end,:);




