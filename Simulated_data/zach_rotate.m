for i = 10:50
    spbimage = s.allDataCell{i,5};
    spb1 = s.allDataCell{i,1};
    spb2 = s.allDataCell{i,2};
    kinetimage = s.allDataCell{i,6};
    kinet1 = s.allDataCell{i,3};
    kinet2 = s.allDataCell{i,4};
    [finalspbimage,~,~,finalkinetimage,~,~] = rotatethis(spbimage,spb1,spb2,kinetimage,kinet1,kinet2);
    imshowpair(max(finalspbimage,[],3),max(finalkinetimage,[],3))
    w = waitforbuttonpress;
end