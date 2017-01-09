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
            %find the neares point and get it derivative
            %create array of distance between the searched point and the
            %evaluated point
            distance = [(this.xValues-x)',(this.yValues-y)'];
            %calculate norm of each pair
            for i=1:length(distance);
                normalized(i) = norm (distance(i));
            end
            %fid the minimum value (least squares distance)
            [~,index] = min(normalized);
            %get coordinate value
            %return also this for draw precisely the tangent/normal
            pointX = this.xValues(index);
            pointY = this.yValues(index);
            %get derivative value
            xderivative = this.xDerivative(index);
            yderivative = this.yDerivative(index);
        end
        
        function tangent = getTangent(this,x,y)
            %get derivative at the given points
           [x,y,derivative(1),derivative(2)] = this.getDerivativeValue(x,y);
           %linear space between [-1,1] instead of [0,1] for drawing also a backward line
           linearSpace = linspace(-1,1,this.numberOfEvaluationPoints);
           %normalize vector
           derivative(1)=derivative(1)/norm(derivative);
           derivative(2)=derivative(2)/norm(derivative);
           %create line
           tangent(1,:) = x+derivative(1)*(linearSpace);
           tangent(2,:) = y+derivative(2)*(linearSpace);
        end
        
        function normal = getNormal(this,x,y)
            %get derivative value at the given points
           [x,y,derivative(1),derivative(2)] = this.getDerivativeValue(x,y);
           linearSpace = linspace(-1,1,this.numberOfEvaluationPoints);
           %determine ortogonal vector
           derivative(1)=-derivative(2)/derivative(1);
           derivative(2)=1;
           %normalize vector
           derivative = derivative./norm(derivative);
           %create line
           normal(1,:) = x+derivative(1)*(linearSpace);
           normal(2,:) = y+derivative(2)*(linearSpace);
        end
        
        function value=getLength(this)
            %function to get the norm of the derivatives
            function val = funToIntegrate(this,x)
                %mapping index from [0,1] to [1,1000]
                index = round((x*(this.numberOfEvaluationPoints-1))+1);
                xderiv = this.xDerivative(index);
                yderiv = this.yDerivative(index);
                val = norm([xderiv,yderiv]);
            end
            %get left extreme function value
            fa = funToIntegrate(this,0);
            %get right extreme function value
            fb = funToIntegrate(this,1);
            %get not composite integral initial value
            trapez = trapezoid(0,1,fa,fb);
            %get integral value with numeric integration
            value = trapezoid_adapt(@(x) funToIntegrate(this,x),0,1,fa,fb,0.001,trapez);  
        end
        
    end
    
end

