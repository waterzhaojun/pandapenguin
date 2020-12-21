function newidx = translateIdx(oriIdx, fastScanrate, slowScanrate)

newidx = ceil(oriIdx * slowScanrate / fastScanrate);

end