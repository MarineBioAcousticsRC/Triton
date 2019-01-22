function dtDumpPredChains(node, level)
% dtDumpPredChains(node)
% Given a tfnode, plot all of its predecessors

if nargin < 2
    level = 0;
end

fprintf('%s ', char(node));
% Handle back chains in a depth first manner
it = node.predecessors().iterator();
first = true;
while it.hasNext()
    node = it.next();
    if first
        first = false;
    else
        fprintf('\n');
        for k=1:level
            fprintf('  ');
        end
    end
    dtDumpPredChains(node, level+1);
end

                