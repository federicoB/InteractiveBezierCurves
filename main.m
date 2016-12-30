%remove items from workspace
clear
%create a figure with defined title and hide showing figure number in title
figureHandler=figure('Name','Interactive Bezier Curves','NumberTitle','off');
%hide the menu
figureHandler.MenuBar='none'; 
%use the same length for the data units along each axis
axis equal;
%set axis limits
axis([0 1 0 1]);
%get the current axis handler
currentAxis = gca;
%set the unit of measurement to pixel
%ginput() and plot() still use dimension based on cartesian coordinate
currentAxis.Units = 'pixels';
%set hold state to on so adding new points doesn't delete old points
hold on
%call function to draw a new bezier curve
drawNewCurve();
%when a curve is already draw, add the button to clear it and draw a new
%curve
btn = uicontrol('Style', 'pushbutton', 'String', 'Clear','Position', [20 20 60 30],'Callback', @(src,event)drawNewCurve);

%clear the graph and ask the user a set of points for a new bezier curve
function drawNewCurve() 
    %clear current plots
    cla;
    %initialize number of points counter
    numberOfPoints=0;
    %initialize control points vector
    %it's global for avoiding matlab way of passing parameter value on
    %callback definition not  on callback call following an event
    global controlPoints; 
    %initialize control points to empty vector
    controlPoints = [];
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
                clickX=controlPoints(1,1);
                clickY=controlPoints(2,1);
            end
            %increase the number of points counter
            numberOfPoints=numberOfPoints+1;
            %add the point to the control point array
            controlPoints(1,numberOfPoints)=clickX;
            controlPoints(2,numberOfPoints)=clickY;
            %plot a blue cicle at the given coordinates
            plot(controlPoints(1,numberOfPoints),controlPoints(2,numberOfPoints),'bo',...            
                'MarkerSize',10,'MarkerFaceColor','b',...
                'ButtonDownFcn',{@controlPointClicked,numberOfPoints});
        end
    end
    %draw the bezier curve on the current axis with the given control
    %points
    drawBezierCurve(numberOfPoints);
end

%plot bezier curve with control polygonal given a set of points
function drawBezierCurve(numberOfPoints) 
    %redeclare controlPoints array, being global if it was already defined
    %it will be already set
    global controlPoints; 
    global controlPolyPlot bezierPlot;
    %delete old plots if already declared
    if (~empty(controlPolyPlot)) 
        delete(controlPolyPlot);
    end
    if (~empty(bezierPlot)) 
        delete(bezierPlot);
    end
    if (~isempty(controlPoints))
        % draw control polygonal
        controlPolyPlot = plot(controlPoints(1,:),controlPoints(2,:),'g-');
        %calculate bezier curve
        bezierCurve = calculateBezier(controlPoints,numberOfPoints);
        %draw red solid line bézier curve
        bezierPlot = plot(bezierCurve(1,:),bezierCurve(2,:),'r-'); 
    end
end

%called upon click on control point, activates drag and drop
function controlPointClicked(src,event,controlPointIndex)
    %get current figure handler
    fig = gcf;
    %set a listener for mouse move event
    fig.WindowButtonMotionFcn = {@controlPointMoved,src,controlPointIndex};
    %set a listener for mouse button relase event
    fig.WindowButtonUpFcn = @dropObject;
end

%called on drag of control point
function controlPointMoved(figureHandler,event,object,controlPointIndex) 
    %get current axes handler
    ax=gca;
    %get the pixel position and dimension of the axes
    axesPosition = get(ax,'Position');
    %axesPosition is an array of 4 element x,y,width and height
    width = axesPosition(3);
    height = axesPosition(4);
    %get the current position of the mouse
    newPos = get(figureHandler,'CurrentPoint');
    %calculate pixel offset related to axes position
    newPos(1) = newPos(1) - axesPosition(1);
    newPos(2) = newPos(2) - axesPosition(2);
    %map pixel position to cartesian position
    newPos(1) = newPos(1)/width;
    newPos(2) = newPos(2)/height;
    %update control point "plot"
    set(object,'XData',newPos(1));
    set(object,'YData',newPos(2));
    %redeclare controlPoints for getting its global value
    global controlPoints; 
    %update control point array
    controlPoints(1,controlPointIndex)=newPos(1);
    controlPoints(2,controlPointIndex)=newPos(2);
    %re-draw bezier curve
    drawBezierCurve(length(controlPoints));
end

%called after clicked on a control point and relased the mouse button.
function dropObject(src,event)
    %get current figure handler
    fig = gcf;
    %remove listener for mouse move event
    fig.WindowButtonMotionFcn = '';
    %remove listener for mouse button relase event
    fig.WindowButtonUpFcn = '';
end