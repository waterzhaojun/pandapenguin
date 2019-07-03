function pretreat(animalID, dateID, run, pmt,outputPath)

    mx = mxFromSbx(animalID, dateID, run, pmt);
    
    mx1 = denoise(mx);
    
    mx1 = trimMatrix(animalID, dateID, run, mx1, 150);
    mx1 = downsample(mx1);
    
    mx2tif(mx1, 'D:\Jun\exp\denoise_sigma100_7_wiener_5_downsample.tif', 15);

end