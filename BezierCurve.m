classdef BezierCurve
    %BEZIERCURVE Class for handling bezier curves
    
    properties
        %initialize control points to empty vector
        controlPoints=[];
        %default curve is not closed
        closedCurve=0;
    end
    
    methods
        function bezierCurve = calculateBezier(obj)
            %CALCULATEBEZIER Create a Bezier courve given a vector of control points.

            %the curve will have a degree of qx-1 point
            %get the length of first row of controlPoints
            numberOfPoints=size(obj.controlPoints,2) - 1;
            %TODO use the min x e max y of control points instead of 0 and 1 
            %create a vector of 100 equally spaced points between 0 and 1 
            linearSpace=linspace(0,1,100);
            %calculate Bernstein base polynomial of grade equal to the number of
            %control points -1 and evaluated in the linear space t.
            bernsteinBase=bernstein(numberOfPoints,linearSpace);
            %calculate the vector of x positions of the curve
            bezierCurve(1,:)=bernsteinBase*obj.controlPoints(1,:)';
            %calculate the vector of y positions of the curve
            bezierCurve(2,:)=bernsteinBase*obj.controlPoints(2,:)';
        end
    end
    
end

