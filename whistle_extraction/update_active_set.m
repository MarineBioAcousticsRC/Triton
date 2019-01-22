function update_active_set(active_set, tonal_set, time_s, thr)
% update_active_set(active_set, tonal_set, time_s, thr)
% Given linked list object handles representing the set of active nodes and
% the current set of tonals, dispose of any active chains that are too old
% and short and old relative to the current time in seconds and the 
% thresholds defined in the threshold structure thr.
% 

if ~ active_set.isempty()
    % Not using iterator as very slow
    a_node = active_set.nodes;
    more = true;
    while more
        tf = a_node.value;  % get time-freq node
        % Check for successors before we modify the list
        more = ~ active_set.nodes.eq(a_node.next);
        if tf.chained
            % This node has been linked to by one or more nodes
            % Remove it from the list of possible nodes.
            % This might not be the right thing to do, but we'll
            % try it for now.
            a_node = active_set.unlink(a_node);
        else
            if time_s - tf.time > thr.maxgap_s
                % Should no longer be on the active list
                a_node = active_set.unlink(a_node);

                % Check if it is long enough to save and not part of
                % someone else's chain
                if tf.longest_s >= thr.minlen_s
                    % nobody else points to this and it is long
                    % enough, new whistle!
                    tonal_set.append(tf);
                else
                    % not sure if we need to delete the old chain
                    % of if it will be garbage collected.
                    % read more about handle classes in
                    % Matlab documentation.  Looks like we
                    % probably do not need to, see discussion in
                    % Handle Base Class in Matlab doc.
                    % In any case, we don't want to consider this
                    % node any more.
                end
            else
                % should still be on active list, move on...
                a_node = a_node.next;
            end
        end
    end
end
