function fixed_data = total_to_weekly(data)
fixed_data = [];
for i = 8:7:length(data)
    fixed_data = [fixed_data; data(i) - data(i - 7)];
end
return 
