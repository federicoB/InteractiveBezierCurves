% This file is part of Interactive Bezier Curves.
% 
%     Interactive Bezier Curves is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     Interactive Bezier Curves is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with Nome-Programma.  If not, see <http://www.gnu.org/licenses/>.

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