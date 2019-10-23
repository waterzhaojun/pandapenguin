function output = denoise(matrix,parameters)

    % This function use '3dgaussfilter' to denoise the matrix

    
    % As I know sd Gaussian filter is a better method than avergae. It
    % keeps more details.
    sigma = 100; % This is a tricky parameter. So far I didn't see much different. 
    sdgaussfilter_size = 7; % The more, the smoother and blurrer.
    sdgaussfilter_frames = 15; % So far I fix this value for 0.2hz frame number.
    wiener_size = 5; % The size of area to calculate variance.
    
    [r,c,ch,f] = size(matrix);
    
    if ch == 1
        % disp('go 1');
        output = imgaussfilt3(squeeze(matrix), sigma, 'FilterSize', [sdgaussfilter_size,sdgaussfilter_size,sdgaussfilter_frames]);

        % add wiener filter
        for i = 1:f
            output(:,:,i) = wiener2(output(:,:,i), [wiener_size, wiener_size]);
            if rem(i, 100) == 0
                disp([num2str(i), ' of ', num2str(f), ' is applied wiener filter.']);
            end
        end
        output = reshape(output, [r,c,ch,f]);
    else
        % disp('go 2');
        output = matrix;
        dpmts = parameters.denoise_pmt;
        for dp = 1:length(dpmts)
            tmp = imgaussfilt3(squeeze(output(:,:,dpmts(dp)+1,:)), sigma, 'FilterSize', [sdgaussfilter_size,sdgaussfilter_size,sdgaussfilter_frames]);
            for i=1:f
                output(:,:,dpmts(dp)+1,:) = wiener2(tmp(:,:,i), [wiener_size, wiener_size]);
            end
        end
    end
        
end