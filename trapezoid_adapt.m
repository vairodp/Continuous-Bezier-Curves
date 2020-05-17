function value = trapezoid_adapt(fun,a,b,fa,fb,tolerance,trapAb)
%TRAPEZOID_ADAPT adaptive composite integration with trapezoid method
% a -> left interval margin
% b -> right interval margin
% fa -> function value in left interval margin
% fb -> function value in right interval margin
% tolerance -> stop condition
% trapAB -> integral computed with step h
median=0.5*(a+b);
medianValue=feval(fun,median);
firstHalfIntegral=trapezoid(a,median,fa,medianValue);
secondHalfIntegral=trapezoid(median,b,medianValue,fb);
%integral computed with step h/2
currentIntegral = firstHalfIntegral+secondHalfIntegral;
%error estimation
error = abs((currentIntegral-trapAb)/3);
if error < tolerance 
    %richardson extrapolation and exit
    value = (4*(firstHalfIntegral+secondHalfIntegral)-trapAb)/3;
else
    %recurvise call on subintervals
    val1=trapezoid_adapt(fun,a,median,fa,medianValue,0.5*tolerance,firstHalfIntegral);
    val2=trapezoid_adapt(fun,median,b,medianValue,fb,0.5*tolerance,secondHalfIntegral);
    value = val1+val2;
end