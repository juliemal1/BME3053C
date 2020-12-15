%Training the data
clc; clear;  
datapath = fullfile('/Users/juliemallinger 1/Desktop/newcovidimages_2/'); 
imds = imageDatastore(datapath, 'IncludeSubfolders', true, 'LabelSource', 'foldernames'); 
rng(0); 
imds.ReadFcn = @customReadDatastoreImage; 
imds = shuffle(imds); 
[imdsTrain, imdsVal, imdsTest] = splitEachLabel(imds, 0.7, 0.15, 0.15); 
imdssavepath = fullfile('/Users/juliemallinger 1/Desktop/imdsvars.mat');
save(imdssavepath, 'imdsTrain', 'imdsVal', 'imdsTest');
function data_final = customReadDatastoreImage(filename)

data = imread(filename); 
if ndims(data)== 3
    data = rgb2gray(data);   
end 
data = imresize(data, [227, 227]); 
data = double(data); 
data_min = min(data(:)); 
data_max = max(data(:)); 
data = (data - data_min) / (data_max-data_min); 
data = data*255; 
data_final = zeros(227, 227, 3); 
data_final(:, :, 1) = data; 
data_final(:, :, 2) = data;
data_final(:, :, 3) = data;
data_final = uint8(data_final); 
end 
