function n = patchnormals(FV)
%Vertex normals of a triangulated mesh, area weighted, left-hand-rule
% N = patchnormals(FV) -struct with fields, faces Nx3 and vertices Mx3
%N: vertex normals as Mx3

%face corners index
A = FV.faces(:,1);
B = FV.faces(:,2);
C = FV.faces(:,3);

%face normals
n = cross(FV.vertices(A,:)-FV.vertices(B,:),FV.vertices(C,:)-FV.vertices(A,:)); %area weighted


%vertice normals
N = zeros(size(FV.vertices)); %init vertix normals
for i = 1:size(FV.faces,1) %step through faces (a vertex can be reference any number of times)
N(A(i),:) = N(A(i),:)+n(i,:); %sum face normals
N(B(i),:) = N(B(i),:)+n(i,:);
N(C(i),:) = N(C(i),:)+n(i,:);
end