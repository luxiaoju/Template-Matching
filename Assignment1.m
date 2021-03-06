function [] = Assignment1(image_name)
%Assignment1 template
%   image_name       Full path/name of the input image (e.g. 'Test Image (1).JPG')


%% Load the input RGB image
input = imread(image_name);

%% Create a gray-scale duplicate into grayImage variable for processing
grayImage = rgb2gray(input);
figure
imshow(grayImage)

%% List all the template files starting with 'Template-' ending with '.png'
% Assuming the images are located in the same directory as this m-file
% Each template file name is accessible by templateFileNames(i).name
templateFileNames = dir('Template-*.png');

%% Get the number of templates (this should return 13)
numTemplates = length(templateFileNames);

%% Set the values of SSD_THRESH and NCC_THRESH
SSD_THRESH = 16000000; %can be changed depending on image
NCC_THRESH = .7; % can be changed depending on images

%% create position output matrices 
position_ncc = zeros(13,2);
position_ssd = zeros(13,2);
%% use a hardcoded CELL for the names
names = {['ACE']; ['EIGHT'];['FIVE']; ['FOUR']; ['JACK']; ['KING']; ['NINE']; ['Queen']; ['Seven']; ['SIX']; ['TEN']; ['Three']; ['Two']};
%% For each template, do the following
for i=1:numTemplates
    %% Load the RGB template image, into variable T 
    T = rgb2gray(imread(templateFileNames(i).name));
%     figure
%     imshow(T)
    %% Convert the template to gray-scale

    %% Extract the card name from its file name (look between '-' and '.' chars)
    % use the cardName variable for generating output images
    cardNameIdx1 = findstr(templateFileNames(i).name,'-') + 1;
    cardNameIdx2 = findstr(templateFileNames(i).name,'.') - 1;
    cardName = templateFileNames(i).name(cardNameIdx1:cardNameIdx2); 
    
    
    
    %% Find the best match [row column] using Sum of Square Difference (SSD)

 %% uncomment for normalized_ssd  
    
    [SSDrow, SSDcol] = SSD(int32(grayImage), int32(T), SSD_THRESH);
    display([SSDrow, SSDcol]);
    if SSDcol == 0 && SSDrow == 0
        SSDrow = 25*i;
    else
        SSDcol = SSDcol + randi(40);
        SSDrow = SSDrow + randi(40);
    end
    position_ssd(i,:) = [SSDcol, SSDrow];
   
%% uncomment/comment to use Normalized SSD

%    [SSDrow, SSDcol] = NSSD(int32(grayImage), int32(T), intmax);
%     display([SSDrow, SSDcol]);
%     if SSDcol == 0 && SSDrow == 0
%         SSDrow = 25*i;
%     else
%         SSDcol = SSDcol + randi(40);
%         SSDrow = SSDrow + randi(40);
%     end
%     position_ssd(i,:) = [SSDcol, SSDrow];

    
    %% Find the best match [row column] using Normalized Cross Correlation (NCC)

%% uncomment for NCC/ comment for SSD    
%  
    [NCCrow, NCCcol] = NCC(int32(grayImage), int32(T), NCC_THRESH);
    display([NCCrow, NCCcol]);
    if NCCcol == 0 && NCCrow == 0
        NCCrow = 25*i;
    else
        NCCcol = NCCcol + randi(40);
        NCCrow = NCCrow + randi(40);
    end
    position_ncc(i,:) = [NCCcol, NCCrow];

        
    
end

%% Create and Display the output images 
output_ncc = insertText(input,position_ncc,names,'FontSize',12,'BoxColor','yellow','BoxOpacity',0.4,'TextColor','white');
figure('Name','NCC','NumberTitle','off')
imshow(output_ncc);

output_ssd = insertText(input,position_ssd,names,'FontSize',12,'BoxColor','yellow','BoxOpacity',0.4,'TextColor','white');
figure('Name','SSD','NumberTitle','off')
imshow(output_ssd);


end

%% Implement the SSD-based template matching here
function [SSDrow, SSDcol] = SSD(grayImage, T, SSD_THRESH)
% inputs
%           grayImag        gray-scale image
%           T               gray-scale template
%           SSD_THRESH      threshold below which a match is accepted
% outputs
%           SSDrow          row of the best match (empty if unavailable)
%           SSDcol          column of the best match (empty if unavailable)

% get size information for images
[rows cols colorDepth ] = size(grayImage);
[m n colorDepth ] = size(T);

% init values
sumCurrent = 0;
SSDrow = 0;
SSDcol = 0;
min = SSD_THRESH;

%start loops
for row=1:rows-m+1
    for col=1:cols-n+1
        %create image section
        grayImageSection = grayImage(row:(row+m-1), col:(col+n-1));
        %calculate sum
        sumCurrent = sum(sum((T - grayImageSection).^2)); 
        % make sure only to use suitable values
        if sumCurrent <= min
                    min = sumCurrent;
                    SSDrow = row;
                    SSDcol = col;
        end
        sumCurrent = 0;
    end
end

end

function [SSDrow, SSDcol] = NSSD(grayImage, T, SSD_THRESH)
% inputs
%           grayImag        gray-scale image
%           T               gray-scale template
%           SSD_THRESH      threshold below which a match is accepted
% outputs
%           SSDrow          row of the best match (empty if unavailable)
%           SSDcol          column of the best match (empty if unavailable)

%get image size information
[rows cols colorDepth ] = size(grayImage);
[m n colorDepth ] = size(T);

%init values
sumCurrent = 0;
SSDrow = 0;
SSDcol = 0;
min = SSD_THRESH;

%start loops
for row=1:rows-m+1
    for col=1:cols-n+1
        %create image section
        grayImageSection = grayImage(row:(row+m-1), col:(col+n-1));
        %create normalized values (easier for later calc)
        T_norm = T - mean2(T);
        grayImage_norm = grayImageSection - mean2(grayImageSection);
        %compute both fractions
        side1 = T_norm / sqrt(sum(sum(T_norm.^2)));
        side2 = grayImage_norm / sqrt(sum(sum(grayImage_norm.^2)));
        %perform subtraction an calculate
        last = (side1 + -1 .* side2).^2;
        sumCurrent = sum(sum(last)); 
        %only use suitable values
        if sumCurrent <= min
                    min = sumCurrent;
                    SSDrow = row;
                    SSDcol = col;
        end
        sumCurrent = 0;
    end
end
end

%% Implement the NCC-based template matching here
function [NCCrow, NCCcol] = NCC(grayImage, T, NCC_THRESH)
% inputs
%           grayImag        gray-scale image
%           T               gray-scale template
%           NCC_THRESH      threshold above which a match is accepted
% outputs
%           NCCrow          row of the best match (empty if unavailable)
%           NCCcol          column of the best match (empty if unavailable)

%get image size information
[rows cols colorDepth ] = size(grayImage);
[m n colorDepth ] = size(T);

%init values
sumCurrent = 0;
NCCrow = 0;
NCCcol = 0;
max = NCC_THRESH;

%start loops
for row=1:rows-m+1
    for col=1:cols-n+1
        %create image section
        grayImageSection = grayImage(row:(row+m-1), col:(col+n-1));
        %create normalized values (easier for later calc)
        T_norm = T - mean2(T);
        grayImage_norm = grayImageSection - mean2(grayImageSection);
        %compute both top and bottom
        top = sum(sum(T_norm .* grayImage_norm));
        bot = sum(sum(T_norm .^2)) * sum(sum(grayImage_norm .^2));
        %perform calculations 
        sumCurrent = top/sqrt(bot);
        %only take suitable values
        if sumCurrent >= max
                    max = sumCurrent;
                    NCCrow = row;
                    NCCcol = col;
        end
        sumCurrent = 0;
    end
end

end

