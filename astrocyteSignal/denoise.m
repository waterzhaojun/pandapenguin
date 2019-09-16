function output = denoise(matrix, method)

    if nargin < 2, method = '3dgaussfilter'; end

    if method == '3dgaussfilter'
        % As I know sd Gaussian filter is a better method than avergae. It
        % keeps more details.
        sigma = 100; % This is a tricky parameter. So far I didn't see much different. 
        sdgaussfilter_size = 7; % The more, the smoother and blurrer.
        sdgaussfilter_frames = 15; % So far I fix this value for 0.2hz frame number.
        output = imgaussfilt3(matrix, sigma, 'FilterSize', [sdgaussfilter_size,sdgaussfilter_size,sdgaussfilter_frames]);
    end

    % add wiener filter
    f = size(output, 3);
    wiener_size = 5; % The size of area to calculate variance.
    for i = 1:f
        output(:,:,i) = wiener2(output(:,:,i), [wiener_size, wiener_size]);
        if rem(i, 100) == 0
            disp([num2str(i), ' of ', num2str(f), ' is applied wiener filter.']);
        end
    end

end