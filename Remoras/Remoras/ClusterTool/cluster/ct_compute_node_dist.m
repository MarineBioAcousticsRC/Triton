function distClickE = ct_compute_node_dist(specClickTf,wcorTF)
% find distance between them
if ~wcorTF
    % Can use euclidean distance, but it doesn't capture shape very well
    % distClick = pdist(specClickTf_norm,'seuclidean');
%     for iB = 1:tempN
%         verySmall = specClickTf_norm_short(iB,:)<=.2;
%         specClickTf_norm_short(iB,verySmall) = 0;
%     end
    distClick = pdist(specClickTf,'euclidean');
    distClickE = ((-distClick)/max(max(distClick)))+1;
    %distClickE = (exp(-distClick));
else
    % weighted correlation
    % Wgts = 1:-1/(size(specClickTf,2)-1):0; % Vector from 1 to 0 ->
    % decreasing weight as frequency increases
    Wgts = ones(1,size(specClickTf,2));  %all ones -> no weighting 
    
    X = specClickTf;
    X = bsxfun(@minus,X,mean(X,2));
    Xmax = max(abs(X),[],2);
    X2 = bsxfun(@rdivide,X,Xmax);
    Xnorm = sqrt(sum(X2.^2, 2));
    Xnorm(Xmax==0) = 0;
    Xnorm = Xnorm .* Xmax;
    X = bsxfun(@rdivide,X,Xnorm);
    
    % euclidean option:
    % weuc = @(XI,XJ,W)(sqrt(bsxfun(@minus,XI,XJ).^2 * W'));
    
    % correlation option:
    wcorr= @(XI,XJ,W)(1-sum(bsxfun(@times,XI,XJ) * W',2));
    Dwgt = pdist(X, @(Xi,Xj,Wgts) wcorr(Xi,Xj,Wgts),Wgts);
    
    distClickE = (exp(-real(Dwgt)));
end
distClickE = sqrt(real(distClickE));
