classdef Application < handle
    %APPLICATION
    
    properties
        bezierCurves;
        userInteractionAgent;
        graphicalInterface;
    end
    
    methods
        function start(this)
            %clear global variables
            clearvars -global;
            %clear non-global variables
            clearvars;
            
            this.graphicalInterface = GraphicalInterface;
            this.graphicalInterface.create();
            
            %initialize bezierCurves to empty BezierCurve array
            this.bezierCurves = BezierCurve.empty;
            %set hold state to on so adding new points doesn't delete old points
            hold on;
            
            userInteractionAgent = UserInteractionAgent(this.bezierCurves);
            %call function to draw a new bezier curve
            userInteractionAgent.drawNewCurve();
        end
    end
    
end

