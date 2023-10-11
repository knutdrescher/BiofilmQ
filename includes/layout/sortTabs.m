function sortTabs(tabGroupHandle, renameTabs)

if nargin == 1
    renameTabs = false;
end

tabTitles = {tabGroupHandle.Children.Title};
[tabTitles, idx] = sort(tabTitles);
tabGroupHandle.Children = tabGroupHandle.Children(idx);

if renameTabs
    globalNum = tabTitles{1}(1);
    
    for i = 1:numel(tabGroupHandle.Children)
        tabGroupHandle.Children(i).Title = sprintf('%s.%d %s', globalNum, i, tabTitles{i}(5:end));
    end
end
