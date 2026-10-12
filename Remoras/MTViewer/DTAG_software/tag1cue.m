function      [c,t,s,len,FS,id,ndigits]=tag1cue(cue,tag,SILENT)
%
%      GENERAL ACCESS TO TAG CUES IS BY tagcue.m
%      tag1cue is called by tagcue
%
%      [c,t,s,len,FS,id,ndigits]=tag1cue(cue,tag,SILENT)
%      Return cue information for a tag dataset:
%         tag  is the deployment name e.g., 'sw01_200'
%         cue is a 1 to 3 element vector interpreted as:
%             1-element: seconds since tag-on
%             2-element: data index in [chip,second]
%             3-element: time of day in [hour,min,sec]
%
%      Output arguments are:
%         c = [chip,audio-sample-in-chip,raw-sensor-sample]
%         t = [year,month,day,hour,min,sec]
%         s = seconds since tag on
%			 len = [id,d,l,r]
%			 where d = data length in hours
%					 l = length of attachment in hours
%					 r = reason for release 0=unknown, 1=release,
%						  2=knock-off, 3=mechanical failure
%
%      Note: the output cue is rounded to the nearest block (0.3s
%      at 32kHz) before the input cue.
%
%  mark johnson, WHOI
%  majohnson@whoi.edu
%  last modified: October 2002 -included bad blocks in chip-sample computation

t = [] ; c = [] ; s = [] ; len = [] ; FS = [] ; id = [] ; ndigits = 2 ;

if nargin==1 & isstr(cue),
   tag = cue ;
   cue = [] ;
end

if nargin<3,
   SILENT=0 ;
end

switch tag
   case 'rw01_207'
 		id = 4 ;
		len = [5.5 -1 -1] ;
      st = [1,4] ;  % starting chip and block
      fs = 16e3 ;
      tagon = [2001 7 25 20 14 0] ;
   case 'rw01_213a'
 		id = 5 ;
		len = [0.5 -1 -1] ;
      st = [1,4] ;  % starting chip and block
      fs = 16e3 ; 
      tagon = [2001 8 1 12 57 21] ;
   case 'rw01_214'
  		id = 6 ;
      st = [1,4] ;  % starting chip and block
      fs = 32e3 ; 
      tagon = [2001 8 2 13 57 32] ;
   case 'rw01_216a'
 		id = 6 ;
      st = [1,4] ;  % starting chip and block
      fs = 32e3 ; 
      tagon = [2001 8 4 14 34 5] ;
   case 'rw01_216b'
 		id = 6 ;
      st = [1,4] ;  % starting chip and block
      fs = 32e3 ; bl = 4096 ;
      tagon = [2001 8 4 18 29 51] ;
   case 'rw01_216c'
 		id = 6 ;
      st = [1,3000] ;  % starting chip and block
      fs = 32e3 ; 
      tagon = [2001 8 4 20 7 17] ;
   case 'rw01_216d'
 		id = 6 ;
      st = [3,1] ;  % starting chip and block
      fs = 32e3 ; 
      tagon = [2001 8 4 21 9 35] ;
   case 'rw01_220'
  		id = 6 ;
      st = [1,4] ;  % starting chip and block
      fs = 32e3 ; 
      tagon = [2001 8 8 21 39 18] ;
   case 'rw01_221'
  		id = 6 ;
      st = [1,4] ;  % starting chip and block
      fs = 32e3 ; 
      tagon = [2001 8 9 14 15 37] ;
   case 'rw01_227a'
  		id = 5 ;
      st = [1,4] ;  % starting chip and block
      fs = 16e3 ; bl = 2048 ;
      tagon = [2001 8 15 15 54 13] ;
   case 'rw01_227b'
  		id = 5 ;
      st = [2,1] ;  % starting chip and block
      fs = 16e3 ; 
      tagon = [2001 8 15 17 43 13] ;
   case 'rw01_231a'
  		id = 5 ;
      st = [1,4] ;  % starting chip and block
      fs = 16e3 ; 
      tagon = [2001 8 19 13 10 1] ;
   case 'rw01_231b'
 		id = 5 ;
      st = [1,4] ;  % starting chip and block
      fs = 16e3 ; 
      tagon = [2001 8 19 16 31 48] ;
   case 'rw01_241a'
  		id = 5 ;
      st = [1,4] ;  % starting chip and block
      fs = 16e3 ; 
      tagon = [2001 8 29 15 7 57] ;
   case 'sw00_250a'
  		id = 4 ;
      st = [1,32] ;  % starting chip and block
      fs = 16e3 ; bl = 1024 ;
      tagon = [2000 9 5 13 23 14] ;
   case 'sw01_199a'
 		id = 6 ;
      st = [1,4] ;  % starting chip and block
      fs = 32e3 ; 
      tagon = [2001 7 17 17 42 34] ;
   case 'sw01_200a'
 		id = 6 ;
      st = [1,4] ;  % starting chip and block
      fs = 32e3 ; 
      tagon = [2001 7 18 15 58 15] ;
   case 'sw01_203a'
 		id = 6 ;
      st = [1,4] ;  % starting chip and block
      fs = 32e3 ; 
      tagon = [2001 7 21 9 40 33] ;
   case 'sw01_203b'
  		id = 6 ;
      st = [1,4] ;  % starting chip and block
      fs = 32e3 ; 
      tagon = [2001 7 21 15 3 1] ;
   case 'sw01_204a'
  		id = 6 ;
      st = [1,4] ;  % starting chip and block
      fs = 32e3 ; 
      tagon = [2001 7 22 14 18 14] ;
   case 'sw01_208a'
  		id = 6 ;
      st = [1 4] ;
      fs = 32e3 ; 
      tagon = [2001 7 26 9 5 41] ;
   case 'sw01_208b'
  		id = 6 ;
      st = [1 4] ;
      fs = 32e3 ; 
      tagon = [2001 7 26 16 42 40] ;
   case 'sw01_209a'
 		id = 6 ;
      st = [1 4] ;
      fs = 32e3 ; 
      tagon = [2001 7 27 8 55 24] ;
   case 'sw01_209c'
 		id = 6 ;
      st = [5 1] ;
      fs = 32e3 ; 
      tagon = [2001 7 27 13 58 48] ;
   case 'sw01_265a'
  		id = 9 ;
      st = [1 4] ;
      fs = 32e3 ;
      tagon = [2001 9 21 13 27 7] ;
   case 'sw01_275a'
 		id = 9 ;
      st = [1 1] ;
      fs = 32e3 ;
      tagon = [2001 10 1 10 9 30] ;
   case 'sw01_275b'
 		id = 9 ;
      st = [7 380] ;     % actual start was [2 1] at 10:30:14 on boat
      fs = 32e3 ;
      tagon = [2001 10 1 12 28 27] ;
   case 'pw02_091a'
  		id = 10 ;
      st = [1 4] ;
      fs = 32e3 ;
      tagon = [2002 4 1 12 59 19] ;
   case 'pw02_091b'
  		id = 8 ;
      st = [1 4] ;
      fs = 32e3 ;
      tagon = [2002 4 1 13 45 10] ;
   case 'pw02_091c'
 		id = 10 ;
      st = [2 1] ;
      fs = 32e3 ;
      tagon = [2002 4 1 14 05 23] ;
   case 'sw02_189b'
 		id = 10 ;
      st = [1 4] ;
      fs = 32e3 ;
      tagon = [2002 7 8 18 16 51] ;
   case 'sw02_191b'
  		id = 10 ;
      st = [1 4] ;
      fs = 32e3 ;
      tagon = [2002 7 10 9 1 24] ;
   case 'sw02_235a'
  		id = 10 ;
      st = [1 4] ;
      fs = 32e3 ;
      tagon = [2002 8 23 10 16 32] ;
   case 'sw02_235b'
 		id = 12 ;
      st = [1 4] ;
      fs = 32e3 ; 
      tagon = [2002 8 23 10 33 20] ;
   case 'sw02_235c'
 		id = 10 ;
      st = [1 4] ;
      fs = 32e3 ; 
      tagon = [2002 8 23 17 03 54] ;
   case 'sw02_236a'
  		id = 10 ;
      st = [1 4] ;
      fs = 32e3 ; 
      tagon = [2002 8 24 17 18 41] ;
   case 'sw02_237a'
  		id = 10 ;
      st = [1 4] ;
      fs = 32e3 ; 
      tagon = [2002 8 25 11 23 02] ;
   case 'sw02_237b'
 		id = 12 ;
      st = [1 4] ;
      fs = 32e3 ; 
      tagon = [2002 8 25 12 13 22] ;
   case 'sw02_238a'
  		id = 10 ;
      st = [1 4] ;
      fs = 32e3 ; 
      tagon = [2002 8 26 9 22 39] ;
   case 'sw02_238b'
 		id = 12 ;
      st = [1 4] ;
      fs = 32e3 ; 
      tagon = [2002 8 26 16 23 45] ;
   case 'sw02_239a'
 		id = 10 ;
      st = [1 4] ;
      fs = 32e3 ; 
      tagon = [2002 8 27 10 40 4] ;
   case 'sw02_239b'
 		id = 12 ;
      st = [1 4] ;
      fs = 32e3 ; 
      tagon = [2002 8 27 17 38 42] ;
   case 'sw02_240a'
 		id = 12 ;
      st = [1 4] ;
      fs = 32e3 ; 
      tagon = [2002 8 23 11 34 29] ;
   case 'sw02_240c'
 		id = 10 ;
      st = [1 4] ;
      fs = 32e3 ; 
      tagon = [2002 8 23 17 03 54] ;
   case 'sw02_248a'
 		id = 10 ;
      st = [1 4] ;
      fs = 32e3 ; 
      tagon = [2002 9 5 18 11 58] ;
   case 'sw02_249a'
 		id = 12 ;
      st = [1 4] ;
      fs = 32e3 ; 
      tagon = [2002 9 6 8 45 11] ;
   case 'sw02_253a'
 		id = 12 ;
      st = [1 4] ;
      fs = 32e3 ; 
      tagon = [2002 9 10 16 38 25] ;
   case 'sw02_254a'
 		id = 10 ;
      %st = [2 1540] ;   % corrupt data in chip 1 and early chip 2
		st = [2 1] ;
		oz = -522.58 ;		 % tag record second at start of offload
      fs = 32e3 ; 
      tagon = [2002 9 11 11 09 17.8] ; % corrected to end of corrupt data
   case 'sw02_254b'
 		id = 12 ;
      st = [1 4] ;
      fs = 32e3 ; 
      tagon = [2002 9 11 10 28 41] ;
   case 'sw02_254c'
 		id = 11 ;
      st = [1 4] ;
      fs = 32e3 ; 
      tagon = [2002 9 11 10 34 05] ;
   case 'zc02_275a'
 	  id = 11 ;
      st = [1 4] ;
      fs = 32e3 ; 
      tagon = [2002 10 2 17 34 41] ;
   case 'pw03_074a'
 	  id = 11 ;
      st = [1 4] ;
      fs = 64e3 ; 
      tagon = [2003 3 15 11 27 40] ;
   case 'pw03_076a'
 	  id = 11 ;
      st = [1 4] ;
      fs = 64e3 ; 
      tagon = [2003 3 17 11 39 2] ;
   case 'pw03_076b'
 	  id = 13 ;
      st = [1 1] ;
      fs = 64e3 ; 
      tagon = [2003 3 17 11 41 37] ;
   case 'pw03_077a'
 	   id = 11 ;
      st = [1 4] ;
      fs = 32e3 ; 
      tagon = [2003 3 18 16 25 43] ;
   case 'pw03_077b'
 	   id = 13 ;
      st = [1 1] ;
      fs = 32e3 ; 
      tagon = [2003 3 18 16 39 8] ;
   case 'pw03_078a'
 	   id = 11 ;
      st = [1 4] ;
      fs = 32e3 ; 
      tagon = [2003 3 19 11 11 47] ;
   case 'pw03_078b'
 	   id = 13 ;
      st = [1 1] ;
      fs = 64e3 ; 
      tagon = [2003 3 19 16 33 38] ;
   case 'pw03_082a'
 	   id = 11 ;
      st = [1 4] ;
      fs = 48e3 ; 
      tagon = [2003 3 23 10 4 6] ;
   case 'pw03_082b'
 	   id = 13 ;
      st = [2 1] ;
      fs = 48e3 ; 
      tagon = [2003 3 23 10 0 16] ;
   case 'pw03_082c'
 	   id = 13 ;
      st = [3 1] ;
      fs = 48e3 ; 
      tagon = [2003 3 23 10 37 21] ;
   case 'pw03_082d'
 	   id = 11 ;
      st = [2 1] ;
      fs = 48e3 ; 
      tagon = [2003 3 23 10 42 29] ;
   case 'pw03_082e'
 	   id = 13 ;
      st = [9 1] ;
      fs = 48e3 ; 
      tagon = [2003 3 23 14 36 31] ;
   case 'sw03_156a'
 	   id = 13 ;
      st = [1 1] ;
      fs = 32e3 ; 
      tagon = [2003 6 5 10 6 13] ;
   case 'sw03_173a'
 	  id = 11 ;
      st = [1 4] ;
      fs = 32e3 ; 
      tagon = [2003 6 22 14 46 06] ;
   case 'sw03_173b'
 	  id = 13 ;
      st = [1 1] ;
      fs = 32e3 ; 
      tagon = [2003 6 22 14 49 38] ;
  
   otherwise
      if ~isempty(cue) & SILENT~=1,
         fprintf('Unknown experiment - supported experiments are:\n') ;
         fprintf('  sw01_199  sw01_200  sw01_203a sw01_203b sw01_204\n') ;
         fprintf('  sw01_208a sw01_208b sw01_209a sw01_209b sw01_265\n') ;
         fprintf('  sw01_275a sw01_275b rw01_207  rw01_213a rw01_214\n') ;
         fprintf('  rw01_216a rw01_216b rw01_216c rw01_216d rw01_220\n') ;
         fprintf('  rw01_221  rw01_227a rw01_227b rw01_231a rw01_231b\n') ;
         fprintf('  rw01_241  pw02_091a pw02_091b pw02_091c\n') ;
      end
      return ;
end

if isempty(cue),
   cue = 0 ;
end

if ~exist('oz','var'),
	oz = 0 ;
end

bldur = 32*340/fs ;       % block duration in seconds
sfs = fs/680 ;            % raw sensor sampling rate in Hz
[bb bl] = badblock(id) ;  % retrieve bad blocks for this tag

% find start point in bad blocks
kb = min(find(bb(:,1)>=st(1) & bb(:,2)>=st(2))) ; 
cRT = [0;cumsum(bl(st(1):end)-hist(bb(kb:end,1),st(1):length(bl))')-st(2)+1]...
       *bldur+oz ; % cumulative record time

switch length(cue)
   case 1
       tcue = cue ;
   case 2
		 if cue(1)-st(1)+1 >= 1,
          tcue = cRT(cue(1)-st(1)+1)+cue(2) ;
		 else
			 tcue = -1 ;
		 end
   case 3
       tcue = etime([tagon(1:3),cue(:)'],tagon) ;
   otherwise
       fprintf('Cue must be 1- to 3- elements. See help tagcue\n') ;
       t = [] ; c = [] ;
       return ;
end

s = tcue ;
if tcue<0,
   fprintf('cue is before start of data set\n') ;
   t = [] ; c = [] ; len = [] ;
   return ;
end

t = datevec(datenum(tagon(1),tagon(2),tagon(3),tagon(4),tagon(5),tagon(6)+tcue)) ;
kl = max(find(cRT<=tcue)) ; 	% find which chip the tcue is in
c(1) = kl-1+st(1) ;
c(2) = fs*(tcue - cRT(kl))+1 ;
c(3) = tcue*sfs ;
c = round(c) ;
len = [id,0,0,0] ;
FS = [fs fs/680] ;


function		[b,bl] = badblock(id)
%
% [b,bl] = badblock(id)
% id = dtag id number
% returns b=[chip,block], bl=number of blocks per chip
%
% mark johnson, april 2003

switch id
   case 4
		b= [1,383;1,1926;3,965;3,1012;6,750;6,948;6,979;9,1660;
			 10,1553;13,783;13,831;13,1008] ;
	   bl = 1024*ones(24,1) ;

	case 5
		b = [1,547;1,1567;1,1599;1,1810;5,619;14,694;14,748;
			  14,790;14,914;14,925;14,955;14,1960;14,2008;14,2017;
			  24,128;24,684;24,746;24,1017] ;
	   bl = 2048*ones(24,1) ;

	case 6
		b = [1,3785;3,110;4,2957;7,104;9,2497;18,383] ;
	   bl = 4096*ones(24,1) ;

	case 7
		b = [6,2049;9,1171;10,886;11,2839;15,434;16,2228;22,2049] ;
	   bl = 4096*ones(24,1) ;

	case 8
		b = [2,2518] ;
	   bl = 4096*ones(24,1) ;

	case 9
		b = [3,3086;4,3927;10,983;18,983;19,2831;21,2157;22,600;
			  22,672] ;
	   bl = 4096*ones(24,1) ;

	case 10
		b = [1,33;1,167;1,4121;1,4889;1,5479;1,5652;1,7475;2,33;
			  2,237;2,4073;2,4375;2,8007;3,33;3,7437;3,7438;3,7439;
			  3,7440;4,33;4,4428;4,4536;4,7487;5,33;5,3711;6,33;
			  6,6355;7,33;7,2474;8,33;8,499;8,4467;8,7285;8,7325;
			  9,33;9,469;9,2954;10,33;10,1635;10,2721;10,3893;
			  10,6981;11,33;11,536;11,4911;11,6961;11,7038;11,7242;
		     11,7286;11,7450;11,7538;11,7906;12,33;12,536;12,4941;
			  12,4942;12,4943;12,4944;13,33;13,3072;13,3076;14,33;
			  14,4932;14,4936;14,5077;14,8175;15,33;16,33] ;
	   bl = 8192*ones(16,1) ;

	case 11
		b = [1,33;2,33;3,33;3,2474;3,3032;3,4176;3,6704;4,33;
			  4,333;4,470;4,1519;4,1876;4,4135;4,5111;4,5351;
			  4,6348;5,33;5,97;5,3169;5,5577;6,33;6,2588;6,2592;
			  6,6071;6,6072;6,6134;7,33;7,4626;7,4969;8,33;8,132;
			  8,4000;9,33;9,1786;9,5646;9,6786;10,33;10,7147;11,33;
			  11,2975;11,3268;11,7647;11,7675;12,33;13,33;13,3093;
			  13,3094;13,3095;13,3096;13,6530;13,6534;14,33;
			  14,3215;14,4682;14,5597;15,33;15,3606;15,3687;16,33;
			  16,568;16,2659;16,7324;16,7610] ;
	   bl = 8192*ones(16,1) ;

	case 12
		b = [1,33;1,1734;2,33;2,3281;2,6292;2,7156;3,33;3,3882;
			  3,7140;3,7142;3,7144;4,33;4,4379;4,5159;5,33;5,1036;
		     6,33;6,7895;7,33;7,2156;7,2614;7,4214;7,7958;8,33;
			  8,7816;9,33;9,440;9,904;9,2934;9,5700;10,33;10,987;
			  10,994;10,2348;10,4251;10,4386;11,33;11,1696;11,7127;
			  11,7905;12,33;12,7251;13,33;13,3873;14,33;14,879;
			  14,3045;14,4362;14,6712;14,7582;14,7963;14,7967;
			  14,7971;15,33;15,2552;16,33;16,4067] ;
	   bl = 8192*ones(16,1) ;

	case 13
		b = [2,1549;2,1958;2,3274;3,8054;3,8102;4,1261;4,1262;4,1263;4,1264;
            4,2900;4,3877;4,3878;4,3879;4,3880;4,4419;4,4420;7,2105;8,4484;
            9,257;9,2907;9,6071;9,6399;9,6431;9,6447;17,3095] ;
	   bl = [2048;8192*ones(9,1);2048*ones(5,1);8192*ones(3,1)] ;

	otherwise
		b = [-1,-1] ;
end
