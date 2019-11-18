function [finalimage, imSPB1, imSPB2] = rotateimage(image, spb1, spb2)
    if spb1(2)>= spb2(2)
        spbMidx = ((spb1(2) - spb2(2))/2) +spb2(2);
    elseif spb2(2) > spb1(2)
        spbMidx = ((spb2(2) - spb1(2))/2)+spb1(2);
    end
    if spb1(1)>= spb2(1)
        spbMidy = ((spb1(1) - spb2(1))/2)+spb2(1);
    elseif spb2(1) > spb1(1)
        spbMidy = ((spb2(1) - spb1(1))/2)+spb1(1);
    end
    [height, width, ~] = size(image);
    centerx = width/2;
    centery = height/2;
    if spb1(1)>spb2(1)
        theta = rad2deg(atan((spb1(1) - spb2(1))/(spb1(2) - spb2(2))));
    elseif spb2(1)>spb1(1)
        theta = rad2deg(atan((spb2(1) - spb1(1))/(spb2(2) - spb1(2))));
    else
        theta = 0;
    end
    shiftx = round(spbMidx - centerx);
    shifty = round(spbMidy - centery);
    Xpad = abs(shiftx);
    Ypad = abs(shifty);
    padded = padarray(image, [Ypad, Xpad]);
    rot = imrotate(padded, theta, 'nearest', 'crop');
    finalimage = rot(Ypad+1-shifty:end-Ypad-shifty, Xpad+1-shiftx:end-Xpad-shiftx, :);
    %[SPB1y, SPB1x] = ind2sub(size(finalimage), find(finalimage(:,:,spb1(3)) == spbmax1));
    P1 = [spb1(2);spb1(1)];
    P2 = [spb2(2);spb2(1)];
    RotMatrix = [cosd(theta), sind(theta); -sind(theta), cosd(theta)];
    imagecenter = [round(centerx);round(centery)];
    RotatedP1 = round(RotMatrix*(P1 - imagecenter)) + imagecenter;
    RotatedP1coords = [RotatedP1(2),RotatedP1(1)];
    RotatedP2 = round(RotMatrix*(P2 - imagecenter)) + imagecenter;
    RotatedP2coords = [RotatedP2(2),RotatedP2(1)];
    [SPB1y,SPB1x,plane1,peakIntensity1] = findVoxelModified(RotatedP1coords, rot, 5); %FLIP roratedP1
    imSPB1 = [SPB1y,SPB1x,plane1,peakIntensity1];
    [SPB2y,SPB2x,plane2,peakIntensity2] = findVoxelModified(RotatedP2coords, rot, 5);
    imSPB2 = [SPB2y,SPB2x,plane2,peakIntensity2];
    %[SPB2y, SPB2x] = ind2sub(size(finalimage), find(finalimage(:,:,spb2(3)) == spbmax2));
    %imSPB2 = [SPB2y, SPB2x, spb2(3)];
end
%Credit: Most of this function was borrowed from Jan Motl (jan@motl.us) on
%GitHub in their function rotateAround