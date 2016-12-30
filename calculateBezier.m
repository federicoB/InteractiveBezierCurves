function bezierCurve = calculateBezier( controlPoints, numberOfPoints )
%CALCULATEBEZIER Create a Bezier courve given a vector of control points.

%the curve will have a degree of qx-1 point
numberOfPoints=numberOfPoints - 1;
%TODO use the min x e max y of control points instead of 0 and 1 
%create a vector of 100 equally spaced points between 0 and 1 
linearSpace=linspace(0,1,100);
%calculate Bernstein base polynomial of grade equal to the number of
%control points -1 and evaluated in the linear space t.
bernsteinBase=bernstein(numberOfPoints,linearSpace);
%calculate the vector of x positions of the curve
bezierCurve(1,:)=bernsteinBase*controlPoints(1,:)';
%calculate the vector of y positions of the curve
bezierCurve(2,:)=bernsteinBase*controlPoints(2,:)';

end

