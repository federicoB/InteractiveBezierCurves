classdef UserInteractionAgent < handle
    %USERINTERACTIONAGENT 
    
    properties
        application;
    end
    
    methods
        function this = UserInteractionAgent(applicationReference)
           this.application = applicationReference;
        end
        
        %clear the graph and ask the user a set of points for a new bezier curve
        function drawNewCurve(this)
            %get graphical interface
            graphicalInterface = this.application.graphicalInterface;
            graphicalInterface.enterDrawingMode();
            %get bezier curves
            bezierCurves = this.application.bezierCurves;
            %add a curve to the list of curves
            bezierCurves(end+1) = BezierCurve;
            %initialize control point indexthisthis
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
                        clickX=bezierCurves(end).controlPoints(1,1);
                        clickY=bezierCurves(end).controlPoints(2,1);
                        %set closed curve flag to 1
                        bezierCurves(end).closedCurve=1;
                    end
                    %increse the control point index
                    controlPointIndex=controlPointIndex+1;
                    %add the point to the control point array
                    bezierCurves(end).controlPoints(1,end+1)=clickX;
                    %the size is been already increased with latest command so only
                    %use end here
                    bezierCurves(end).controlPoints(2,end)=clickY;
                    %if the curve is not closed (in a closed curve the latest
                    %control point will not be plotted)
                    if (bezierCurves(end).closedCurve==0)
                        clickcallback = {@this.controlPointClicked,controlPointIndex,length(bezierCurves)};
                        graphicalInterface.plotControlPoint(clickX,clickY,clickcallback);
                    end
                end
            end
            %draw the bezier curve
            graphicalInterface.drawBezierCurve(bezierCurves(end),length(bezierCurves));
            graphicalInterface.exitDrawingMode();
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

