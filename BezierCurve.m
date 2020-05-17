classdef BezierCurve < handle
    %BEZIERCURVE Class for handling bezier curves
    properties (Constant)
        numberOfEvaluationPoints=1000;
    end
    properties
        %initialize control points to empty vector
        controlPoints=[];
        %default curve is not closed
        closedCurve=0;
        xValues;
        yValues;
        xDerivative;
        yDerivative;
    end
    
    methods
        function bezierCurve = calculateBezier(this)
            %create a vector of 100 equally spaced points between 0 and 1 
            linearSpace=linspace(0,1,this.numberOfEvaluationPoints);
            %calculate the vector of x positions of the curve
            [this.xValues, this.xDerivative]=decastWithDerivative(this.controlPoints(1,:),linearSpace);
            disp(this.xValues);
            %calculate the vector of y positions of the curve
            [this.yValues, this.yDerivative]=decastWithDerivative(this.controlPoints(2,:),linearSpace);
            bezierCurve(1,:) = this.xValues;
            bezierCurve(2,:) = this.yValues;
        end
        
        function [pointX,pointY,xderivative,yderivative] = getDerivativeValue(this,x,y)
            %find the neares point and get it derivative
            %create array of distance between the searched point and the
            %evaluated point
            distance = [(this.xValues-x)',(this.yValues-y)'];
            %calculate norm of each pair
            for i=1:length(distance);
                normalized(i) = norm (distance(i));
            end
            %fid the minimum value (least squares distance)
            [~,index] = min(normalized);
            %get coordinate value
            %return also this for draw precisely the tangent/normal
            pointX = this.xValues(index);
            pointY = this.yValues(index);
            %get derivative value
            xderivative = this.xDerivative(index);
            yderivative = this.yDerivative(index);
        end
        
        function tangent = getTangent(this,x,y)
            %get derivative at the given points
           [x,y,derivative(1),derivative(2)] = this.getDerivativeValue(x,y);
           %linear space between [-1,1] instead of [0,1] for drawing also a backward line
           linearSpace = linspace(-1,1,this.numberOfEvaluationPoints);
           %normalize vector
           derivative(1)=derivative(1)/norm(derivative);
           derivative(2)=derivative(2)/norm(derivative);
           %create line
           tangent(1,:) = x+derivative(1)*(linearSpace);
           tangent(2,:) = y+derivative(2)*(linearSpace);
           
        end
        
        function curvature = getCurvature(this,x,y)
            %get derivative value at the given points
            [x,y,derivative(1),derivative(2)] = this.getDerivativeValue(x,y);
           linearSpace = linspace(-1,1,this.numberOfEvaluationPoints);
           %determine ortogonal vector
           derivative(1)=-derivative(2)/derivative(1);
           derivative(2)=1;
           %normalize vector
           derivative = derivative./norm(derivative);
           %create line
           normal(1,:) = x+derivative(1)*(linearSpace);
           normal(2,:) = y+derivative(2)*(linearSpace);
           f=normal(1,500);
            disp(this.xValues);
            for j=1:length(this.xValues)
                disp(j);
                if ( f == this.xValues(1,j))
                  
                    fprintf('L ho trovatoo! è nella posizione %d\n',j)
                    break
                end
            end
           %________________CURVATURE_____________________
            mx = mean(normal(1,500:end));
            my = mean(normal(2,500:end));
            X = normal(1,500:end) - mx; Y = normal(2,500:end) - my; % Get differences from means
            dx2 = mean(X.^2);
            dy2 = mean(Y.^2); % Get variances
            t = [X,Y]\(X.^2-dx2+Y.^2-dy2)/2; % Solve least mean squares problem
            a0 = t(1); b0 = t(2); % t is the 2 x 1 solution array [a0;b0]
            r = sqrt(dx2+dy2+a0^2+b0^2); % Calculate the radius
            disp(r);
           %______________________________________________
           fin = 500;
           while (fin ~= 1001)
               X = [normal(1,500),normal(2,500);normal(1,fin),normal(2,fin)];
               d = pdist(X,'euclidean');
               
               if (r - d < 0)
                   break
               end
               
               fin = fin +1;
           end
           
           plot(normal(1,500:fin),normal(2,500:fin));
           circle(normal(1,fin),normal(2,fin),r);
           
           curvature = r;
               
           end
     
        
        function normal = getNormal(this,x,y)
            %get derivative value at the given points
           [x,y,derivative(1),derivative(2)] = this.getDerivativeValue(x,y);
           linearSpace = linspace(-1,1,this.numberOfEvaluationPoints);
           %determine ortogonal vector
           derivative(1)=-derivative(2)/derivative(1);
           derivative(2)=1;
           %normalize vector
           derivative = derivative./norm(derivative);
           %create line
           normal(1,:) = x+derivative(1)*(linearSpace);
           normal(2,:) = y+derivative(2)*(linearSpace);
        end
        
        function value=getLength(this)
            %function to get the norm of the derivatives
            function val = funToIntegrate(this,x)
                %mapping index from [0,1] to [1,1000]
                index = round((x*(this.numberOfEvaluationPoints-1))+1);
                xderiv = this.xDerivative(index);
                yderiv = this.yDerivative(index);
                val = norm([xderiv,yderiv]);
            end
            %get left extreme function value
            fa = funToIntegrate(this,0);
            %get right extreme function value
            fb = funToIntegrate(this,1);
            %get not composite integral initial value
            trapez = trapezoid(0,1,fa,fb);
            %get integral value with numeric integration
            value = trapezoid_adapt(@(x) funToIntegrate(this,x),0,1,fa,fb,0.001,trapez);  
        end
        
    end
    
end

