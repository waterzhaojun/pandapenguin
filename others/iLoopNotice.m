function iLoopNotice(i, length, gap)

    % length is the total length of the loop.
    % i is the current i in the loop.
    % gap is every how many percent print a note.
    % usually just use the i in the for loop. 
    % like: iLoopNotice(i, size(2, array), 10);
    
    currentP = i/length*100;
    lastP = (i-1)/length*100;
    
    if floor(currentP/gap)>floor(lastP/gap)
        disp(sprintf('%d percent done', floor(i/length*100)));
    end

end