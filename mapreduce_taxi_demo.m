%% 1. Create a Datastore (Mimics HDFS Pointer)
% This creates a pointer to the data without loading it into RAM
%ds = tabularTextDatastore('yellow_tripdata_2026-01.csv');

ds = tabularTextDatastore('taxi_data_subset.csv');

% 2. Print all available column names to the command window
%disp(ds.VariableNames') 
ds.SelectedVariableNames = {'tpep_pickup_datetime', 'fare_amount', 'tip_amount'};

%% 2. Define Local Execution Environment
% This forces MATLAB to use the local laptop CPU cores
mapreducer(0);

%% 3. Run MapReduce
% Results are written to a lightweight output datastore
hourlyTipResults = mapreduce(ds, @taxiMapFcn, @taxiReduceFcn);
finalTable = readall(hourlyTipResults);
disp(finalTable);

%% 4. Map Function (taxiMapFcn.m)
function taxiMapFcn(data, ~, intermKVStore)
   % Extract columns from the current chunk
   hours = hour(datetime(data.tpep_pickup_datetime));
   fare = data.fare_amount;
   tip = data.tip_amount;
   
   % Loop through the current chunk and emit key-value pairs
   for i = 1:height(data)
       if fare(i) > 0 % Avoid division by zero
           % Key: Hour (0-23)
           % Value: [Tip Amount, Fare Amount]
           add(intermKVStore, hours(i), [tip(i), fare(i)]);
       end
   end
end

%% 5. Reduce Function (taxiReduceFcn.m)
function taxiReduceFcn(key, intermValIter, finalKVStore)
   totalTip = 0;
   totalFare = 0;
   
   % Retrieve and aggregate all values passed from the Shuffling phase
   while hasnext(intermValIter)
       values = getnext(intermValIter);
       totalTip = totalTip + values(1);
       totalFare = totalFare + values(2);
   end
   
   % Calculate final metric for this specific hour key
   avgTipPercent = (totalTip / totalFare) * 100;
   add(finalKVStore, key, avgTipPercent);
end
 