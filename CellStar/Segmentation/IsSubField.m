%     Copyright 2012, 2015 Cristian Versari (cristian.versari@univ-lille1.fr)
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


function isDefined = IsSubField(myvar, fieldList)
  % given a variable and a cell of field, subfield, subsubfield, ...
  % returns true if myvar.field.subfield.subsubfield.... is defined

  isDefined = true;
  currVar = myvar;
  for i = 1:size(fieldList(:), 1)
      if isDefined
          if isfield(currVar, fieldList{i})
              currVar = currVar.(fieldList{i});
          else
              isDefined = false;
          end
      end
  end
end
