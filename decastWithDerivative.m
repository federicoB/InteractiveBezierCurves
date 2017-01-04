function [y,yd] = decastWithDerivative( coefLength,points )
%DECASTWITHDERIVATIVE evaluate the value of the polyonomial and derivative
% evaluate the value of the polyonomial and derivative given the
% polyonimal's coefficents and evaluation points.

coefLength=length(coef);
grade=coefLength-1;
numberOfPoints=length(points);
%for each point
for i=1:numberOfPoints
 w=coef;
 d1=points(i);
 d2=1.0-points(i);
 for j=1:grade
  for k=1:grade-j+1
   w(k)=d1.*w(k+1)+d2.*w(k);
  end
 end
 y(i)=w(1);
 yd(k)=grade(w(2)-w(1))/d2;
end

