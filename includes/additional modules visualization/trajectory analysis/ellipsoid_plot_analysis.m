function [ x, y, z, color ] = ellipsoid_plot_analysis( xvec, v1, v2, v3, eig1, eig2, eig3 )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

%eigenvectors must be column vectors
if iscolumn(v1)==0
    v1=v1';
end

if iscolumn(v2)==0
    v2=v2';
end

if iscolumn(v3)==0
    v3=v3';
end

% generate data for "unrotated" ellipsoid
[xc,yc,zc] = ellipsoid(0,0,0,eig1,eig2,eig3,20);

%color accoring to orientation:
[m,n]=size(xc);
color=abs(v1(3))*ones(m,n);

% rotate data with eigenvectors and move position to xvec
a = kron(v1,xc); 
b = kron(v2,yc); 
c = kron(v3,zc);
data = a+b+c; 
n = size(data,2);

x = data(1:n,:)+xvec(1); 
y = data((n+1):(2*n),:)+xvec(2); 
z = data((2*n+1):end,:)+xvec(3);
end