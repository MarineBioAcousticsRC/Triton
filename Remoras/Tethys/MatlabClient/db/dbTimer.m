
classdef dbTimer < handle
    properties 
        start
    end
    
    methods

        function t = dbTimer()
            t.start = datetime();
        end

        function interval = elapsed(t)
            interval = datetime() - t.start;
            interval.Format = 'hh:mm:ss.SSS';
        end
        
    end
end
        
     
