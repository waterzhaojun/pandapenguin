function frames = goodFrames(vec)
    
    vec = double(vec);
    x = 1:length(vec);
    fit = fitlm(x, vec);
    frames = [];
    for i = 1:length(vec)
        if vec(i)>fit.Fitted(i)-fit.RMSE & vec(i)<fit.Fitted(i)+fit.RMSE
            frames = [frames; i];
        end
    end
    


end


