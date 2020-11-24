function [ridx,cidx] = bwcenter(bw)

rsum = find(sum(bw,2) > 1);
ridx = floor((min(rsum)+max(rsum))/2);

csum = find(sum(bw,1) > 1);
cidx = floor((min(csum)+max(csum))/2);

end