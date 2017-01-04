classdef GraphicalInterface < handle
    %GRAPHICALINTERFACE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
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
        end
    end
    
end

