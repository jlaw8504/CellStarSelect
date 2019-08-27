%perimeter background subtraction
x=data_cell{2,1}(1)
y=data_cell{2,1}(2)

fivebyfive=plane(x-2:x+2,y-2:y+2)
sevenbyseven=plane(x-3:x+3,y-3:y+3)

int_intensity_5=sum(fivebyfive(:))
int_intensity_7=sum(sevenbyseven(:))

F_bg=(int_intensity_5-int_intensity_7)*(25/49)
area_btwn= 49-25
F_bg= (int_intensity_7-int_intensity_5)/(25/area_btwn)
F_fg= int_intensity_5-F_bg