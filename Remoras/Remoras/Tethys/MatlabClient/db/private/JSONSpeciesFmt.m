function map = JSONSpeciesFmt(queryEng, varargin)
% map = JSONSpeciesInputFmt(queryEng, io...)
% io - "GetInput", "GetOutput" (both may be present)
% Construct a map (hashtable) specifying how to translate 
% species names (e.g., Latin to TSN) for Javascript object
% notation (JSON) queries.  The mapping is based on the current
% settings of dbSpeciesFmt



map = containers.Map();
for io_idx = 1:length(varargin)
    io = varargin{io_idx};  % Remove cell wrapper
    switch io
        case "GetInput"
            key = "query";
        case "GetOutput"
            key = "return";
    end
    fmt = dbSpeciesFmt(queryEng, io);
    if ~ isstring(fmt)
        fmt = string(fmt);
    end
    
    if fmt.contains("%f")
        map = [];
    else
        % Build the input/output specification
        
        % Parse the function
        m = regexp(fmt, "(?<fn>[^\(]+)\((?<args>[^\)]+)\)", "names");
        if isempty(m)
            error("Unable to parse dbSpeciesFmt(q, %s) result: %s", io, fmt);
        end
        % Create the hashtable/map/dict
        iomap = containers.Map();
        iomap("optype") = "function";
        iomap("op") = m.fn;
        operands = m.args.split(",");
        % Remove extraneous spaces and quotes
        operands = arrayfun(@(x) x.strip(), operands);
        operands = arrayfun(@(x) x.replace('"', ''), operands);
        iomap("operands") = operands;
        map(key) = iomap;
    end
end

if map.length == 0
    map = [];  % nothing constructed
end





