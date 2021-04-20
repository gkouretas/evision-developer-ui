function [google_data, dt] = trends_scraper(app, code, lang, disease, level)
    pe = py_init();
    if strcmp(disease, 'Influenza')
        fix = 1;
        terms = py.list({"cough", "sore throat", "flu", "tamiflu"}); % keywords
        if strcmp(app.DateRangeDropDown.Value, "Past 5 Years")
            time = 'today 5-y';
        else
            time = string(app.StartDateDatePicker.Value) + ' ' + string(app.EndDateDatePicker.Value);
        end
    elseif strcmp(disease, 'COVID-19')
        fix = 0;
        terms = py.list({"loss of smell", "loss of taste"});
        if strcmp(level, 'State')
            if strcmp(app.DateRangeDropDown.Value, "All Available Dates")
                time = '2020-01-25 ' + string(datetime(date, 'Format', 'uuuu-MM-dd') - 1);
            else
                time = string(app.StartDateDatePicker.Value) + ' ' + string(app.EndDateDatePicker.Value);
            end
        elseif strcmp(level, 'National')
            if strcmp(app.DateRangeDropDown.Value, "All Available Dates")
                time = '2020-04-19 ' + string(datetime(date, 'Format', 'uuuu-MM-dd') - 1);
            else
                time = string(app.StartDateDatePicker.Value) + ' ' + string(app.EndDateDatePicker.Value);
            end
        end
    end
    out = py.google_scraper.scrape(py.list(code), terms, char(lang), char(time));
    data = double(py.array.array('d',py.numpy.nditer(out(1))));
    misses = cellfun(@double,cell(out(2)));
    google_data = reshape(data,[],(length(terms) * length(code)) - misses); 
    dates = py.google_scraper.get_date(char(time));
    dates = cellfun(@char, cell(dates), 'UniformOutput', false)';
%     if(fix) 
%         google_data = coronafix(google_data, dates); 
%     end
    dt = datetime(dates);
%     dt = dt + 1;
end
% reshapes returned data to only include the values of the search data
