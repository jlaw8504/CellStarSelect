function paddedPolygon = padPolygon(inPolygon, inPolygonXY, imSize)
%%This funciton creates binary mask of inPolygon the size of the orginal
%%image

prePad = padarray(inPolygon, inPolygonXY-1, 'pre');
postPadSize = imSize - size(prePad);
paddedPolygon = padarray(prePad, postPadSize, 'post');