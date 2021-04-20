function out = statefix(data, state)
    out = [];
    for i = 1:51
        if(strcmp(state,data.REGION(i)))
            pos = i;
            break
        end
    end
    iterate = 52;
    while pos < height(data)
        if strcmp(state, data.REGION(pos))
            out = [out; data(pos,1:width(data))];
            pos = pos + iterate;
        else
            pos = pos + 1;
            iterate = iterate + 1;
        end
    end
end