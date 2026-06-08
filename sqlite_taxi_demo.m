% 1. Load the CSV file into a MATLAB table
% (Assuming 'pickup_datetime' and 'tip_amount' are in the CSV)
%taxiData = readtable('taxi_data_subset.csv');

% 2. Create and connect to an SQLite database file
%bfile = 'nyctaxi.db';
%conn = sqlite(dbfile, 'create');

% 3. Write the MATLAB table to the SQLite database
%tableName = 'taxi_trips';
%sqlwrite(conn, tableName, taxiData);

dbfile = 'nyctaxi.db';
conn = sqlite(dbfile, 'connect');

% 1. Construct the SQL query to calculate average tip per hour
sqlQuery = sprintf([...
    'SELECT strftime(''%%H'', tpep_pickup_datetime) AS trip_hour, ' ...
    '(SUM(tip_amount) / SUM(fare_amount)) * 100 AS avg_tip ' ...
    'FROM %s ' ...
    'GROUP BY trip_hour ' ...
    'ORDER BY trip_hour ASC'], tableName);

% 2. Execute the query and store the results in a MATLAB table
hourlyTips = fetch(conn, sqlQuery);

% 3. View or plot the results
disp(hourlyTips);
bar(str2double(hourlyTips.trip_hour), hourlyTips.avg_tip);
xlabel('Hour of the Day');
ylabel('Average Tip ($)');

% 4. Close the connection when done
close(conn);
