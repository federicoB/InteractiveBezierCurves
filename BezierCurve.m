classdef BezierCurve < handle
    %BEZIERCURVE Class for handling bezier curves
    properties (Constant)
        numberOfEvaluationPoints=1000;
    end
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
            linearSpace=linspace(0,1,this.numberOfEvaluationPoints);
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
                normalized(i) = norm (distance(i));
            end
            [~,index] = min(normalized);
            pointX = this.xValues(index);
            pointY = this.yValues(index);
            xderivative = this.xDerivative(index);
            yderivative = this.yDerivative(index);
        end
        
        function tangent = getTangent(this,x,y)
           [x,y,derivative(1),derivative(2)] = this.getDerivativeValue(x,y);
           linearSpace = linspace(-1,1,this.numberOfEvaluationPoints);
           derivative(1)=derivative(1)/norm(derivative);
           derivative(2)=derivative(2)/norm(derivative);
           tangent(1,:) = x+derivative(1)*(linearSpace);
           tangent(2,:) = y+derivative(2)*(linearSpace);
        end
        
        function normal = getNormal(this,x,y)
           [x,y,derivative(1),derivative(2)] = this.getDerivativeValue(x,y);
           linearSpace = linspace(-1,1,this.numberOfEvaluationPoints);
           derivative(1)=-derivative(2)/derivative(1);
           derivative(2)=1;
           normal(1,:) = x+derivative(1)*(linearSpace);
           normal(2,:) = y+derivative(2)*(linearSpace);
        end
        
        function value=getLength(this)
            value = integral(@(x) myfun(this,x),0,1,'ArrayValued',true);
            function val = myfun(this,x)
                %mapping
                index = round(x*this.numberOfEvaluationPoints);
                if (index<=this.numberOfEvaluationPoints-1 && index>0) 
                    xderiv = this.xDerivative(index); 
                    yderiv = this.yDerivative(index);
                    val = norm([xderiv,yderiv]);
                else 
                    val = 0;
                end
            end
        end
        
    end
    
end

