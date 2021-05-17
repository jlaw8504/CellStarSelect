function [finalspbimage,newspb1,newspb2,finalkinetimage,newkinet1,newkinet2] = rotatethis(spbimage,spb1,spb2,kinetimage)
%find spb foci midpoint and shift until its centered in the image
spbrot_centery = size(spbimage,1)./2; 
spbrot_centerx = size(spbimage,2)./2;
spbrot_center = [spbrot_centery,spbrot_centerx];
spbmidpoint = ((spb1(1:2))+(spb2(1:2)))./2; 
spbdist = round(spbrot_center - spbmidpoint);
imspb1 = spb1(1:2) + spbdist(1:2);
imspb2 = spb2(1:2) + spbdist(1:2);
imspbmidpoint = spbmidpoint(1:2) + spbdist(1:2);
if imspb1(1)>imspb2(1)
    if ((imspb1(2) - imspbmidpoint(2)) == 0) && ((imspb1(1) - imspbmidpoint(1)) > 0)
        theta = 90;
    elseif ((imspb1(2) - imspbmidpoint(2)) == 0) && ((imspb1(1) - imspbmidpoint(1)) == 0)
        theta = 0;
    else
        theta = rad2deg(atan((imspb1(1) - imspbmidpoint(1))/(imspb1(2) - imspbmidpoint(2))));
    end
elseif imspb2(1)>imspb1(1)
    if ((imspb2(2) - imspbmidpoint(2)) == 0) && ((imspb2(1) - imspbmidpoint(1)) > 0)
        theta = 90;
    elseif ((imspb2(2) - imspbmidpoint(2)) == 0) && ((imspb2(1) - imspbmidpoint(1)) == 0)
        theta = 0;
    else
        theta = rad2deg(atan((imspb2(1) - imspbmidpoint(1))/(imspb2(2) - imspbmidpoint(2))));
    end
else
        theta = 0;
end
%rotate
spbshifted = circshift(spbimage,spbdist);
%relocate the foci by adding the distance they were shifted
%find the theta for spb and kinet rotation
%rotate the spb image
finalspbimage = imrotate(spbshifted,theta, 'nearest','crop');
%% populate the zero values with mins from spbimage
finalspbimage(finalspbimage == 0) = min(spbimage(:));
%Locate rotated spb foci using advpointsource and then findvoxelmodified
mipspb = max(finalspbimage,[],3);
ptsrcimgspb = advPointSourceDetection(mipspb,2,0);
[imspbrows, imspbcolumns] = ind2sub(size(ptsrcimgspb), find(ptsrcimgspb));
if numel(imspbrows) ~= 2
    sigma = 1.9
    while numel(imspbrows) ~=2
        ptsrcimgspb = advPointSourceDetection(mipspb,sigma,0);
        [imspbrows, imspbcolumns] = ind2sub(size(ptsrcimgspb), find(ptsrcimgspb));
        sigma = sigma - 0.01
    end
end
[newspb1y,newspb1x,newspb1plane,newspb1intensity] = findVoxelModified([imspbrows(1),imspbcolumns(1)], finalspbimage, 5);
newspb1 = [newspb1y,newspb1x,newspb1plane,newspb1intensity];
[newspb2y,newspb2x,newspb2plane,newspb2intensity] = findVoxelModified([imspbrows(2),imspbcolumns(2)], finalspbimage, 5);
newspb2 = [newspb2y,newspb2x,newspb2plane,newspb2intensity];
%shift the kinet image until the foci midpoint is in the center of the
%image
kinetshifted = circshift(kinetimage,spbdist);
%rotate the kinet image until it lies on the x axis (ideally)
finalkinetimage = imrotate(kinetshifted,theta,'nearest','crop');
%% populate the zeros values with mins from kinetimage
finalkinetimage(finalkinetimage == 0) = min(kinetimage(:));
%Find foci again using advanced point source detection and then find voxel
%modified
mipkinet = max(finalkinetimage,[],3);
ptsrcimgkinet = advPointSourceDetection(mipkinet,2,0);
[imkinetrows, imkinetcolumns] = ind2sub(size(ptsrcimgkinet), find(ptsrcimgkinet));
if numel(imkinetrows) ~= 2
    sigma = 1.9
    while numel(imkinetcolumns) ~=2
        ptsrcimgkinet = advPointSourceDetection(mipkinet,sigma,0);
        [imkinetrows, imkinetcolumns] = ind2sub(size(ptsrcimgkinet), find(ptsrcimgkinet));
        sigma = sigma - 0.01
    end
end
[newkinet1y,newkinet1x,newkinet1plane,newkinet1intensity] = findVoxelModified([imkinetrows(1),imkinetcolumns(1)], finalkinetimage, 5);
newkinet1 = [newkinet1y,newkinet1x,newkinet1plane,newkinet1intensity];
[newkinet2y,newkinet2x,newkinet2plane,newkinet2intensity] = findVoxelModified([imkinetrows(2),imkinetcolumns(2)], finalkinetimage, 5);
newkinet2 = [newkinet2y,newkinet2x,newkinet2plane,newkinet2intensity];
end