function Segments = spEndpointCMU2(Signal, SampleRate, Channel)
% Segments = spEndpointCMU(Signal, SampleRate, Channel)
% Endpoint the given signal using the CMU endpointer.
% The 10 ms advance frame indices of the segments containing speech are
% returned in Segments.
%
% It is assumed that Signal is a 1 or 2 channel signal.
%
% A temporary file containing the raw signal is created and an external
% endpointer is invoked on the temporary file.  After processing, the
% file is removed. 

ChannelCount = size(Signal, 2);
RawFile = ['/tmp/', getenv('USER'), '.raw'];

if ChannelCount > 1
  % If multiple channels, merge.  CMU endpointer doesn't
  % deal well with residual from acoustic echo cacneller.
  % We'll endpoint both channels combined and then determine
  % what belongs to the target channel.
  spWritePcm16(RawFile, sum(Signal, 2));
else
  spWritePcm16(RawFile, Signal);
end

% Utility to extract feature information and run segmenter
EPUTIL='/zal/mroch/speech/cmu/segmenter/endpoint';

% do it!
[ResultCode, Results] = system(sprintf('%s %s', EPUTIL, RawFile));

if ResultCode ~= 0
  error(sprintf('endpointer failure, return code =%d\nOutput = %s', ...
		 ResultCode, Results));
end

% Process results
Segments = sscanf(Results, '%d');
SegmentCount = length(Segments)/2;

if (SegmentCount ~= floor(SegmentCount))
  error('endpointer failed to return appropriate frames');
end

Segments = reshape(Segments, 2, SegmentCount)';
Segments = Segments + 1;	% C 0->N-1, Matlab 1->N

if ChannelCount > 1
  % Multiple channel case
  
  FrameAdvanceMS = 10;	% CMU defaults
  FrameLengthMS = 25;
  
  ChannelEnergySmoothed = [];
  for c = 1:ChannelCount
    tmp = spEnergyLevels(int16(Signal(:,c)), SampleRate, FrameAdvanceMS, ...
				FrameLengthMS);
    ChannelEnergy = tmp.FrameEnergy;
%    ChannelEnergy = spEnergy(Signal(:, c), SampleRate, ...
%			     FrameAdvanceMS, FrameLengthMS);


    ChannelEnergySmoothed = [ChannelEnergySmoothed; ...
		    spNLFilter(ChannelEnergy, 'Median', 5)'];
  end

  [Dummy, ChannelMax] = max(ChannelEnergySmoothed);

  % Get rid of hiccups in categorization (high freq changes)
  ChannelMax = spCatSmooth(ChannelMax, 5);
  
  [Starts, Labels, Lengths] = spRunLengthAnalysis(ChannelMax);
  Ends = Starts + Lengths - 1;
  TargetRuns = find(Labels == Channel);	% select those we're interested in
  
  NewSegments = [];
  TargetIdx = 1;
  TargetCount = length(TargetRuns);
  SegmentCount = size(Segments, 1);
  SegmentIdx = TargetRuns(TargetIdx);
  for idx = 1:SegmentCount;
    
    done = 0;
    while (~ done)
      % Check for intersection 
      % An intersection occurs if the end of the channel run
      % is larger than the start of the segment and the the start
      % of the channel run is smaller than the end of the segment.
      if (Starts(SegmentIdx) <= Segments(idx, 2) & ...
	  Ends(SegmentIdx) >= Segments(idx, 1))
	StartingPoint = max(Starts(SegmentIdx), Segments(idx, 1));
	EndingPoint = min(Ends(SegmentIdx), Segments(idx, 2));
	
	% Only add if segment exceeds a minimum length
	if (EndingPoint - StartingPoint > 4)
	  NewSegments = [NewSegments; [StartingPoint EndingPoint]];
	end
	
	% If the ending point is outside the current segment,
	% we are done with this segment
	if Ends(SegmentIdx) > Segments(idx, 2)
	  done = 1;
	else
	  if TargetIdx >= TargetCount
	    done = 1;
	    idx = SegmentCount;
	  else
	    TargetIdx = TargetIdx + 1;
	    SegmentIdx = TargetRuns(TargetIdx);
	  end
	end
	  
      else
	% No intersection.  
	
	% Check if the current start is past the end of the current
	% segment.  If so, it's time to move on to the next segment.
	if (Starts(SegmentIdx) > Segments(idx, 2))
	  done = 1;
	else
	  % Perhaps the next TargetIdx will be better.
	  if TargetIdx >= TargetCount
	    done = 1;
	    idx = SegmentCount;
	  else
	    TargetIdx = TargetIdx + 1;
	    SegmentIdx = TargetRuns(TargetIdx);
	  end
	end
      end
    end
  end
  
  Segments = NewSegments;
end
