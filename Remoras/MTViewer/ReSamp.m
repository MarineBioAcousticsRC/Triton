function [fastout] = ReSamp(fast,slow)

ls = length(slow);
fastout = zeros(ls,4);
% Down-sample the faster time series
fastout(:,2) = interp1(fast(:,1), fast(:,2), slow(:,1), 'spline');
fastout(:,3) = interp1(fast(:,1), fast(:,3), slow(:,1), 'spline');
fastout(:,4) = interp1(fast(:,1), fast(:,4), slow(:,1), 'spline');
fastout(:,1) = slow(:,1);

% Optional: Plotting for comparison with original names
% figure;
% plot(fast(:,1), fast(:,2), '-o');
% hold on
% plot(fastout(:,1),fastout(:,2), '-x');
% xlabel('Time');
% ylabel('Value');


end