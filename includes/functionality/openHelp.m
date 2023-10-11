function openHelp(src, ~, page)

if nargin < 3
    page = 'index.html';
end

web(['https://drescherlab.org/data/biofilmQ/docs/', page], '-noaddressbox');

