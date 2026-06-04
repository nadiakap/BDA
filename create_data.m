% 1. Define your large raw dataset file name
fullDataFile = 'yellow_tripdata_2026-01.csv'; 

% 2. Create a datastore to read the massive file block-by-block
ds = tabularTextDatastore(fullDataFile);
% 1. Set the chunk size property to 50,000 rows
ds.ReadSize = 50000;
% 3. Extract just the first 50,000 rows for your demonstration
firstChunk = read(ds);



% 5. Write the subset to a CSV file
writetable(firstChunk, 'taxi_data_subset.csv');
disp('taxi_data_subset.csv created successfully!');
