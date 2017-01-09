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
classdef Application < handle
    %APPLICATION
    
    properties
        bezierCurves;
        userInteractionAgent;
        graphicalInterface;
    end
    
    methods
        function start(this)
            this.graphicalInterface = GraphicalInterface(this);
            this.graphicalInterface.create();
            
            %initialize bezierCurves to empty BezierCurve array
            this.bezierCurves = BezierCurve.empty;
            
            this.userInteractionAgent = UserInteractionAgent(this);
            %call function to draw a new bezier curve
            this.userInteractionAgent.drawNewCurve();
        end
        
        function clearCurves(this)
            %renizialize it to empty BezierCurves array
            this.bezierCurves=BezierCurve.empty;
        end    
    end
    
end

