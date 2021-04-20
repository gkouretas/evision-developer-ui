function [case_data, dates] = cdc_scraper(app, dates)
    pe = py_init();
    if strcmp(app.DiseaseDropDown.Value, 'Influenza')
        if strcmp(app.PredictionLevel.Value, 'National') && ~strcmp(app.SublevelDropDown.Value, 'United States of America')
            dates = dates + 1;
            py.case_scraper.whoflunet(app.SublevelDropDown.Value, py.int(week(dates(1))));
            app.ProgressBar.Title = 'Formatting Data';
            case_data = readtable('FluNetInteractiveReport.csv').ALL_INF; % takes the column of the total influenza cases
            case_data(length(case_data) - 1:length(case_data)) = []; % removes last 2 weeks of data since reporting is lagged
            dates(length(dates) - 1:length(dates)) = [];
        elseif strcmp(app.SublevelDropDown.Value, 'United States of America') || strcmp(app.LevelDropDown.Value, 'United States of America')
            py.case_scraper.cdcwho(char(app.PredictionLevel.Value));
            app.ProgressBar.Title = 'Formatting Data';
            if strcmp(app.PredictionLevel.Value, 'National')
                case_data = timefix(readtable('ILINET.csv'), dates);
            else    
                case_data = statefix(readtable('ILINET.csv'), char(app.SublevelDropDown.Value));
                case_data = timefix(case_data, dates);
            end
            dates(length(case_data) + 1:length(dates)) = [];
        end
        if sum(isnan(case_data(length(case_data) - 12:length(case_data) - 3))) > 0 
            if app.PredictCounter ~= -1
                app.Alert = uiconfirm(app.UIFigure, 'Insufficient Data, there have been no reports by your area. This could be caused by a lack of cases, in which case assume little to no cases', 'Warning', 'Options', {'Continue', 'Stop'});
                if strcmp(app.Alert, 'Stop')
                    case_data = NaN;
                    return
                end
            end
        end
    elseif strcmp(app.DiseaseDropDown.Value, 'COVID-19')
%         py.case_scraper.get_covid_data()
        if strcmp(app.PredictionLevel.Value, 'National')
            try
                data = readtable('covid-19-data/us.csv');
            catch
                data = readtable('covid-19-data\us.csv');
            end
            case_data_total = data.cases;
        elseif strcmp(app.PredictionLevel.Value, 'State')
            try
                total_data = readtable('covid-19-data/us.csv');
            catch
                total_data = readtable('covid-19-data\us.csv');
            end
            data = total_data(strcmp(total_data.state, app.SublevelDropDown.Value), :);
            case_data_total = data.cases;
        end
        app.ProgressBar.Title = 'Formatting Data';
        str_dates = string(dates);
        i = 1;
        while(1)
            if str_dates(1) == data.date(i)
                break
            else
                i = i + 1;
                continue
            end
        end
        case_data_total = case_data_total(i:length(case_data_total), :);  
        case_data = total_to_weekly(case_data_total);
    end
    case_data(isnan(case_data)) = 0;
end
    

