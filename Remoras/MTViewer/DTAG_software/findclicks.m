function    C = findclicks(tag,cue,INOPTS,C)
%
%     C = findclicks(tag,cue)
%     C = findclicks(tag,cue,filt)
%     C = findclicks(tag,cue,[],C)
%     C = findclicks(tag,cue,filt,C)
%		Click sequence finder for stereo dtags
%     tag is the tag deployment string e.g., 'sw03_207a'
%     cue is the time in seconds-since-tag-on to start working from.
%        If cue = [start_cue end_cue], that interval will be used instead
%        of the default 20s.
%		INOPTS is a 2-vector of high-pass and low-pass frequencies defining
%			a filter to apply to the audio before click detection. If no
%			filt is given or filt=[] the species prefix in tag is used
%        to select sensible values.
%     C is an optional data structure defined below. C can be passed as an
%        input argument to allow multiple work sessions.
%
%	  Valid commands in the figure window are:
%		f  display next time block forward
%		b  display previous time block
%     m  toggle focal and non-focal mode. In focal mode, all clicks
%        selected are added to the focal list. In non-focal mode, clicks
%        are maintained in individual sequences.
%		e	open the sequence closest to the mouse for editing
%		a  save the open sequence as a non-focal sequence
%     t  add the open sequence to the focal click sequence
%		d  display the time waveform and t-f plot for the click closest to
%		the mouse
%		s	select or de-select the current click
%     r  remove all currently selected clicks
%		left-button-drag-box		select all clicks in the drawn box with a
%		   level threshold above the current select threshold
%		+  increase the select threshold level by 10 dB
%		-  decrease the select threshold level by 10 dB
%		j	join the open sequence with the sequence closest to the mouse
%		q or right-button-click		quit
%
%    Output cell array C contains a cell for each unique click sequence 
%    identified. The first cell C{1} is the focal sequence. Each cell 
%    contains a mx3 matrix with the following columns:
%    1  click_cue in seconds since tag on
%    2  angle of arrival with respect to tag x-axis in degrees
%    3  peak level
%
%  mark johnson, WHOI
%  majohnson@whoi.edu
%  last modified: 24 October 2004
%

if nargin<2,
   help findclicks
   return
end

LEN = 20 ;
OVLP = 3 ;
SEL_TH = 0.00075 ;
SC = 6 ;
MAG_TH = -40 ;
FOCAL = 1 ;
NONFOCAL = 2 ;
MODENAME = {'FOCAL','NONFOCAL'} ;

selectsymb = {'ks','ko'} ;
seqorder = ['k+';'kp';'k^';'kv';'kd';'k*';'kh';'kx';'k>';'k<'] ;

OPTS.sw.fh = [5e3 40e3] ;
OPTS.sw.maxthr = 0.03 ;
OPTS.sw.cax = [-50 0] ;
OPTS.sw.NSHOW = [-400 2000] ;
OPTS.sw.maxici = 1.5 ;
OPTS.sw.blanking = 15e-3 ;
OPTS.sw.aoa_win = [-0.3e-3 0.5e-3] ;

%OPTS.md.fh = [2e3 15e3] ;
OPTS.md.fh = [20e3 70e3] ;
OPTS.md.blanking = 1.5e-3 ;
OPTS.md.cax = [-70 -30] ;
OPTS.md.maxthr = 0.002 ;

OPTS.pw.fh = [20e3 75e3] ;

OPTS.by.fh = [25e3 45e3] ;
OPTS.by.blanking = 2e-3 ;
OPTS.by.separation = 0.199 ;
OPTS.by.cax = [-85 -45] ;
OPTS.by.minthr = 0.5e-4 ;
OPTS.by.aoa_win = [-0.2e-3 0.25e-3] ;
OPTS.by.thrfactor = 1 ;

OPTS.def.fh = [20e3 70e3] ;
OPTS.def.blanking = 1e-3 ;
OPTS.def.separation = 0.025 ;
OPTS.def.minthr = 0.0001 ;
OPTS.def.nodisp = 1 ;
OPTS.def.maxici = 1 ;
OPTS.def.cax = [-50 -10] ;
OPTS.def.fl = [] ;
OPTS.def.NSHOW = [-150 150] ;

if nargin<3 | isempty(INOPTS),
   INOPTS = struct([]) ;
elseif ~isstruct(INOPTS) & ~isempty(INOPTS),
	INOPTS = setfield([],'fh',INOPTS(1:2)) ;
end

OPTS = resolveopts(tag,OPTS,INOPTS) ;

if nargin<4,
   C = [] ;
end

if length(cue)==2,
   len = diff(cue) ;
   OVLP = min([OVLP 0.2*len]) ;
else
   len = LEN ;
end

[x fs] = tagwavread(tag,cue(1),0.1) ;
if OPTS.fh(2)>fs/2,
   OPTS.fh(2) = fs*0.46 ;
end

fh = OPTS.fh ;
[bf,af] = butter(4,fh/(fs/2)) ;
OPTS.fh = [] ;

SC = SC*LEN/len ;
scue = cue(1) ;
figure(4), clf
done = 0 ;
mode = NONFOCAL ;

while(done<2)   
   fprintf(' Reading %3.1fs at %5.1f\n',len,scue) ;

   % read in current block of audio
   [x fs] = tagwavread(tag,scue,len) ;
   x = filter(bf,af,x) ;

   % find all clicks and their angle and magnitude in current block
   if size(x,2)>1,
      if size(x,2)>2,
         x = x(:,1:2) ;
      end
      [cl a m q] = rainbow(x,fs,OPTS) ;
   else
      [cl a m q] = rainbowmono(x,fs,OPTS) ;
   end

   if isempty(cl),
      fprintf(' No clicks in selected block\n') ;
      return ;
   end

   % click matrix contains: [cue angle magnitude sequence n_in_seq]
   CL = [scue+cl a m cl*[0 0]] ;

   % identify saved clicks and append any saved clicks that don't appear in CL
   K = [] ;
   for k=1:length(C),
      d = C{k} ;        % for each sequence...
      if ~isempty(d),
         if size(d,2)==1,
            d = [d zeros(size(d,1),1) ones(size(d,1),1)] ;
         end
         kk = find(d(:,1)>=scue & d(:,1)<scue+len) ;  % find clicks in block
         kmatch = nearest(CL(:,1),d(kk,1),SEL_TH) ;   % match them to CL
         kd = find(~isnan(kmatch)) ;                  % find the ones that match
         if ~isempty(kd),
            CL(kmatch(kd),4:5) = [k+0*kd kk(kd)] ;    % identify matches in CL
         end
         knew = find(isnan(kmatch)) ;                 % find clicks not in CL
         if ~isempty(knew),
            CL = [CL;[d(kk(knew),:) k+0*knew kk(knew)]] ;     % and add them to CL
         end
      end
   end

   kk = [] ;      % kk is indices of currently selected clicks in CL
   Coff = [] ;    % Coff is list of currently selected clicks outside of CL
   done = 0 ; accept = 0 ;
   while ~done,

      figure(2), clf
      if ~isempty(kk)   % waveform display of selected clicks in figure panel 2
         X = extractcues(x,(CL(kk,1)-scue)*fs,OPTS.NSHOW) ;
         if size(X,3)>1,
            X = squeeze(X(:,1,:)) ;
         elseif ~isempty(X),
            X = X(:,1) ;
         end
         
         if ~isempty(X),
            plot(X-ones(size(X,1),1)*max(max(abs(X)))*(0:size(X,2)-1)) ;
         end
         title(sprintf('%d clicks of %d',size(X,2),length(kk)+size(Coff,1))) ;
      end

      figure(3), clf    % ici display of selected clicks and off-frame clicks
      if ~isempty(Coff),
         ccl = [Coff(:,1);CL(kk,1)] ;
      else
         ccl = CL(kk,1) ;
      end
      if length(ccl>1)
         ccl = sort(ccl) ;
         if length(ccl)>50,
            kincl = find(ccl>scue-len & ccl<scue+2*len) ;
            ccl = ccl(kincl) ;
         end
         dcl = diff(ccl) ;
         kbig = find(dcl>OPTS.maxici) ;
         dcl(kbig) = NaN ;
         plot(ccl(2:end),dcl,'k+-') ; grid
      end

      figure(1),clf     % main rainbow display
      scatter(CL(:,1),CL(:,2),20,20*log10(CL(:,3)),'filled'),grid
      title(sprintf('Mode %s        Select Threshold %3.0f',MODENAME{mode},MAG_TH)) ;
      box on
      colormap(jet) ;
      set(gca,'XLim',[scue scue+len]) ;
      caxis(OPTS.cax)

      if ~isempty(kk),  % indicate currently selected clicks
         hold on
         hh = plot(CL(kk,1),CL(kk,2),selectsymb{mode}) ;
         hold off
         set(hh,'MarkerSize',6) ;
      end

      % plot clicks that are part of saved sequences...
      % ...find unique sequences
      seqns = unique(CL(find(CL(:,4)>0),4)) ;
      for ks=1:length(seqns),
         if seqns(ks)==1,
            symb = selectsymb{1} ;
         else
            seqsym = 1+rem(ks-1,size(seqorder,1)) ;
            symb = seqorder(seqsym,:) ;
         end
         kseq = find(CL(:,4)==seqns(ks)) ;
         hold on
         hh=plot(CL(kseq,1),CL(kseq,2),symb) ;
         set(hh,'MarkerSize',6) ;
         hold off
      end

      [gx gy button]=ginput(1) ;
      if button==1,
         set(gcf,'Pointer','topl') ;
         [gx(2) gy(2) button] = ginput(1) ;
         set(gcf,'Pointer','arrow') ;
         if button==1,
            gx = sort(gx) ; gy = sort(gy) ;
            kk = sort(unique([kk;find(CL(:,1)>gx(1) & CL(:,1)<gx(2) & CL(:,2)>gy(1) ...
                  & CL(:,2)<gy(2) & 20*log10(CL(:,3))>MAG_TH)])) ;
         end

      elseif button=='s',
         [mm ks] = min(abs(CL(:,1)*SC+j*CL(:,2)-(gx*SC+j*gy))) ;
         if ismember(ks,kk),
            kk = setxor(kk,ks) ;
         else
            kk = sort([kk;ks]) ;
         end

      elseif button=='d',
         [mm ks] = min(abs(CL(:,1)*SC+j*CL(:,2)-(gx*SC+j*gy))) ;
         figure(4),subplot(211)
         X = extractcues(x,(CL(ks,1)-scue)*fs,OPTS.NSHOW) ;
         X = squeeze(X(:,1,:)) ;
         plot((1:length(X))/fs,X),grid
         set(gca,'XLim',[0 length(X)/fs]) ;
         title(sprintf('angle %3.1f degrees',CL(ks,2))) ;
         
         subplot(212)
         if length(X)>512,
            specgram(X,512,fs,hanning(512),300),grid
         else
            wigner1(hilbert(X),fs) ; grid
            set(gca,'YLim',[fh(1)/2 0.45*fs],'XLim',[0 length(X)/fs]) ;
         end
         pause;
         figure(1)

      elseif button=='r',
         kk = [] ;
         %Coff = [] ;

      elseif button=='e' & mode==NONFOCAL,
         [mm ks] = min(abs(CL(:,1)*SC+j*CL(:,2)-(gx*SC+j*gy))) ;
         if CL(ks,4)>0,           % is this click associated with a sequence?
            dd = C{CL(ks,4)} ;    % remove the sequence from C for editing
            C{CL(ks,4)} = [] ;    % and replace with a blank sequence
            kk = find(CL(:,4)==CL(ks,4)) ; % find clicks in CL assoc. with this seq
            koff = setxor(1:size(dd,1),CL(kk,5)) ;
            Coff = dd(koff,:) ;   % find off-screen clicks in the sequence
            CL(kk,4:5) = 0 ;      % clear the seq. assoc. of clicks in the frame
         end

      elseif button=='j' & mode==NONFOCAL,
         [mm ks] = min(abs(CL(:,1)*SC+j*CL(:,2)-(gx*SC+j*gy))) ;
         if CL(ks,4)>0,           % is this click associated with a sequence?
            dd = C{CL(ks,4)} ;    % access the sequence 
            kn = nearest(dd(:,1),CL(kk,1),SEL_TH) ; % find clicks not in the sequence
            knew = find(isnan(kn)) ;
            dd = [dd;CL(kk(knew),1:3)] ;   % add new clicks to sequence
            if ~isempty(Coff),    % repeat for Coff if any
               kn = nearest(dd(:,1),Coff(:,1),SEL_TH) ; % find clicks not in the sequence
               knew = find(isnan(kn)) ;
               dd = [dd;Coff(knew,:)] ;   % add new clicks to sequence
            end
            [ddd I] = sort(dd(:,1)) ;  % sort sequence into order
            C{CL(ks,4)} = dd(I,:) ;    % and replace in C
            % associate clicks in CL with the sequence
            CL(kk,4:5) = [CL(ks,4)+0*kk nearest(dd(I,1),CL(kk,1),SEL_TH)] ;
            kk = [] ;                  % clear current selected indices
         end

      elseif button=='+',
         MAG_TH = MAG_TH+10 ;
         title(sprintf('SELECT THRESHOLD %3.0f',MAG_TH)) ;

      elseif button=='-',
         MAG_TH = MAG_TH-10 ;
         title(sprintf('SELECT THRESHOLD %3.0f',MAG_TH)) ;

      elseif button=='f',
         done = 1 ;
         scue = scue+len-OVLP ;

      elseif button=='b',
         done = 1 ;
         scue = max([0 scue-len+OVLP]) ;

      elseif button==3 | button=='q',
         done = 2 ;

      elseif button=='m' | (button=='a' & mode==NONFOCAL),
         accept = 1 ;
      end

      if accept | done,
         dd = [Coff ; CL(kk,1:3)] ;  % save the current clicks to a sequence
         if ~isempty(dd),
            [ddd I] = sort(dd(:,1)) ;
            if mode==NONFOCAL,
               nseq = max([2 length(C)+1]) ;
            else
               nseq = 1 ;
            end
            C{nseq} = dd(I,:) ;
            CL(kk,4:5) = [nseq+0*kk nearest(dd(I,1),CL(kk,1),SEL_TH)] ;
            save findclicks_Recover C
            kk = [] ; Coff = [] ;
         end
         accept = 0 ;
         if done, mode = NONFOCAL ; end
      end    

      if button=='m',
         if mode==NONFOCAL,
            mode = FOCAL ;
            if ~isempty(C),      % open the focal sequence for editing
               dd = C{1} ;             % remove the focal sequence from C for editing
               C{1} = [] ;
               kk = find(CL(:,4)==1) ; % find clicks in CL assoc. with this seq
               koff = setxor(1:size(dd,1),CL(kk,5)) ;
               Coff = dd(koff,:) ;     % find off-screen clicks in the sequence
               CL(kk,4:5) = 0 ;        % clear the seq. assoc. of clicks in the frame
            end
         else
            mode = NONFOCAL ;
         end
      end      % button=='m'
   end         % while ~done
end            % while done<2

% clean up Cn by removing empty cells

if isempty(C),
   return
end

CC = {C{1}} ;
for k=2:length(C),
   d = C{k} ;
   if ~isempty(d),
      CC{length(CC)+1} = d ;
   end
end
C = CC ;
return
