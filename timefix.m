function out = timefix(data, dates)
    start_week = week(dates(1)) - 1;
    current_year = year(dates(length(dates)));
    for i = height(data):-1:1
        if data.YEAR(i) == current_year - 5
            cut = i - data.WEEK(i) + start_week;
            break
        end
    end
    out = data.ILITOTAL(cut:height(data));
end