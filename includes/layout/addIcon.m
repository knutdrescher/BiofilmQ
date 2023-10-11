function f = addIcon(f)

warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
jframe=get(f,'javaframe');
if isdeployed
    pathstr = fileparts(which('logo.png'));
    iconPath = fullfile(pathstr, 'logo.png');
else
    iconPath = fullfile('includes', 'layout', 'logo.png');
end
jIcon=javax.swing.ImageIcon(iconPath);
jframe.setFigureIcon(jIcon);