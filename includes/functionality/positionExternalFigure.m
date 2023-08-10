function pos = positionExternalFigure(handles)

pos = handles.mainFig.Position;
pos(1) = pos(1) + pos(3)/4;
pos(2) = pos(2) + pos(4)/4;
pos(3) = pos(4)/2;
pos(4) = pos(4)/2;