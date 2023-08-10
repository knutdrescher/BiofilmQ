function [varargout] = nanmin(varargin)
%NANMIN Minimum value, ignoring NaNs.
%   M = NANMIN(A) returns the minimum of A with NaNs treated as missing. 
%   For vectors, M is the smallest non-NaN element in A.  For matrices, M
%   is a row vector containing the minimum non-NaN element from each
%   column.  For N-D arrays, NANMIN operates along the first non-singleton
%   dimension.
%
%   [M,NDX] = NANMIN(A) returns the indices of the minimum values in A.  If
%   the values along the first non-singleton dimension contain more than
%   one minimal element, the index of the first one is returned.
%  
%   M = NANMIN(A,B) returns an array the same size as A and B with the
%   smallest elements taken from A or B.  Either one can be a scalar.
%
%   M = NANMIN(A,[],'all') returns the smallest element of X.
%
%   [M,NDX] = NANMIN(A,[],DIM) operates along the dimension DIM.
%
%   M = NANMIN(A,[],VECDIM) returns the smallest elements of X based 
%   on the dimensions specified in the vector VECDIM.
%
%   See also MIN, NANMAX, NANMEAN, NANMEDIAN, NANVAR, NANSTD.

%   Copyright 1993-2018 The MathWorks, Inc. 


% Call [m,ndx] = min(a,b) with as many inputs and outputs as needed
[varargout{1:nargout}] = min(varargin{:});
