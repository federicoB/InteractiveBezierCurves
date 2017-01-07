classdef GraphicalInterface < handle
    %GRAPHICALINTERFACE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        application;
        controlPointsPlot=[];
        controlPolyPlot=[];
        bezierPlot = [];
        tangentPlot = [];
        clearButton;
        addCurveButton;
        tangentButton;
        normalButton;
        textInstructions;
        hideControlsButton;
    end
    
    methods
        function this = GraphicalInterface(applicationReference)
            this.application=applicationReference;
        end
        
        function create(this)
            %create a figure with defined title and hide showing figure number in title
            figureHandler=figure('Name','Interactive Bezier Curves','NumberTitle','off');
            %hide the menu
            figureHandler.MenuBar='none';
            %get screen dimension
            screenSize = get(groot,'ScreenSize');
            %set figure position and dimension according to screen dimension
            figureHandler.Position=[1 screenSize(4)/2 screenSize(3)/2 screenSize(4)/2];
            %use the same length for the data units along each axis
            axis equal;
            %set axis limits
            axis([0 1 0 1]);
            %get the current axis handler
            currentAxis = gca;
            %set the unit of measurement to pixel
            %ginput() and plot() still use dimension based on cartesian coordinate
            currentAxis.Units = 'pixels';
            %set axis left-margin, bottom-margin, width and height
            currentAxis.Position = [150 110 400 400];
            %define clear button but set to invisible for now
            this.clearButton = uicontrol('Style', 'pushbutton', 'String', 'Clear','Position', [20 30 60 30],...
                'Callback', @(src,event)this.clearAllPlot,...
                'Visible','off');
            %define button for adding a curve, but hide it for now
            this.addCurveButton = uicontrol('Style', 'pushbutton', 'String', 'Add curve','Position', [20 60 90 30],...
                'Callback', @(src,event)this.application.userInteractionAgent.drawNewCurve,...
                'Visible','off');
            %define button for showing tangent, but hide it for now
            this.tangentButton = uicontrol('Style', 'pushbutton', 'String', 'Tangent','Position', [20 90 90 30],...
                'Callback',@(src,event)this.application.userInteractionAgent.enterTangentMode,...
                'Visible','off');
            %define button for showing normal, but hide it for now
            this.normalButton = uicontrol('Style', 'pushbutton', 'String', 'Normal','Position', [20 120 90 30],...
                'Callback',@(src,event)this.application.userInteractionAgent.enterNormalMode,...
                'Visible','off');
            this.hideControlsButton = uicontrol('Style', 'pushbutton', 'String', 'HideControls','Position', [20 150 90 30],...
                'Visible','off','Callback',@(src,event)this.hideControls);
            %define text for giving istruction to the user
            this.textInstructions = uicontrol('Style','text','Position',[150 0 400 80],'HorizontalAlignment','left');
        end
        
        function enterDrawingMode(this)
            %set istructions for the user
            this.textInstructions.String = {'Left mouse click for define a control point',...
                'Central mouse button for ending draw a closed curve or right mouse button for open curve'};
            %set clear button and add button to invisible during drawing
            this.clearButton.Visible = 'off';
            this.addCurveButton.Visible = 'off';
            this.tangentButton.Visible = 'off';
            this.normalButton.Visible = 'off';
            this.hideControlsButton.Visible = 'off';
        end
        
        function plotControlPoint(this,x,y,clickcallback,controlPointNumber,curveNumber)
            tag = strcat(int2str(controlPointNumber),'-',int2str(curveNumber));
            %plot a blue cicle at the given coordinates
            plot(x,y,'bo','MarkerSize',10,'MarkerFaceColor','b','ButtonDownFcn',clickcallback,'Tag',tag);
            this.controlPointsPlot{curveNumber,controlPointNumber}=tag;
        end
        
        function exitDrawingMode(this)
            %after a curve is drawn, set to visible the clear button
            this.clearButton.Visible='on';
            %and the add curve button
            this.addCurveButton.Visible='on';
            this.tangentButton.Visible = 'on';
            this.normalButton.Visible = 'on';
            this.hideControlsButton.Visible = 'on';
            %modify instructions
            this.textInstructions.String = 'Drag and drop a control point for modify the curve';
        end
        
        %plot bezier curve with control polygonal given a set of points
        function drawBezierCurve(this,curveIndex)
            %get bezier curve by given index
            bezierCurve = this.application.bezierCurves(curveIndex);
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
        
        function clearAllPlot(this)
            %clear everything except this
            this.application.clearCurves();
            cellfun(@(tag) this.deleteControlPoint(tag),this.controlPointsPlot);
            this.controlPointsPlot=[];
            delete(this.controlPolyPlot);
            this.controlPolyPlot = [];
            delete(this.bezierPlot);
            this.bezierPlot = [];
            delete(this.tangentPlot);
            this.tangentPlot=[];
            this.application.userInteractionAgent.drawNewCurve();
        end
        
        function deleteControlPoint(this,tag)
            obj=findobj('Tag',tag);
            delete(obj);
        end
        
        function hideControls(this)
            cellfun(@hideControlPoint,this.controlPointsPlot);
            function hideControlPoint(tag)
                if (ischar(tag)) 
                    obj=findobj('Tag',tag);
                    obj.Visible='off';
                end
            end
            arrayfun(@hidePolygonals,this.controlPolyPlot);
            function hidePolygonals(polygonal)
                set(polygonal,'Visible','off');
            end
            this.hideControlsButton.String='Show';
            this.hideControlsButton.Callback=@(src,event)this.showControls;
        end
        
        function showControls(this)
            cellfun(@showControls,this.controlPointsPlot);
            function showControls(tag)
                if (ischar(tag)) 
                    obj=findobj('Tag',tag);
                    obj.Visible='on';
                end
            end
            arrayfun(@hidePolygonals,this.controlPolyPlot);
            function hidePolygonals(polygonal)
                set(polygonal,'Visible','on');
            end
            this.hideControlsButton.String='Hide';
            this.hideControlsButton.Callback=@(src,event)this.hideControls;
        end
        
        function movePlotPoint(~,newPos,object)
            %update control point "plot"
            object.XData=newPos(1);
            object.YData=newPos(2);
        end
        
        function plotTangent(this,line,curveIndex)
           this.tangentPlot(curveIndex,end+1) = plot(line(1,:),line(2,:));
           uistack(this.tangentPlot(curveIndex,end),'bottom');
        end
    end
    
end

