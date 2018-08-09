function [verticesList, facesList] = getVerticesAndFacesInSphere(mesh_outer, iV, radius)
%iV is the INDEX of the initial vertex
% find all the vertices included in a sphere
verticesList = [];
if size(iV,1)~=1&size(iV,2)~=1;
    %mesh_outer
end
if ~isfield(mesh_outer,'vertices');str8verts=mesh_outer;mesh_outer=struct('vertices',str8verts);end
%
% getVerticesAndFacesInSphere.m
%
% Original Author: FreeSurfer (MGH)
% Derivative Author: Walter Hinds
%    $Revised Date: 01/01/2017 00:04:12 $
%
% Copyright © 2017 Drexel University
%
% Terms and conditions for use, reproduction, distribution and contribution
% are found in the 'ACOREL Software License Agreement' contained
% in the file 'LICENSE' found in the ACOREL distribution.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%

eudz=eud([mesh_outer.vertices],mesh_outer.vertices(iV,:));
verticesList=find(eudz<=radius);
%then the index removes itself from the neighbor list
verticesList=verticesList(verticesList~=iV);

% find faces to which those vertices belong
facesList = [];
if isfield(mesh_outer,'facesOfVertex')
for vert = verticesList
    facesList = [facesList, mesh_outer.facesOfVertex(vert).faceList];
end
end
facesList = unique(facesList);
