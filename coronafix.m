function data = coronafix(data, dates)
%     start_data = data
    end_pos = length(dates);
    while(1)
        if strcmp(dates(end_pos), '2020-04-26')
            break
        else
            end_pos = end_pos - 1;
        end
    end
    start_pos = end_pos - 9;
    not_rona_szn = [data(1:start_pos, :); data(end_pos:length(data), :)];
    for i = 1:size(not_rona_szn, 2)
        if max(not_rona_szn(:,i)) ~= 100
            data(:,i) = 100 - max(not_rona_szn(:,i)) + data(:,i);
        else
            continue
        end
    end
    rona_szn = data(start_pos:end_pos, :);
    diff = (rona_szn(1,:) - rona_szn(size(rona_szn, 1), :));
    diff_avg = diff / (size(rona_szn, 1) - 2);
    for i = 1:size(rona_szn, 2)
        if max(rona_szn(:,i)) == 200 - max(not_rona_szn(:,i))
            for j = 2:size(rona_szn, 1) - 1
                rona_szn(j,i) = rona_szn(j - 1,i) - diff_avg(i);
            end
        else
            continue
        end
    end 
    data(start_pos:end_pos, :) = rona_szn;
%     plot(data);
%     hold on
%     plot(start_data);
%     hold off
end