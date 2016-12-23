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
%set hold state to on so adding new points doesn't delete old points
hold on
%define flag for knowing if the user want a closed line
closed=0;
%initialize number of points counter
numberOfPoints=0;
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
            %set the curve as a closed curve
            closed=1;
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
        plot(controlPoints(1,numberOfPoints),controlPoints(2,numberOfPoints),'bo');
    end
end

% draw control polygonal
plot(controlPoints(1,:),controlPoints(2,:),'g-');
%calculate bezier curve
bezierCurve = calculateBezier(controlPoints,numberOfPoints);
%draw red solid line bézier curve
plot(bezierCurve(1,:),bezierCurve(2,:),'r-');