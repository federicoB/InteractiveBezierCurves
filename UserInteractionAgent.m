classdef UserInteractionAgent < handle
    %USERINTERACTIONAGENT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        bezierCurves;
        controlPolyPlot; 
        bezierPlot;
    end
    
    methods
        function this = UserInteractionAgent(bezierCurvesArray)
           this.bezierCurves = bezierCurvesArray;
        end
        function clearCurve(this)
            %clear current plots
            cla;
            %clear global variables
            clearvars -global;
            %clear non-global variables
            clearvars;
            this.drawNewCurve();
        end
        
        %clear the graph and ask the user a set of points for a new bezier curve
        function drawNewCurve(this)
            %set istructions for the user
            text = findobj('Tag','instructions');
            text.String = {'Left mouse click for define a control point',...
                'Central mouse button for ending draw a closed curve or right mouse button for open curve'};
            %set clear button and add button to invisible during drawing
            clearButton = findobj('Tag','ClearButton');
            addCurveButton = findobj('Tag','addCurveButton');
            clearButton.Visible = 'off';
            addCurveButton.Visible = 'off';
            %add a curve to the list of curves
            this.bezierCurves(end+1) = BezierCurve;
            %initialize control point index
            controlPointIndex=0;
            %matlab doesn't support do-while loop so first we set a true contition
            buttonClicked=1;
            %while the user had clicked the left mouse button
            while (buttonClicked==1)
                %wait for user click
                [clickX,clickY,buttonClicked]=ginput(1);
                %if the left of central mouse button is pressed
                if (buttonClicked==1) || (buttonClicked==2)
                    %if the central mouse buton is pressed
                    if buttonClicked==2
                        %set the control point equal to the first control point for closing
                        %the curve
                        clickX=this.bezierCurves(end).controlPoints(1,1);
                        clickY=this.bezierCurves(end).controlPoints(2,1);
                        %set closed curve flag to 1
                        this.bezierCurves(end).closedCurve=1;
                    end
                    %increse the control point index
                    controlPointIndex=controlPointIndex+1;
                    %add the point to the control point array
                    this.bezierCurves(end).controlPoints(1,end+1)=clickX;
                    %the size is been already increased with latest command so only
                    %use end here
                    this.bezierCurves(end).controlPoints(2,end)=clickY;
                    %if the curve is not closed (in a closed curve the latest
                    %control point will not be plotted)
                    if (this.bezierCurves(end).closedCurve==0)
                        %plot a blue cicle at the given coordinates
                        plot(this.bezierCurves(end).controlPoints(1,end),this.bezierCurves(end).controlPoints(2,end),'bo',...
                            'MarkerSize',10,'MarkerFaceColor','b',...
                            'ButtonDownFcn',{@controlPointClicked,controlPointIndex,length(this.bezierCurves)});
                    end
                end
            end
            %draw the bezier curve
            this.drawBezierCurve(this.bezierCurves(end),length(this.bezierCurves));
            %after a curve is drawn, set to visible the clear button
            clearButton.Visible='on';
            %and the add curve button
            addCurveButton.Visible='on';
            %modify instructions
            text.String = 'Drag and drop a control point for modify the curve';
        end
        
        %plot bezier curve with control polygonal given a set of points
        function drawBezierCurve(this,bezierCurve,curveIndex)

            %delete old plots if present
            if (length(this.controlPolyPlot)>=curveIndex)
                delete(this.controlPolyPlot(curveIndex));
                delete(this.bezierPlot(curveIndex));
            end
            if (~isempty(bezierCurve.controlPoints))
                % draw control polygonal
                this.controlPolyPlot(curveIndex) = plot(bezierCurve.controlPoints(1,:),bezierCurve.controlPoints(2,:),'g-');
                %move the control polygonal to minimum z-index for better
                %click detection on control points
                uistack(this.controlPolyPlot(curveIndex),'bottom');
                %calculate bezier curve
                bezierPoints = bezierCurve.calculateBezier();
                %draw red solid line bézier curve
                this.bezierPlot(curveIndex) = plot(bezierPoints(1,:),bezierPoints(2,:),'r-');
                %move the bezier curve plot to minimum z-index for better
                %click detection on control points
                uistack(this.bezierPlot(curveIndex),'bottom');
            end
        end
        
        %called upon click on control point, activates drag and drop
        function controlPointClicked(src,~,controlPointIndex,curveIndex)
            %get current figure handler
            fig = gcf;
            %set a listener for mouse move event
            fig.WindowButtonMotionFcn = {@controlPointMoved,src,controlPointIndex,curveIndex};
            %set a listener for mouse button relase event
            fig.WindowButtonUpFcn = @dropObject;
        end
        
        %called on drag of control point
        function controlPointMoved(figureHandler,~,object,controlPointIndex,curveIndex)
            %get the current position of the mouse
            newPos = get(figureHandler,'CurrentPoint');
            %get current axes handler
            ax=gca;
            %get the pixel position and dimension of the axes
            axesPosition = get(ax,'Position');
            %axesPosition is an array of 4 element x,y,width and height
            width = axesPosition(3);
            height = axesPosition(4);
            %calculate pixel offset related to axes position
            newPos(1) = newPos(1) - axesPosition(1);
            newPos(2) = newPos(2) - axesPosition(2);
            %map pixel position to cartesian position
            newPos(1) = newPos(1)/width;
            newPos(2) = newPos(2)/height;
            %move the graphical point on the axes
            movePlotPoint(newPos,object);
            %change the point in the control point array
            moveCurveGeneratorsPoints(newPos,controlPointIndex,curveIndex);
            %redeclare bezierCurves for get its global value
            global bezierCurves;
            %if we are moving the first control point and is a closed curve
            if ((controlPointIndex==1)&&(bezierCurves(curveIndex).closedCurve==1))
                %get the index of the last control point
                lastIndex = length(bezierCurves(curveIndex).controlPoints);
                %move also the last control point
                moveCurveGeneratorsPoints(newPos,lastIndex,curveIndex);
            end
        end
        
        function movePlotPoint(newPos,object)
            %update control point "plot"
            object.XData=newPos(1);
            object.YData=newPos(2);
        end
        
        function moveCurveGeneratorsPoints(newPos,controlPointIndex,curveIndex)
            %redeclare bezierCurves for getting its global value
            global bezierCurves;
            %update control point array
            bezierCurves(curveIndex).controlPoints(1,controlPointIndex)=newPos(1);
            bezierCurves(curveIndex).controlPoints(2,controlPointIndex)=newPos(2);
            %re-draw bezier curve
            drawBezierCurve(bezierCurves(curveIndex),curveIndex);
        end
        
        %called after clicked on a control point and relased the mouse button.
        function dropObject(~,~)
            %get current figure handler
            fig = gcf;
            %remove listener for mouse move event
            fig.WindowButtonMotionFcn = '';
            %remove listener for mouse button relase event
            fig.WindowButtonUpFcn = '';
        end
    end
    
end

