function reviewSelection(allDataCell)
%reviewSelection Visualize the images and coordinate selection after
%CellStarSelection pipeline
%   Iterate over the images and coordinate data and display a scatterplot.

%% Open figure window
h = figure;
%% Loop over each row of allDataCell array
for n = 2:size(allDataCell,1)
    for i = 1:4
        subplot(1,4,i);
        plane = allDataCell{n,i}(3);
        if i < 3
            imgPlane = allDataCell{n,5}(:,:,plane);
        else
            imgPlane = allDataCell{n,6}(:,:,plane);
        end
        imshow(imgPlane, []);
        hold on;
        %parse out and adjust coorindates of each spot
        X = allDataCell{n,i}(2);
        Y = allDataCell{n,i}(1);
        switch i
            case 1
                marker = 'go';
            case 2
                marker = 'go';
            case 3
                marker = 'rx';
            case 4
                marker = 'rx';
        end
        scatter(X, Y, marker);
        hold off;
        if i == 1
            title('Image 1, Spot 1');
        elseif i == 2
            title('Image 1, Spot 2');
        elseif i == 3
            title('Image 2, Spot 1');
        elseif i == 4
            title('Image 2, Spot 2');
        end
    end
    waitforbuttonpress;
    
end
close(h);
end

