function features = dtWaveletFB(basis, packets)
% features = dtWaveletFB(basis, packets)
% Given an indicator function specifying which basis set to use,
% determine the average energy in each basis and then compute
% the log dct of the average energies.

[len, depth] = size(packets);

% Allocate for each basis we will examine
basis_indices = find(basis == 1);
Coef = zeros(length(basis_indices)*(1 + 8), 1);  % Eek!  Magic # (dct coef)
bases = length(basis_indices);

%figure('Name', 'Subband comparison')

% Compute energy
energies = zeros(bases, 1);
% Examine each basis
basis_n = 1;
for b = basis_indices
  % Compute the depth and offset idx for basis b
  d = floor(log2(b));
  idx = b - 2^d;
  
  % pull out coefficients and sum energy
  data = packets(packet(d,idx,len), d+1);
  
  energies(basis_n) = log(sum(data .^ 2));
  basis_n = basis_n+1;
end

basis_n = 1;
for b = basis_indices
    d = floor(log2(b));
    idx = b - 2^d;
    data = packets(packet(d,idx, len), d+1);
    
    % Compute cepstrum
    spectrum = fft(data);
    data_n = length(data);
    magspectrum2 = spectrum .* conj(spectrum);
    cepstrum = dct(log(magspectrum2(1:floor(data_n/2))));
    retain_n = floor(data_n/4);    % prune
    % first cepstral coefficient is related to energy
    subband{basis_n} = cepstrum(2:retain_n);
    if any(~ isreal(cepstrum))
        fprintf('Imaginary cepstrum!')
        keyboard
    end
    basis_n = basis_n + 1;
end

features = vertcat(energies, subband{:});
1;

