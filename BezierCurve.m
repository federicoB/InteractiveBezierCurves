classdef BezierCurve
    %BEZIERCURVE Class for handling bezier curves
    
    properties
        %initialize control points to empty vector
        controlPoints=[];
        %default curve is not closed
        closedCurve=0;
        xDerivative;
        yDerivative;
    end
    
    methods
        function bezierCurve = calculateBezier(obj)
            %create a vector of 100 equally spaced points between 0 and 1 
            linearSpace=linspace(0,1,100);
            %calculate the vector of x positions of the curve
            [bezierCurve(1,:), obj.xDerivative]=decastWithDerivative(obj.controlPoints(1,:),linearSpace);
            %calculate the vector of y positions of the curve
            [bezierCurve(2,:), obj.yDerivative]=decastWithDerivative(obj.controlPoints(2,:),linearSpace);
        end
        
        function tangent = getTangent(obj,x,y)
           
        end
    end
    
end

