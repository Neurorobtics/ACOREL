function [trodes]=callbackPickA3DPoint(src, eventData)
% CALLBACKCLICK3DPOINT mouse click callback function for CLICKA3DPOINT
%
%   The transformation between the viewing frame and the point cloud frame
%   is calculated using the camera viewing direction and the 'up' vector.
%   Then, the point cloud is transformed into the viewing frame. Finally,
%   the z coordinate in this frame is ignored and the x and y coordinates
%   of all the points are compared with the mouse click location and the 
%   closest point is selected.
%
%   Original Author: Babak Taati - May 4, 2005 
%   http://rcvlab.ece.queensu.ca/~taatib
%   Robotics and Computer Vision Laboratory (RCVLab)
%   Queen's University
%   revised Oct 31, 2007
%   revised Jun 3, 2008
%   revised May 19, 2009
%
% callbackPickA3DPoint.m
%
% Derivative Author: Walter Hinds
%    $Date: 01/01/2017 00:04:12 $
%
% Copyright © 2017 Drexel University
%
% Terms and conditions for use, reproduction, distribution and contribution
% are found in the 'ACOREL Software License Agreement' contained
% in the file 'LICENSE' found in the ACOREL distribution.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
trodes=guidata(findobj('Tag','GUI'));
%if ~isfield(trodes,'postproc');trodes.postproc=[NaN];end
pointCloud=trodes.cloud;
try
    brush_size=str2num(trodes.brush);
catch
    trodes.brush='1';
    brush_size=str2num(trodes.brush);
end%catch no brush size
point = get(gca, 'CurrentPoint'); % mouse click position
camPos = get(gca, 'CameraPosition'); % camera position
camTgt = get(gca, 'CameraTarget'); % where the camera is pointing to

camDir = camPos - camTgt; % camera direction
camUpVect = get(gca, 'CameraUpVector'); % camera 'up' vector

% build an orthonormal frame based on the viewing direction and the 
% up vector (the "view frame")
zAxis = camDir/norm(camDir);    
upAxis = camUpVect/norm(camUpVect); 
xAxis = cross(upAxis, zAxis);
yAxis = cross(zAxis, xAxis);

rot = [xAxis; yAxis; zAxis]; % view rotation 

% the point cloud represented in the view frame
rotatedPointCloud = rot * pointCloud; 

% the clicked point represented in the view frame
rotatedPointFront = rot * point' ;

% find the nearest neighbour to the clicked point 
pointCloudIndex = dsearchn(rotatedPointCloud(1:2,:)', ... 
    rotatedPointFront(1:2));

h = findobj(gca,'Tag','pt'); % try to find the old point
b = findobj(gca,'Tag','pts'); % try to find the old point
selectedPoint = pointCloud(:, pointCloudIndex); 

if ~isempty(h) % if it's the first click (i.e. no previous point to delete)
    delete(h); % delete the previously selected point
    delete(b); % delete the previously selected points
end

[brush_indices,~]=getVerticesAndFacesInSphere2(pointCloud',pointCloudIndex,brush_size);
brushPoints=pointCloud(:,brush_indices); %reshape
    % highlight the newly selected point
    h = plot3(selectedPoint(1,:), selectedPoint(2,:), ...
        selectedPoint(3,:), 'r.', 'MarkerSize', 25);  
    set(h,'Tag','pt');  % set its Tag property for later use
    %highlight the neighboring points
     b = plot3(brushPoints(1,:), brushPoints(2,:), ...
        brushPoints(3,:), 'y.');  
    set(b,'Tag','pts');  % set its Tag property for later use
    trodes.centr=selectedPoint';
    trodes.points=brushPoints';
    trodes.sphere=brush_indices;
if isfield(trodes,'postproc');
    trodes.vert=mesh_vertex_nearest(cell2mat(trodes.postproc(:,1)),trodes.centr);
    fprintf('You clicked on point number %d\n', trodes.vert);
end
    
    
%     %find the centroid
%     denSTATS = MRIdbscan(ct_points,SURFradius,min_neighbors);
%     %then apply a ruleset to find putative points
%     [elect_vert] = find_E_vertSURF(denSTATS,neybor_ratio);

 guidata(findobj('Tag','GUI'),trodes)

    %assignin('base','trodes',trodes);
    %assignin('caller','pointCloud',pointCloud);
    %setappdata(0,'trodes',trodes);
% else
%     trodes.points=[trodes.points; pointCloud(:,pointCloudIndex)'];
%     trodes.dex=[trodes.dex pointCloudIndex];
% end
    
    fprintf('The coords are (%f, %f, %f)\n',...
        selectedPoint(1,:), selectedPoint(2,:),selectedPoint(3,:));
try
 set(findobj(findobj('Tag','GUI'),'Tag','editIndex'),'String',num2str(trodes.vert)); %update a field on the gui
 set(findobj(findobj('Tag','GUI'),'Tag','editCoords'),'String',num2str(selectedPoint')); %update a field on the gui
 set(findobj(findobj('Tag','GUI'),'Tag','editName'),'String',trodes.postproc{trodes.vert,3}); %update a field on the gui
 set(findobj(findobj('Tag','GUI'),'Tag','editNeybs'),'String',''); %update a field on the gui
catch

    disp('no gui to update')
end %catch GUI update
%keyboard;
%update the variable int he workspace
end%function