classdef GraphicalInterface < handle
    %GRAPHICALINTERFACE Manage the interface of the application
    
    properties
        application;
        controlPointsPlot=[];
        controlPolyPlot=[];
        bezierPlot = [];
        linesPlot = [];
        clearButton;
        addCurveButton;
        tangentButton;
        normalButton;
        textInstructions;
        hideControlsButton;
        lengthButton;
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
                'Callback',{@(src,event)this.application.userInteractionAgent.enterCurveSelectionMode(0)},...
                'Visible','off');
            %define button for showing normal, but hide it for now
            this.normalButton = uicontrol('Style', 'pushbutton', 'String', 'Normal','Position', [20 120 90 30],...
                'Callback',{@(src,event)this.application.userInteractionAgent.enterCurveSelectionMode(1)},...
                'Visible','off');
            %define button for calculate length of the curve, but hide it for now
            this.lengthButton = uicontrol('Style', 'pushbutton', 'String', 'Length','Position', [20 150 90 30],...
                'Callback',{@(src,event)this.application.userInteractionAgent.enterCurveSelectionMode(2)},...
                'Visible','off');
            this.hideControlsButton = uicontrol('Style', 'pushbutton', 'String', 'HideControls','Position', [20 180 90 30],...
                'Visible','off','Callback',@(src,event)this.hideControls);
            %define text for giving istruction to the user
            this.textInstructions = uicontrol('Style','text','Position',[150 0 400 80],'HorizontalAlignment','left');
            %set hold state to on so adding new points doesn't delete old points
            hold on;
        end
        
        function enterDrawingMode(this)
            %set istructions for the user
            this.setInstruction(3);
            %set clear button and add button to invisible during drawing
            this.clearButton.Visible = 'off';
            this.addCurveButton.Visible = 'off';
            this.tangentButton.Visible = 'off';
            this.normalButton.Visible = 'off';
            this.hideControlsButton.Visible = 'off';
            this.lengthButton.Visible = 'off';
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
            %display all the button for features related to drawed curves
            %and the add curve button
            this.addCurveButton.Visible='on';
            this.tangentButton.Visible = 'on';
            this.normalButton.Visible = 'on';
            this.hideControlsButton.Visible = 'on';
            this.lengthButton.Visible = 'on';
            %modify instructions
            this.setInstruction(4);
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
            %delete all the control point graphic object
            cellfun(@(tag) this.deleteControlPoint(tag),this.controlPointsPlot);
            %empties array
            this.controlPointsPlot=[];
            delete(this.controlPolyPlot);
            this.controlPolyPlot = [];
            delete(this.bezierPlot);
            this.bezierPlot = [];
            delete(this.linesPlot);
            this.linesPlot=[];
            %enter mode for drawing new curve
            this.application.userInteractionAgent.drawNewCurve();
        end
        
        function deleteControlPoint(~,tag)
            %find object given its tag
            obj=findobj('Tag',tag);
            %delete graphic object
            delete(obj);
        end
        
        function hideControls(this)
            %iterate through the point and set Visible to off
            cellfun(@hideControlPoint,this.controlPointsPlot);
            function hideControlPoint(tag)
                if (ischar(tag)) 
                    obj=findobj('Tag',tag);
                    obj.Visible='off';
                end
            end
            %iterate through the curves and hide polygonal
            arrayfun(@hidePolygonals,this.controlPolyPlot);
            function hidePolygonals(polygonal)
                set(polygonal,'Visible','off');
            end
            %change button string
            this.hideControlsButton.String='Show';
            %set 'show' callback on button click
            this.hideControlsButton.Callback=@(src,event)this.showControls;
            this.setInstruction(5);
        end
        
        function showControls(this)
            %iterate through the point and set Visible to on
            cellfun(@showControls,this.controlPointsPlot);
            function showControls(tag)
                if (ischar(tag)) 
                    obj=findobj('Tag',tag);
                    obj.Visible='on';
                end
            end
            %iterate through the curves and show polygonal
            arrayfun(@hidePolygonals,this.controlPolyPlot);
            function hidePolygonals(polygonal)
                set(polygonal,'Visible','on');
            end
            %change button string
            this.hideControlsButton.String='Hide';
            %set 'hide' callback on button click
            this.hideControlsButton.Callback=@(src,event)this.hideControls;
            this.setInstruction(4);
        end
        
        function movePlotPoint(~,newPos,object)
            %update control point "plot"
            object.XData=newPos(1);
            object.YData=newPos(2);
        end
        
        function plotLine(this,line,curveIndex,r)
            d = 0;
            fin = 501;
            while (d~=r)
                if (fin == 1001)
                    fprintf('TROPPO GRANDEEEE\n');
                    break
                end
            X = [line(1,500),line(2,500);line(1,fin),line(2,fin)];
            d = pdist(X, 'euclidean');
            disp(d);
            fin = fin + 0.01;                    
            end
            
            
            %plot the given point
           this.linesPlot(curveIndex,end+1) = plot(line(1,500:fin),line(2,500:fin));
           %__________________LENGTH OF SEGMENT__________________________
           %X = [line(1,500),line(2,500);line(1,600),line(2,600)];
           %d = pdist(X, 'euclidean');
           %disp(d);
           %_____________________________________________________________
           %set to minimum z-index so the user can click in the same point
           %for the normal/tangent.
           uistack(this.linesPlot(curveIndex,end),'bottom');
        end
        
        %called on curve modify 
        function clearLines(this,curveIndex)
           %delete all the tangents and normals
           delete(this.linesPlot(curveIndex));
           %empties array
           this.linesPlot(curveIndex) = [];
        end
        
        %display a message box with the given value
        function displayValue(~,value)
            %if the value is numeric
            if (isnumeric(value))
                %convert it to string
                value = num2str(value);
            end
            %show the value in a message box
            msgbox(value);
        end
        
        %change instruction for the use
        function setInstruction(this,mode)
            switch mode
                case 0 %tangent mode
                    this.textInstructions.String = 'Click on a point of a curve for showing the tangent line to that point';
                case 1 %normal mode
                    this.textInstructions.String = 'Click on a point of a curve for showing the normal line to that point';
                case 2 %length mode
                    this.textInstructions.String = 'Click on curve to get its length';
                case 3 %drawing mode
                    this.textInstructions.String = {'Left mouse click for define a control point',...
                        'Central mouse button for ending draw a closed curve or right mouse button for open curve'};
                case 4 %drag and drop mode
                    this.textInstructions.String = 'Drag and drop a control point for modify the curve';
                case 5 %nothing mode
                    this.textInstructions.String = '';
            end
        end
    end
end

