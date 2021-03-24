function output = HRF(para, n)
% HRF (hemodynamic response functions) model is to mimic a single time
% point stimulation induced exponial shape response. It is widely used in
% blood vessel dilation/constriction responses. 

% The output relay on three parameters: A, td, tao, which is included in 'para' variable. 

% Variable n defines how long you want this model describe. For example, n
% is 100 means to apply 1:100 to HRF model. 

% To alway have a 0 at the beginning (like the baseline), we add a 0 as the
% first output element, but I am thinking this may be overcomed by apply
% 0:100 as default. In the following code, first line is the old version,
% second line is the new version.

% output = [0,para(1)*exp(-([1:n] - para(2)) / para(3))] .*[0, floor(heaviside([1:n]-para(2)))];
output = para(1)*exp(-([0:n] - para(2)) / para(3)) .* floor(heaviside([0:n]-para(2)));


end