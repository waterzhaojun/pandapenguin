function newmx = reorderLayers(mx,nlayers)
% When we use z stack scanning, scanbox's default scanning sequence is from
% bottom to top. But sometime it starts from top. This function is to
% reorder the sequence, put the beginning top layers to the back.
% mx is the 4D matrix that we commonly use in our project.
% nlayers is the number of layers which was on the top and now you want to
% put it to the back.

if nargin < 2, nlayers = 1; end  % So far I find it is usually only 1 layer put on the top.
f = size(mx,4);
neworder = [nlayers+1:f, 1:nlayers];
newmx = mx(:,:,:,neworder);




end