function bernstMatrix=bernstein(grade,points)
% BERNSTEIN evaluates the bernstein basis functions of given grade in the
% given points.
% M = bernstein(3,1:5) M is the matrix of bernstein basis polynomial of
% grade 3 in the points from 1 to 5.

%This is a dynamic programming algoritm. 
%Instead of using a matrix it use a vector. It doesn't store a sub-solution
%after had used it.This is called memoization technique.

%It use the following formula:
% B_{j,i}(t) = t * B_{j-1,i-1}(t) + (1-t) * B_{j,i-1}(t) j=0,..,n
% B_0,0 is always 1

%execution example
%1-[0      0      0        B_0,0]
%2-[0      0      B_0,1    B_1,1]
%3-[0      B_0,2  B_1,2    B_2,2]
%4-[B_0,3  B_1,3  B_2,3    B_3,3]


%get the number of points
numberOfPoints=length(points);
n=grade+1;
%initialize bernstMatrix to a empty numberOfPoints x n Matrix
bernstMatrix=zeros(numberOfPoints,n);
% for all the row
for k=1:numberOfPoints
 %every last element of a row is 1 (because B_0,0 = 1)  
 bernstMatrix(k,n)=1.0;
 %get the k th element of x array
 t=points(k);
 % for i= n to 2 with step of -1 (cycling backward the row)
 for i=n:-1:2
   temp=0.0;
   %cycle forward the row
    for j=i:n
     bernstMatrix(k,j-1)= temp + (1-t).*bernstMatrix(k,j);
     %this temp will be the B_(i-1,n-1) in the next iteration
     temp=t.*bernstMatrix(k,j);
   end
   bernstMatrix(k,n)=temp;
  end
end

  

