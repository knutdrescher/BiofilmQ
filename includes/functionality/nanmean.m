function y = nanmean(varargin)
%NANMEAN Mean value, ignoring NaNs.
%   M = NANMEAN(X) returns the sample mean of X, treating NaNs as missing
%   values.  For vector input, M is the mean value of the non-NaN elements
%   in X.  For matrix input, M is a row vector containing the mean value of
%   non-NaN elements in each column.  For N-D arrays, NANMEAN operates
%   along the first non-singleton dimension.
%
%   NANMEAN(X,'all') is the mean value of all the elements in X.
%
%   NANMEAN(X,DIM) takes the mean along the dimension DIM of X.
%
%   NANMEAN(X,VECDIM) finds the mean of the elements of X based on the
%   dimensions specified in the vector VECDIM.
%
%   See also MEAN, NANMEDIAN, NANSTD, NANVAR, NANMIN, NANMAX, NANSUM.

%   Copyright 1993-2018 The MathWorks, Inc.


narginchk(1,2);
y = mean(varargin{:},'omitnan');
