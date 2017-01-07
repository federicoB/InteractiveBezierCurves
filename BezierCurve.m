classdef BezierCurve < handle
    %BEZIERCURVE Class for handling bezier curves
    
    properties
        %initialize control points to empty vector
        controlPoints=[];
        %default curve is not closed
        closedCurve=0;
        xValues;
        yValues;
        xDerivative;
        yDerivative;
    end
    
    methods
        function bezierCurve = calculateBezier(this)
            %create a vector of 100 equally spaced points between 0 and 1 
            linearSpace=linspace(0,1,1000);
            %calculate the vector of x positions of the curve
            [this.xValues, this.xDerivative]=decastWithDerivative(this.controlPoints(1,:),linearSpace);
            %calculate the vector of y positions of the curve
            [this.yValues, this.yDerivative]=decastWithDerivative(this.controlPoints(2,:),linearSpace);
            bezierCurve(1,:) = this.xValues;
            bezierCurve(2,:) = this.yValues;
        end
        
        function [pointX,pointY,xderivative,yderivative] = getDerivativeValue(this,x,y)
            distance = [(this.xValues-x)',(this.yValues-y)'];
            for i=1:length(distance);
                normal(i) = norm (distance(i));
            end
            [~,index] = min(normal);
            pointX = this.xValues(index);
            pointY = this.yValues(index);
            xderivative = this.xDerivative(index);
            yderivative = this.yDerivative(index);
        end
        
        function tangent = getTangent(this,x,y)
           [x y derivative(1),derivative(2)] = this.getDerivativeValue(x,y);
           linearSpace = linspace(-1,1,100);
           t(1)=derivative(1)/norm(derivative);
           t(2)=derivative(2)/norm(derivative);
           %t = [xderivative,yderivative]/norm([xderivative,yderivative]);
           tangent(1,:) = x+t(1)*(linearSpace);
           tangent(2,:) = y+t(2)*(linearSpace);
        end
    end
    
end

