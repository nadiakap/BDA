
% 1. Create a datastore pointing to all text files in your data folder
% We use fileDatastore because it handles raw, unformatted text files easily.
dataFolder = './gutenberg_files';
ds = fileDatastore(dataFolder, 'ReadFcn', @readTextFile, 'FileExtensions', '.txt');

% 2. Run the MapReduce operation
% MATLAB automatically uses your local CPU cores if Parallel Computing Toolbox is open.
disp('Starting MapReduce word count...');
tic;
mapReduceResult = mapreduce(ds, @wordCountMapper, @wordCountReducer);
toc;

% 3. Display the top 10 most frequent words
resultTable = readall(mapReduceResult);
sortedTable = sortrows(resultTable, 'Value', 'descend');
disp('Top 10 Words:');
disp(sortedTable(1:10, :));


% --- Helper function to read raw text chunks ---
function data = readTextFile(filename)
    % Reads an entire text file into a string array line-by-line
    % 'native' occupies the 3rd position so 'encoding' can safely follow
    fid = fopen(filename, 'r', 'native', 'UTF-8');
    
    % Ensure the file closes even if an error occurs later
    cleanUp = onCleanup(@() fclose(fid));
    
    % Read lines from the file
    textLines = textscan(fid, '%s', 'Delimiter', '\n', 'Whitespace', '');
    data = string(textLines{1});
end

function wordCountMapper(data, ~, intermKVStore)
    % data: A string array containing the lines of a single text file.
    % intermKVStore: The framework's intermediate key-value storage.
    
    % 1. Combine all lines into a single piece of text and lowercase it
    fullText = lower(join(data, ' '));
    
    % 2. Remove punctuation using a regular expression
    cleanText = regexprep(fullText, '[\\.\?\,\!\:\;\(\)\"\-\_\[\]]', ' ');
    
    % 3. Split the cleaned text into individual words by spaces
    words = split(cleanText);
    
    % 4. Remove empty strings resulting from double spaces
    words(words == "") = [];
    
    % 5. Emit a key-value pair for every word found
    for i = 1:numel(words)
        add(intermKVStore, words(i), 1);
    end
end

function wordCountReducer(key, intermValIter, outKVStore)
    % key: A unique word (e.g., "the")
    % intermValIter: An iterator pointing to all the values (1, 1, 1...) for this word
    % outKVStore: The final destination for the results
    
    wordCount = 0;
    
    % Loop through the iterator and sum the values
    while hasnext(intermValIter)
        wordCount = wordCount + getnext(intermValIter);
    end
    
    % Save the final count for this specific word
    add(outKVStore, key, wordCount);
end