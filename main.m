%clear global variables
clearvars -global;
%clear non-global variables
clearvars;
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
uicontrol('Style', 'pushbutton', 'String', 'Clear','Position', [20 30 60 30],...
            'Tag','ClearButton','Callback', @(src,event)clearCurve,...
            'Visible','off');
%define button for adding a curve, but hide it for now        
uicontrol('Style', 'pushbutton', 'String', 'Add curve','Position', [20 60 90 30],...
            'Tag','addCurveButton','Callback', @(src,event)drawNewCurve,...
            'Visible','off');
%define button for showing tangent, but hide it for now        
uicontrol('Style', 'pushbutton', 'String', 'Tangent','Position', [20 90 90 30],...
            'Tag','tangent',...
            'Visible','off');   
%define button for showing normal, but hide it for now        
uicontrol('Style', 'pushbutton', 'String', 'Normal','Position', [20 120 90 30],...
            'Tag','normal',...
            'Visible','off');          
%define text for giving istruction to the user
uicontrol('Style','text','Position',[150 0 400 80],'HorizontalAlignment','left',...
    'Tag','instructions');
global bezierCurves;
%initialize bezierCurves to empty BezierCurve array
bezierCurves = BezierCurve.empty;
%set hold state to on so adding new points doesn't delete old points
hold on;
%call function to draw a new bezier curve
drawNewCurve();

function clearCurve()
    %clear current plots
    cla;
    %clear global variables
    clearvars -global;
    %clear non-global variables
    clearvars;
    drawNewCurve();
end

%clear the graph and ask the user a set of points for a new bezier curve
function drawNewCurve()
    %set istructions for the user
    text = findobj('Tag','instructions');
    text.String = {'Left mouse click for define a control point',...
    'Central mouse button for ending draw a closed curve or right mouse button for open curve'};
    %set clear button and add button to invisible during drawing
    clearButton = findobj('Tag','ClearButton');
    addCurveButton = findobj('Tag','addCurveButton');
    clearButton.Visible = 'off';
    addCurveButton.Visible = 'off';
    %initialize list of bezier curves
    %it's global for avoiding matlab way of passing parameter value in the
    %moment of callback definition not on callback call following an event
    global bezierCurves;
    %add a curve to the list of curves
    bezierCurves(end+1) = BezierCurve;
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
            %plot a blue cicle at the given coordinates
            plot(bezierCurves(end).controlPoints(1,end),bezierCurves(end).controlPoints(2,end),'bo',...
                'MarkerSize',10,'MarkerFaceColor','b',...
                'ButtonDownFcn',{@controlPointClicked,controlPointIndex,length(bezierCurves)});
            end 
        end
    end
    %draw the bezier curve
    drawBezierCurve(bezierCurves(end),length(bezierCurves));
    %after a curve is drawn, set to visible the clear button
    clearButton.Visible='on';
    %and the add curve button
    addCurveButton.Visible='on';
    %modify instructions
    text.String = 'Drag and drop a control point for modify the curve';
end

%plot bezier curve with control polygonal given a set of points
function drawBezierCurve(bezierCurve,curveIndex)
    global controlPolyPlot bezierPlot;
    %delete old plots if present
    if (length(controlPolyPlot)>=curveIndex)
        delete(controlPolyPlot(curveIndex));
        delete(bezierPlot(curveIndex));
    end
    if (~isempty(bezierCurve.controlPoints))
        % draw control polygonal
        controlPolyPlot(curveIndex) = plot(bezierCurve.controlPoints(1,:),bezierCurve.controlPoints(2,:),'g-');
        %move the control polygonal to minimum z-index for better
        %click detection on control points
        uistack(controlPolyPlot(curveIndex),'bottom');
        %calculate bezier curve
        bezierPoints = bezierCurve.calculateBezier();
        %draw red solid line bézier curve
        bezierPlot(curveIndex) = plot(bezierPoints(1,:),bezierPoints(2,:),'r-');
        %move the bezier curve plot to minimum z-index for better
        %click detection on control points
        uistack(bezierPlot(curveIndex),'bottom');
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