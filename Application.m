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
            
            %set hold state to on so adding new points doesn't delete old points
            hold on;
            
            this.userInteractionAgent = UserInteractionAgent(this);
            %call function to draw a new bezier curve
            this.userInteractionAgent.drawNewCurve();
        end
    end
    
end

