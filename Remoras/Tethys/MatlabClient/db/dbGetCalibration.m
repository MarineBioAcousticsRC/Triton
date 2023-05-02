classdef dbGetCalibration < handle
    properties
        calibration
        calibration_idx
        interp_method = 'linear';
    end
    
    methods
        function obj = dbGetCalibration(queryH, varargin)
            % calibration = dbGetCalibarion(queryEngine, Optional Args)
            % Retrieve a calibration object.  
            %
            % queryEngine must be a Tethys database query object.  See
            % dbInit() for details, or dbDemo for an example.
            %
            % Optional Args
            % Set of keyword value pairs.  The keywords are names that
            % describe the calibration.  A complete list of calibration
            % elmeents can be found by executing:
            %     dbOpenSchemaDescription(queryEngine, 'Calibration')
            %
            % The name most likely to be of use is Id as it matches
            % an equipment identifier.  Other useful names include but
            % are not limited to:
            % 'TimeStamp' - ISO 8601 timestamp describing calibration date
            %   and time, e.g. 2005-04-19T00:00:00Z
            % 'Type' - hydrophone, preamplifier, or end-to-end
            %
            % Ideally, one provides enough details to specify a single
            % calibration.  If multiple calibrations are retrieved,
            % a warning is issued and the first is used by default
            % although one can specify others by index.
            %
            % See the other dbGet functions (e.g., dbGetDetections) for
            % details on how to specify additional search criteria such
            % as relative operators (<, >, etc.)


            assert(dbVerifyQueryHandler(queryH), ...
                "First argument must be a query handler produced by dbInit()");

            varargin{end+1} = "return";
            varargin{end+1} = "Calibration";


            map = containers.Map();
            map('enclose') = 1;  % Wrap elements around sets of loop values
            map('namespaces') = 0;  % Strip namespaces from results

            err = dbParseOptions(queryH, "Calibration", ...
                map, "calibrations", varargin{:});
            if ~ isempty(err)
                dbParseUnrecoverableErrorCheck(err);
                dbParseUnmatchedErrors(err);
            end

            json = jsonencode(map);
            xmlstr = queryH.QueryJSON(json, 0);

            typemap = {
                'TimeStamp', 'datetime'; 
                'IntensityReference_uPa', 'double';
                'Sensitivity_dbV', 'double';
                'Sensitivity_V', 'dobule';
                'Sensitivity_dBFS', 'double';
                'Hz', 'double';
                'dB', 'double'
                };

            result = tinyxml2_tethys('parse', char(xmlstr), typemap);

            if ~isstruct(result)
                error("No such calibration found");
            end

            % Convert timestamps 
            for idx = 1:length(result.Return)
                result.Return(idx).Calibration.TimeStamp{1} = ...
                    datetime(result.Return(idx).Calibration.TimeStamp{1}, ...
                    'ConvertFrom', 'datenum');
            end

            obj.calibration = result.Return;

            if length(obj.calibration) > 1
                warning("Query matched multiple calibrations")
            end
        end

        function check_calibration_index(obj, idx)
            % check_calibration_index(idx) 
            % Verify specified calibration index is valid.
            assert(idx >=1 && idx <= length(obj.calibration), ...
                sprintf("Calibration idx must be 1 <= idx <= %d", ...
                length(obj.calibration)));
        end


        function c = getCalibration(obj, idx)
            % c = getCalibration(calibration_idx)
            % Retrieve the idx'th calibration.  If idx is omitted
            % the first (and perhaps only) calibration is retrieved.

            if nargin < 2, idx = 1; end
            obj.check_calibration_index(idx);

            c = obj.calibration(idx).Calibration;

        end
        

        function method = getInterpMethod(obj)
            % method = getInterpMethod(obj)
            % Retrieve the current interpoloation method

            method = obj.interp_method;
        end

        function setInterpMethod(obj, method)
            % setInterpMethod(obj, method)
            % Set the interpolation method 
            % Any string supported by interp1 is permitted,
            % See doc('interp1') for details.
            obj.interp_method = method;
        end

        function dB = getFreqResponse(obj, Hz, idx)
            % dB = getFreqResponse(Hz, calibration_idx)
            % Retrieve the frequency response for the designated
            % frequencies.  The frequency calibrated frquency response is 
            % interpolated to the specified frequencies Hz.
            % Extrapolation is allowed but highly discouraged.
            %
            % If more than one calibration was retrieved, calibration_idx
            % may be used to specify the calibration to be used.

            if nargin < 3, idx = 1; end
            obj.check_calibration_index(idx);

            c_Hz = obj.calibration(idx).Calibration.FrequencyResponse.Hz{1};
            c_dB = obj.calibration(idx).Calibration.FrequencyResponse.dB{1};

            dB = interp1(c_Hz, c_dB, Hz, obj.interp_method, 'extrap');
        end

    end

end

