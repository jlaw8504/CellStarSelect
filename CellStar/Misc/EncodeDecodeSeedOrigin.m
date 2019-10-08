%     Copyright 2014, 2015 Cristian Versari
%
%     This file is part of CellStar.
%
%     CellStar is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     CellStar is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with CellStar.  If not, see <http://www.gnu.org/licenses/>.

function mapped = EncodeDecodeSeedOrigin(toMap)
    map = { ...
            'border' ...
            'content' ...
            'borderNoSegments' ...
            'contentNoSegments' ...
            'centroids' ...
            'hough' ...
            'mouseclick' ...
            'mouseedit' ...
            'starparameteroptimization' ...
            'rankingparameteroptimization' ...
            'border_rand' ...
            'content_rand' ...
            'borderNoSegments_rand' ...
            'contentNoSegments_rand' ...
            'centroids_rand' ...
            'hough_rand' ...
            'mouseclick_rand' ...
            'mouseedit_rand' ...
            'starparameteroptimization_rand' ...
            'rankingparameteroptimization_rand' ...
            'unknown' ...
          };

   if isnumeric(toMap)
       if toMap > length(map)
           disp(['DecodeSeedOrigin: unknown code ' num2str(toMap)]);
       end
        idx = min(toMap, length(map));
        mapped = map{idx};
   else
       which = strcmp(toMap, map);
       if any(which)
           mapped = find(which);
       else
           disp(['DecodeSeedOrigin: unknown origin ' toMap]);
           mapped = length(map);
       end
   end
end
