function visSelection(spotStructArray, img1Mat, img2Mat)

dataCell = spotStructArray.dataCell;
figure;
for n=2:size(dataCell,1)
    for i = 1:4
        subplot(1,4,i);
        display(n);
        plane = dataCell{n,i}(3);
        X = dataCell{n,i}(2);
        Y = dataCell{n,i}(1);
        if i < 3
            try
                imshow(img1Mat(Y-49:Y+49,X-49:X+49,plane),[]);
            catch
                imshow(img1Mat(Y-24:Y+24,X-24:X+24,plane),[]);
            end
        else
            try
                imshow(img2Mat(Y-49:Y+49,X-49:X+49,plane),[]);
            catch
                imshow(img2Mat(Y-24:Y+24,X-24:X+24,plane),[]);
            end
        end
        hold on;
        scatter(dataCell{n,i}(1), dataCell{n,i}(2));
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