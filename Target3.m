function refined_shape_detection
    clear;     % Clear all variables from the workspace
    clc;       % Clear the Command Window
    close all; % Close all open figure windows

    %% Identify non-accidental properties and segment regions of concavity

    %  1) Read the input image
    [filename, pathname] = uigetfile({'*.jpg;*.png;*.bmp','Image Files (*.jpg,*.png,*.bmp)'}, ...
        'Select an image file');
    if isequal(filename,0)
        disp('User selected Cancel');
        return;
    else
        disp(['User selected ', fullfile(pathname, filename)]);
    end
    img = imread(fullfile(pathname, filename));

    %  2) Convert image to grayscale
    if size(img, 3) == 1 || isequal(img(:,:,1), img(:,:,2), img(:,:,3))
        disp('The image is grayscale or black and white.');
        
        % Invert the grayscale image
        imgInvert = imcomplement(img);
        % Convert to grayscale 
        grayI = rgb2gray(imgInvert);
    else
        disp('The image is a color image.');
        
        % Convert to HSV and then to grayscale
        I_hsv = rgb2hsv(img);
        grayI = rgb2gray(I_hsv);
    end

    %  3) Enhance contrast for better feature visibility
    grayI = imadjust(grayI);

    %  4) Binarize and remove small noise
    bwImg = imbinarize(grayI);
    bwImg = bwareaopen(bwImg, 20);

    %  5) Perform distance transform and watershed
    D = -bwdist(~bwImg);
    % Suppress small local minima
    D = imhmin(D, 2);
    % Initial watershed
    L = watershed(D);
    bwImg(L == 0) = 0;

    % Optional morphological refinements
    se = strel('disk',3);
    bg = imerode(bwImg,se);
    fg = imdilate(bwImg,se);
    markers = bg;
    markers(fg) = 2;
    % Re-apply watershed
    L = watershed(D);
    L(~bwImg) = 0;

    % Create a colored label matrix for visualization
    rgbSeg = label2rgb(L, 'jet', 'w', 'shuffle');

    %  6) Display original and segmented images side by side
    figure;
    imshowpair(img, rgbSeg, 'montage');
    title('Original and Segmented Image');

    %% Matching components to objectives representation and object identifcation 

    %  7) Find boundaries and label connected components
    [B,L] = bwboundaries(bwImg, 'noholes');
    props = regionprops(L, 'Area','Perimeter','BoundingBox','Centroid');
    
    %  8) Visualize detected shapes on the original image
    figure;
    imshow(img);
    hold on;
    title('Final Detection with Shape Outlines and Classifications');

    % Loop over each object in the image
    for k = 1 : length(B)
        boundary    = B{k};          % boundary coordinates for object k
        area_k      = props(k).Area;
        perim_k     = props(k).Perimeter;
        bbox        = props(k).BoundingBox;
        centroid_k  = props(k).Centroid;

        width       = bbox(3);
        height      = bbox(4);
        aspectRatio = width / height;
        
        % RBC-inspired metrics
        circleMetric = (perim_k^2) / area_k; 
        boundingBoxArea = width * height;
        extent = area_k / boundingBoxArea;

        %  9) Classify the shape
        if abs(circleMetric - 4*pi) < 2
            shapeType = 'Circle';
        elseif abs(aspectRatio - 1) < 0.2 && extent > 0.85
            shapeType = 'Square';
        elseif extent < 0.65
            shapeType = 'Triangle';
        else
            shapeType = 'Rectangle';
        end

        % Plot the boundary outline of this shape
        plot(boundary(:,2), boundary(:,1), 'r', 'LineWidth', 2);

        % Create a label that includes classification and metrics
        labelStr = sprintf('%s\nArea=%.1f\nPerim=%.1f\nAR=%.2f',...
            shapeType, area_k, perim_k, aspectRatio);

        % Display the label near the shape centroid
        text(centroid_k(1), centroid_k(2), labelStr, ...
             'Color','yellow','FontWeight','bold', 'FontSize',10, ...
             'HorizontalAlignment','center');
    end
    
    hold off;

end