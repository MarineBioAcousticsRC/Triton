function ndetections = dbNormDiel(detections, night, UTCoffset)
% Given a set of detections and diel informaiton specifying night time,
% renormalize detections to represent a 12 hour day/night period by
% linear interpolation.
%
% Assumptions:
% Both detections and night are sorted by timestamp and 
%   converted to local time (or in UTC with a provided UTCoffset)
%   so that night fall is after sunrise each day.
% There are no detections outside of the night intervals except for
%   the day before and after the first and last night respectively.

if nargin < 3
    UTCoffset = 0;
end

if UTCoffset
    offset = datenum(0, 0, 0, UTCoffset, 0, 0);
    detections = detections + offset;
    night = night + offset;
end

day = datenum(0,0,1);
h12 = day/2;  % 12 hours
midnight = @(t) fix(t / day);

% Normalized sunset and sunrise at 05:30 to 05:30
sunriseStd = datenum(0, 0, 0, 5, 30, 0);
sunsetStd = datenum(0, 0, 0, 17, 30, 0);



ndetections = zeros(size(detections));
n_idx = 1;  % index into night array
set = night(n_idx,1);
rise_next = night(n_idx, 2);
% First day may occur before the first reported nightfall.
% Assume that it occurs on the same day
rise = night(n_idx, 2)-day;

lastnight = false;
% process each detection
for d_idx = 1:size(detections, 1)
    for k=1:size(detections, 2)
        event = detections(d_idx, k);
        if event < rise  && n_idx == 1
            % No diel information for this date
            error('%s earlier than %s', ...
                datestr(event), datestr(rise));
        end
        done = false;
        while ~ done

            if lastnight && event > set
                % Past sunset on last day for which we have diel
                error('%s later than %s', datestr(event), ...
                    datestr(set))
            end
            
            if event >= rise && event < set
                % day time, convert to normalized day
                offset = h12 * ...
                    (event - rise) / (set - rise);
                nevent = midnight(rise) + sunriseStd + offset;
                fprintf('(%s < %s < %s) --> %s\n', ...
                    datestr(rise), datestr(event), datestr(set), datestr(nevent));
                done = true;
            elseif event >= set && event < rise_next
                % convert to normalized night
                offset = h12* ...
                    (event - set) / (rise_next - set);
                nevent = midnight(set) + sunsetStd + offset;
                fprintf('(%s < %s < %s) --> %s\n', ...
                    datestr(set), datestr(event), datestr(rise_next), datestr(nevent));
                done = true;
            else
                % set up for next day
                n_idx = n_idx + 1;
                lastnight = n_idx > size(night, 1);
                if lastnight
                    % use last sunset as proxy for next one
                    set = night(end, 1) + day;
                else
                    set = night(n_idx, 1);
                    rise = rise_next;
                    rise_next = night(n_idx, 2);
                end
            end
        end
        ndetections(d_idx, k) = nevent;
    end
end