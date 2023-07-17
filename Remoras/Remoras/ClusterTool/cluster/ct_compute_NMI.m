function [NMIList] = ct_compute_NMI(nList,ka,naiItr,inputSet)
% inputs:
% nList = cell array containing the list of nodes in each partition
% ka = vector containing number of clusters in each partition
% naiItr = cell array containing list of nodes in each cluster for each
%   partition. 
%   (e.g. naiItr{1}{2} contains nodes from partition 1, cluster 2)

N = length(nList); % # of partitions
cntr2=1;
NMIList = zeros(N,N);
for i = 1:N 
    kA = ka(i); % # of clusters in iteration A
    
    for j = i+1:N
        kB = ka(j); 
        % find nodes common to both datasets
        % commonSet = intersect(nList{i},nList{j});
        commonSet = intersect(inputSet{1},inputSet{j});
        n = length(commonSet);
        
        % Compute entropy of A for each cluster
        set_a = {};
        nai = zeros(1,kA);
        % pull out node numbers in cluster a
        for iA = 1:kA
            set_a{iA} = intersect(commonSet,naiItr{i}{iA}); 
            nai(iA) = length(set_a{iA}); 
        end
        Entropy_A = nai.*log2(nai/n);
        denom1 = nansum(Entropy_A); % Denominator term 1
        
        % Compute entropy of B for each cluster
        set_b = {};
        nbj = zeros(1,kB);
        % pull out node numbers in cluster b
        for jB = 1:kB
            set_b{jB} = intersect(commonSet,naiItr{j}{jB}); 
            nbj(jB) = length(set_b{jB}); 
        end
        Entropy_B = nbj.*log2(nbj/n);
        denom2 = nansum(Entropy_B); % Denominator term 2
        
        % Determine common nodes btwn each pair of clusters, and compute
        % mutual information
        mutInfoAB = [];
        cntr1 = 1;
        for ia = 1:kA
            for jb = 1:kB
                naibj(cntr1) = length(intersect(set_a{ia},set_b{jb}));
                mutInfoAB(cntr1) = naibj(cntr1)*log2((naibj(cntr1)*n)/(nai(ia)*nbj(jb)));
                cntr1 = cntr1 + 1;
            end
        end

        NMIList(i,j) = (-2*nansum(mutInfoAB))/(denom1+denom2);
        NMIList(j,i) = NMIList(i,j);
        cntr2 = cntr2 + 1;
    end
end



