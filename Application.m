classdef Application < handle
    %APPLICATION
    
    properties
        bezierCurves;
        userInteractionAgent;
        graphicalInterface;
    end
    
    methods
        function start(this)
            this.graphicalInterface = GraphicalInterface(this);
            this.graphicalInterface.create();
            
            %initialize bezierCurves to empty BezierCurve array
            this.bezierCurves = BezierCurve.empty;
            
            this.userInteractionAgent = UserInteractionAgent(this);
            %call function to draw a new bezier curve
            this.userInteractionAgent.drawNewCurve();
        end
        
        function clearCurves(this)
            %renizialize it to empty BezierCurves array
            this.bezierCurves=BezierCurve.empty;
        end    
    end
    
end

