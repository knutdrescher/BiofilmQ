
%% Test1: Can redraw line in 3D
rootpath = mfilename('fullpath');
while ~isfolder(fullfile(rootpath, 'includes'))
    rootpath = fileparts(rootpath);
end
addpath(genpath(fullfile(rootpath, 'includes')))

disp('test_Bresenham3D')
N = 33;
x = ones(1,N)*7;
y = 1:N;
z = 1:N;
[cx, cy, cz] = Bresenham3D(x(1), y(1), z(1), x(end), y(end), z(end));

assert(all(cx == x));
assert(all(cy == y));
assert(all(cz == z));