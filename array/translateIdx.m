function newidx = translateIdx(oriIdx, oriScanrate, toScanrate)
% This function is to translate the index between different scanrate. The
% scanrate should be original scanrate, not round value. If translate from
% slow to fast, it will point to the first timepoint of fast scan rate
% period of time.

newidx = round(oriIdx * toScanrate / oriScanrate);
% I changed it from ceil to round. Let's see. 2/3/2021


end