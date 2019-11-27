function a=get_csd_array(mx)

mx= normalize(double(mx), 4);
a = squeeze(mean(mx, [1,2]));

end