function visSelection(spotStructArray, img1Mat, img2Mat)

dataCell = spotStructArray.dataCell;
figure;
for n=2:size(dataCell,1)
    for i = 1:4
        subplot(1,4,i);
        display(n);
        plane = dataCell{n,i}(3);
        if i == 1 %to center image around first channel's first spot
            midX = dataCell{n,i}(2) + 50; %adjusted by 50 for padding of image
            midY = dataCell{n,i}(1) + 50;
        end
        %To prevent indexing errors, pad image with 50 edge pixel value
        if i < 3
            imgPlane = img1Mat(:,:,plane);
        else
            imgPlane = img2Mat(:,:,plane);
        end
        imgPlane = padarray(imgPlane,[50, 50],'replicate','both');
        imshow(imgPlane(midY-50:midY+50, midX-50:midX+50), []);
        hold on;
        %parse out and adjust coorindates of each spot
        X = dataCell{n,i}(2) + 50;
        Y = dataCell{n,i}(1) + 50;
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
        scatter(X - midX + 51, Y - midY + 51, marker);
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
end