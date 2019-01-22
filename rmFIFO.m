function datao = rmFIFO(datai)
% rmFIFO.m
%
% HARP data logger FIFO noise removal filter
%
% useage: >>datao = rmFIFO(datai)
%
%  where,   datai = HARP data input from hrp file before xwav file
%           datao = output data ready for more filtering or write to xwav
%
%
% 100527 smw
% 
nsamp = length(datai);
%remove FIFO noise (every 4,000th sample)
% fs = 200000Hz -> noise every 50Hz
% fs = 320000Hz -> noise every 80Hz
%build "noise" kernal to subtract from data
fifo = 4000; % a/d buffer size
min_nsamp = floor(nsamp/fifo);
rnsamp = min_nsamp*fifo;
datai=datai.';
noise = reshape(datai(1,1:rnsamp), fifo, min_nsamp);
noise_avg = mean(noise,2);
%         figure(12) %if you want to see if it is working
%         plot(noise_avg)
noise_avg = noise_avg';
noise_sum = ones(1,rnsamp);
%append noise together
for jj = 1:fifo:rnsamp
    noise_sum(1,jj:jj+fifo-1)= noise_avg(1,1:fifo);
end
% noise is not the same length as data, because only took a fraction
ex = rem(nsamp,length(noise_sum));%remainder not filled in noise matrix
ex = round(ex);
noise_all = [noise_sum noise_sum(1,1:ex)];
datao = datai - noise_all;
