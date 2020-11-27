clc; clear; close all;

jsonfolderpath = fullfile('/Users/juliemallinger 1/Desktop/covid-19-xray-dataset-master/annotations/all-images/'); %from github
allimagespath = fullfile('/Users/juliemallinger 1/Desktop/images/'); %from command line download
maskfolderpath = fullfile('/Users/juliemallinger 1/Desktop/covid-19-xray-dataset-master/annotations/all-images-semantic-masks/'); %from github

outputpath = fullfile('/Users/juliemallinger 1/Desktop/newcovidimages_2/'); %this will create sub-folders of covid & healthy
covidsavepath = fullfile(outputpath,'covid');
healthysavepath = fullfile(outputpath,'healthy');

if ~exist(outputpath,'dir'),mkdir(outputpath);end
if ~exist(covidsavepath,'dir'),mkdir(covidsavepath);end
if ~exist(healthysavepath,'dir'),mkdir(healthysavepath);end

jsonfiles = dir(jsonfolderpath);

for idx = 1: length(jsonfiles)
    jsonfile = jsonfiles(idx);
    jsonfilename = jsonfile.name;
    if strcmp(jsonfilename(1),'.'), continue; end % skip if not important 
    
    % read json information and find out if an image is covid or not
    jsonvals = jsondecode(fileread(fullfile(jsonfile.folder,jsonfilename)));
    iscovid = false;
    tags = jsonvals.annotations;
    for tagidx = 1:length(tags)
        if iscell(tags)
            tag = tags{tagidx,1};
        else
            tag = tags(tagidx);
        end
        
        if isfield(tag,'name')
            tagname = tag.name;
            if strcmp(tagname,'COVID-19')
                iscovid = true;
            end
        end
    end
    
    % find the mask for the same image
    % the mask has the same name as the json file
    [~,imgname,~] = fileparts(fullfile(jsonfile.folder,jsonfile.name));
    maskimgpath = fullfile(maskfolderpath,strcat(imgname,'.png'));
    maskimg = imread(maskimgpath);
    mask = logical(maskimg); %converts from uint8 to binary
    
    % find the lung image
    imgfilepath = jsonvals.image.filename;
    imgfilepath = fullfile(allimagespath,imgfilepath);
    lungimg = imread(imgfilepath);
    if ndims(lungimg)==3
        lungimg = rgb2gray(lungimg);
    end    
    %lungimgstore = lungimg; %delete if not showing the figure
    
    % apply mask to lung image
    lungimg(~mask) = 0; % everywhere on the lung image that's not the lung, turn to black 
    
    % apply preprocessing steps
    newlungimg = lungimg;
    lungimg(newlungimg==255)= 0; 
    
     
    if all(lungimg(:)==0)
        continue; 
    end 
    
      
    
    % save the final image
    [~,savename,~] = fileparts(imgfilepath);
    savename = strcat(savename,'.png');
    
    if iscovid
        savepath = fullfile(covidsavepath,savename);
    else
        savepath = fullfile(healthysavepath,savename);
    end
    
%     figure; %comment this section out if you don't want to see the figure
%     subplot(121);imshow(lungimgstore);%title('original image');
%     if iscovid, title('covid'); else, title('healthy'); end
%     subplot(122);imshow(lungimg);title('segmented image');
%     pause;
%     close all;
    
    imwrite(lungimg,savepath);
    fprintf('done saving %g of %g images\n',idx,length(jsonfiles));
end

disp('all done!');   
    
    