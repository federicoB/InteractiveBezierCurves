classdef Point < handle
    %POINT handle class (reference) for simple xy points 
    
    properties
        x
        y
    end
    
    methods
        %constructor
        function obj=Point(x,y)
           obj.x=x;
           obj.y=y;
        end
        
    end
    
end

