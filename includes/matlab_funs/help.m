% overwrite MATLAB help function since can not be part of a redistribution
function [out, docTopic] = help(varargin)
    if isdeployed
        out = '';
        docTopic = '';
    else
        [out, docTopic] = help(varargin);
    end
end
