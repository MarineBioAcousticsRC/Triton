function bm_loadKernelPicks
% Choose directory to find call data
% defdir = '';   % default directory
% cDir = uigetdir(defdir,'Select Directory to Load Call Data');
% % if the cancel button is pushed, then no file is loaded so exit this script
% if strcmp(num2str(cDir),'0')
%     disp('Canceled Button Pushed - no directory for call data')
%     return
% else
%     disp('Load call data from directory : ')
%     disp(cDir)
% end

% Display number of files in directory
% cDir = 'E:\code\BcallMethod\MATfiles\CallMats';  %Hard code option

d = dir(REMORA.bm.settings.kernel);    % directory info
fn = char(d.name);      % file names in directory
fnsz = size(fn);        % number of files in directory including 2 hidden files
fname = fn(3:fnsz(1),:); % get rid of first two hidden files
fnamesz = size(fname);   % new set of file names
nfiles = fnamesz(1);     % number of files in directory
disp(['Number of files in directory is ',num2str(nfiles)])
kernelcode = [REMORA.bm.settings.kernelSite REMORA.bm.settings.kernelDepl];
cd(cDir)
for a = 1:nfiles
    
    filename = [kernelcode '_Bcall_',num2str(a),'.mat'];

%     if exist(filename,'file') == 2
        
        load(filename)
        Calls(a,:) = Call;
        kernel = nanmean(Calls);       
        
      
        clear Call 
        
        
%     else
%         continue
%     end
end