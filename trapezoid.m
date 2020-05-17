function T=trapezoid(a,b,leftExtremeValue,rightExtremeValue) 
%TRAPEZOID numerical integration with trapezoid method
% a -> left interval margin
% b -> right interval margin
T=0.5*(b-a)*(leftExtremeValue+rightExtremeValue);

