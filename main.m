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
            %set in the qx/qy array the coordinate
            controlPoints(1,numberOfPoints)=clickX;
            controlPoints(2,numberOfPoints)=clickY;
            %plot a blue cicle at the given coordinates
            plot(controlPoints(1,numberOfPoints),controlPoints(2,numberOfPoints),'bo',...            
                'LineWidth',4,'ButtonDownFcn',{@controlPointClicked,numberOfPoints});
        end
    end
    drawBezierCurve(numberOfPoints);
end

%plot bezier curve with control polygonal given a set of points
function drawBezierCurve(numberOfPoints) 
    global controlPoints; 
    if (~isempty(controlPoints))
        global controlPoly bezierPlot; 
        delete(controlPoly);
        delete(bezierPlot);
        % draw control polygonal
        controlPoly = plot(controlPoints(1,:),controlPoints(2,:),'g-');
        %uistack(controlPoly,'down');
        %calculate bezier curve
        bezierCurve = calculateBezier(controlPoints,numberOfPoints);
        %draw red solid line bézier curve
        bezierPlot = plot(bezierCurve(1,:),bezierCurve(2,:),'r-'); 
    end
end

function controlPointClicked(src,event,controlPointIndex)
    %get current figure handler
    fig = gcf;
    fig.WindowButtonMotionFcn = {@controlPointMoved,src,controlPointIndex};
    fig.WindowButtonUpFcn = @dropObject;
end

function controlPointMoved(figureHandler,event,object,controlPointIndex) 
    ax=gca;
    axesPosition = get(ax,'Position');
    width = axesPosition(3);
    height = axesPosition(4);
    newPos = get(figureHandler,'CurrentPoint');
    newPos(1) = newPos(1) - axesPosition(1);
    newPos(2) = newPos(2) - axesPosition(2);
    newPos(1) = newPos(1)/width;
    newPos(2) = newPos(2)/height;
    set(object,'XData',newPos(1));
    set(object,'YData',newPos(2));
    global controlPoints; 
    controlPoints(1,controlPointIndex)=newPos(1);
    controlPoints(2,controlPointIndex)=newPos(2);
    drawBezierCurve(length(controlPoints));
end

function dropObject(src,event)
    %get current figure handler
    fig = gcf;
    fig.WindowButtonMotionFcn = '';
    fig.WindowButtonUpFcn = '';
end