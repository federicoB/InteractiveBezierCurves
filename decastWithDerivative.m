% This file is part of Interactive Bezier Curves.
% 
%     Interactive Bezier Curves is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     Interactive Bezier Curves is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with Nome-Programma.  If not, see <http://www.gnu.org/licenses/>.

function [y,yd] = decastWithDerivative( coef,points )
%DECASTWITHDERIVATIVE evaluate the value of the polyonomial and derivative
% evaluate the value of the polyonomial and derivative given the
% polyonimal's coefficents and evaluation points.

coefLength=length(coef);
grade=coefLength-1;
numberOfPoints=length(points);
%for each point
for i=1:numberOfPoints
 %the initial row is made by the coefficients
 w=coef;
 %get current evaluation point
 d1=points(i);
 %calculates its complementary to one
 d2=1.0-points(i);
 for j=1:grade
  %every new row is shorter of 1 because is a triangular construction 
  for k=1:grade-j+1
   %the formula is https://wikimedia.org/api/rest_v1/media/math/render/svg/5634c700f37bf9bd30ab82043bf18a102bbf93a2  
   w(k)=d1.*w(k+1)+d2.*w(k);
  end
 end
 %the value of the polynomial at the i point is the first element(the top
 %of the triangular)
 y(i)=w(1);
 %the derivative at the point i 
 yd(i)=grade*(w(2)-w(1))/d2;
end
%calculate last point derivative
yd(end)=grade*(coef(end)-coef(end-1));