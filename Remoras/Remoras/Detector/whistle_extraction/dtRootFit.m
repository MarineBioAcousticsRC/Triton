function [smoothed_tonals] = dtRootFit(Filename)
% Code from Liz Henderson, Kait Frasier, and Marie Roch
% Go through a tonals.bin file, smooth each tonal, then fit a polynomial,
% take derivative and find roots.
% Output: A "fittedtonals" java LinkedList containing interpolated whistle contour points, polynomial 
% coefficents, r^2 for goodness of fit, derivative coefficients, roots.
% Info about each whistle segment (between roots) is given (Min,
% Max,Segment Duration, max slope, mean slope, bandwidth).

% Sample input: 
% [smoothed_tonals] = dtRootFit_liz('K:/Delphinus files/B07h24m24s17aug2006y_0to30sec.bin');

% % To access the info in the output LinkedList, you can call various variables,
% % for each tonal

% % example 1: 
% tonal0 = smoothed_tonals.get(0); % pull out all characteristics of 0th tonal
% tonal0_roots = tonal0.getRoots; % find roots of 0th tonal

% % example 2: 
% % Plot smoothed tonal
% tonal0_smooth = tonal0.getThisTonal; % find roots of 0th tonal
% tonal0_freq = tonal0_smooth.get_freq;
% tonal0_time = tonal0_smooth.get_time;
% plot (tonal0_time,tonal0_freq)

% % to figure out what the info you can ask for from a given list use the
% % "methods" command in matlab:
% % example: 
% methods(smoothed_tonals.get(0))

% % Attn!! 
% % Appending '.setRoots' will change the values of 'Roots' for a
% % given whistle to whatever you're setting it to.
% % --> So mostly, you want to be 'getting' (NOT 'setting'), if you're doing
% % analysis of the output.

% clear all % can't clear all within a function

% Java classes we will be needing
% Note that the Java calls have side effects to their arguments
import java.util.LinkedList;
import tonals.*;


% Get filename
% [filepath, filename, ext, versn] = fileparts(Filename);
[filePath, filename, ext, versn] = ...
    fileparts(Filename);
filePath = [filePath,'/'];

% Initialize
newInflectionFinder = InflectionFinder();
% Set path
newInflectionFinder.setFilePath(filePath);
fittedTonalList = LinkedList;
% Load tonals
traced_tonals = dtTonalsLoad(Filename,false);
% newInflectionFinder.loadTonals(filename_ext);
tonal_it = traced_tonals.iterator();  % Get iterator object; java option
% while tonal_it.hasNext() 
tonalsN = traced_tonals.size(); % matlab iterator option

a=1; b=2; c=3; d=4; e=5; f=6; g=7; h=8; k=9; l=10;
for tidx = 0 : tonalsN-1
    thisTonal = tonal_it.next(); % get next tonal
    if max(thisTonal.get_freq())< 25000
    time = thisTonal.get_time(); % time is a double array 
    freq = thisTonal.get_freq(); % freq is a double array 
%  Inserted correction for cases where there are double x-values - from
%  Marie
    [t2, tindices] = unique(time, 'first');  % return unique list of sorted times & permuation
    if length(t2) ~= length(time)
        fprintf('Sort problem - ground truth %d\n', tidx);
        % fix it
        time = t2;
        freq = freq(tindices);  % Reorder according to permutationend
    end   

    % smooth using interpolation
    newtime = time(1):0.002:time(end);
    newfreq = interp1(time,freq,newtime,'spline');
%     newtonal = tonals.tonal(newtime, newfreq);
    new_whistle = [newtime; newfreq]; %this is the interpolated whistle which is saved in the end
    whistle_num = tidx+1;
  
        
    % The following info will be stored in a Polynomial object
    % Set order nd r2 to lowest, then increase them until you have a fit 
    order = 1;
    r2=0;
    acceptR2 = .99;
    while r2 < acceptR2 
        [poly, polyS] = polyfit(newtime, newfreq, order);
        freq_y = polyval(poly,newtime,polyS);
        
        % create a plot of each line and fit, take this out when automated
%          plot(newtime,newfreq,'o',newtime,freq_y,'--')
        
        firstder = polyder(poly); %calculate min and max values
%       can add this calculation if desired, but then have to add to save structure at end of loop
%       secDer = polyder(firstder); 
        polyroot = roots(firstder); %calculate roots of the min/max values
%        inflections = roots(secDer);


%       loop deals with overfitting, if fit is creating imaginary roots, back up one order and break      
        if isreal(polyroot) == 0 
           order = order - 1;
           [poly, polyS] = polyfit(newtime, newfreq, order);
           freq_y = polyval(poly,newtime,polyS);
           firstder = polyder(poly); %calculate min and max values
           polyroot = roots(firstder); %calculate roots of the min/max values
           break
        end
    
%       loop to calculate r2 values        
        for i = 1:length(newfreq)
            sum_sq(i) = (newfreq(i)-mean(newfreq))^2;
            sum_sq_e(i) = (newfreq(i) - freq_y(i))^2;
        end
        sum_sq_t = sum(sum_sq);
        sum_sq_r = sum(sum_sq_e);
        r2 = 1 - (sum_sq_r/sum_sq_t);

%       this loop retains an order of 1 for whistles that are basically
%       flat
        if max(newfreq)-min(newfreq) < 200
            break
        elseif (r2 < 0.99) && (order < 10)
        order=order+1;
        sum_sq = []; sum_sq_e = []; freq_y = [];
        else
            break
        end
    end
    
    % get rid of roots outside the whistle time
    polyroot_n = [];
    aa = 1;
    for ii = 1:length(polyroot)
        if isreal(polyroot(ii)) && (polyroot(ii) > newtime(1))...
                && (polyroot(ii) < newtime(end)) 
            polyroot_n(aa) = polyroot(ii);
            aa = aa+1;
        end
    end
    
    polyroot_n = sort(polyroot_n);
    newtonal = tonals.tonal(newtime, freq_y);
    
    % this loop cuts each tonal into segments based on the min/max of the
    % polynomial, then calculates the duration, min/max frequency, and
    % mean/max slope of each segment
    x=1; y = 1; z = 1; time_new = []; freq_new = []; slope = [];
    for j = 1: length(polyroot_n)
          while z <= length(newtime)
          
             if newtime(z) <= polyroot_n(j)
                time_new(x,j) = newtime(z);
                freq_new(x,j) = freq_y(z);
                slope(x,j) = polyval(firstder,newtime(z));
                x=x+1; z = z+1;
             elseif (newtime(z) > polyroot_n(j)) && z <= length(newtime)  
%                 
                  if j < length(polyroot_n)               
                    segdur(j) = time_new(x-1,j)-time_new(1,j);
                    minfreq(j) = min(freq_new(1:x-1,j));
                    maxfreq(j) = max(freq_new(1:x-1,j));
                    bandwidth(j) = maxfreq(j) - minfreq(j);
                    meanslope(j) = mean(slope(1:x-1,j));
                    maxslope(j) = max(abs(slope(1:x-1,j)));
                    x = 1; 
                    break
                  else
                    time_new(y,j+1) = newtime(z);
                    freq_new(y,j+1) = freq_y(z);
                    slope(y,j+1) = polyval(firstder,newtime(z));
                    y = y+1; z = z+1; 
                   end
            end
          end
                if j == length(polyroot_n)
                    segdur(j) = time_new(x-1,j)-time_new(1,j);
                    minfreq(j) = min(freq_new(1:x-1,j));
                    maxfreq(j) = max(freq_new(1:x-1,j));
                    bandwidth(j) = maxfreq(j) - minfreq(j);
                    meanslope(j) = mean(slope(1:x-1,j));
                    maxslope(j) = max(abs(slope(1:x-1,j)));
             
                    segdur(j+1) = time_new(y-1,j+1)-time_new(1,j+1);
                    minfreq(j+1) = min(freq_new(1:y-1,j+1));
                    maxfreq(j+1) = max(freq_new(1:y-1,j+1));
                    bandwidth(j+1) = maxfreq(j+1) - minfreq(j+1);
                    meanslope(j+1) = mean(slope(1:y-1,j+1));
                    maxslope(j+1) = max(abs(slope(1:y-1,j+1)));
                end
          
    end

    % If no values were created, store zeros and move on to next whistle.
if isempty(polyroot_n) == 1
    segdur = newtime(end)-newtime(1);
    minfreq = min(freq_y);
    maxfreq = max(freq_y);
    bandwidth = maxfreq-minfreq;
    meanslope = polyval(firstder,newtime(1));
    maxslope = meanslope;
    polyroot_n = 0;
end

% this section creates a matrix for each tonal of all the calculated values
% tonal_mat = zeros(500,10);
tonal_mat(a:l,1) = whistle_num;
tonal_mat(a,2) = r2;
tonal_mat(b,2:1+length(poly)) = poly(1:end);
tonal_mat(c,2:1+length(firstder)) = firstder(1:end);
tonal_mat(d,2:1+length(polyroot_n)) = polyroot_n(1:end);
tonal_mat(e,2:1+length(minfreq)) = minfreq(1:end);
tonal_mat(f,2:1+length(maxfreq)) = maxfreq(1:end);
tonal_mat(g,2:1+length(bandwidth)) = bandwidth(1:end);
tonal_mat(h,2:1+length(segdur)) = segdur(1:end);
tonal_mat(k,2:1+length(meanslope)) = meanslope(1:end);
tonal_mat(l,2:1+length(maxslope)) = maxslope(1:end);

a=a+10;b=b+10;c=c+10;d=d+10;e=e+10;f=f+10;g=g+10;h=h+10;k=k+10;l=l+10;


%exporting all the above values into java LinkedList
newFittedTonal = FittedTonal();	
newFittedTonal.setThisTonal(newtonal);% saves interpolated whistle info, for HMM use later
newFittedTonal.setR2(r2);
newFittedTonal.setDeriv(firstder);
newFittedTonal.setCoeff(poly);
newFittedTonal.setRoots(polyroot_n);
newFittedTonal.setMin(minfreq);
newFittedTonal.setMax(maxfreq);
newFittedTonal.setBandWidth(bandwidth)
newFittedTonal.setSegDur(segdur);
newFittedTonal.setMeanSlope(meanslope);
newFittedTonal.setMaxSlope(maxslope);
fittedTonalList.add(newFittedTonal);
    end
end


% fitted tonals to a simple file, (semi-colon delimited)
newInflectionFinder.fittedTonalList = fittedTonalList;
% newInflectionFinder.saveFittedTonals(fullfile([filename,'_seglist']));
% Output the java LinkedList to workspace
smoothed_tonals = newInflectionFinder.fittedTonalList;







