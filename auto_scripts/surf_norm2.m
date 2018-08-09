function [ surf_coords ] = surf_norm2( electrodes, filled_vertices, e_int, names,plot_result )
%surf_norm2 -
% electrodes - the Nx3 points
% filled_vertices - the vertices of the smoothed or pial surface
% e_int - the electrode interval for grids 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% surf_norm2.m
%
% Original Author: Walter Hinds
%    $Date: 01/01/2017 00:04:12 $
%
% Copyright © 2017 Drexel University
%
% Terms and conditions for use, reproduction, distribution and contribution
% are found in the 'ACOREL Software License Agreement' contained
% in the file 'LICENSE' found in the ACOREL distribution.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist('e_int','var');e_int=10;end
if ~exist('plot_result','var');plot_result=0;end
%initial parameters
surf_coords=[];increment=.2;reach_start=2; %reach=2.5;
% First determine type of implant (grid vs strip)
if size(electrodes,1)>8;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GRID
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% grid projection
for e=1:size(electrodes,1)
    fprintf('%s...',num2str(e));
%find nearest neighbors
[verticesList, ~] = getVerticesAndFacesInSphere2(electrodes, e, e_int+.22*e_int);
X=electrodes(verticesList,:);
[coeff,score,roots] = princomp(X);
basis = coeff(:,1:2);

normal = coeff(:,3);
temp_surf_coords=[];
flip=0;reach=reach_start;
while size(temp_surf_coords,1)<2%&reach<10&flip<=1
    if reach>10;normal=-normal;flip=flip+1;reach=reach_start;end
    
for t=0:increment:40;
normline_plus=electrodes(e,:)+t*normal';
%normline_minus=electrodes(e,:)-t*normal';
[surfListplus] = isVertexInRadius2(filled_vertices, normline_plus, reach);
%[surfListminus] = isVertexInRadius2(filled_vertices, normline_minus, reach);
surfListminus=zeros(size(filled_vertices,1),1);
if sum([surfListplus+surfListminus])>0;
indies=find([surfListplus+surfListminus]);
dists=eud(filled_vertices(indies,:),electrodes(e,:));
 temp_surf_coords(end+1,:)=filled_vertices(indies(dists==min(dists)),:);
 reach=11;
 break;
end
%if ismember(e,[50,55,60]);keyboard;end
end
reach=reach+increment;
end
[~,m]=min(eud(electrodes(e,:),temp_surf_coords)); %in case there are multiple vertexes, pick the closest
surf_coords(end+1,:)=temp_surf_coords(m,:);
%(filled_vertices-electrodes(e,:))*normal

%calculate the residuals
[n,p] = size(X);
meanX = mean(X,1);
Xfit = repmat(meanX,n,1) + score(:,1:2)*coeff(:,1:2)';
residuals = X - Xfit;
end% electrode loop end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STRIP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif size(electrodes,1)<=8 & size(electrodes,1)>=3;% strip projection
if ~exist('names','var');
    disp('assuming coordinates are already in strip order');
else
   [strode ,sorder]=sort_trodes(electrodes,names);
end
%  A = [electrodes(:,1) electrodes(:,2) ones(size(electrodes,1),1)];
%  b = electrodes(:,3);
%  d=pinv(A)*b;
[T, ~,~]=myfrenet(strode(:,1),strode(:,2),strode(:,3)); %[T N B]
[~, N, B]=myfrenet(strode(:,1),strode(:,2),strode(:,3),mean(T)'); %[T N B]
    for p=2:size(strode,1)-1
    frenny(p-1,:)=[abs(dot(N(p,:),mean(T)'));abs(dot(B(p,:),mean(T)'))];
    end %determine whether to use normal or binormal
    [~,vex]=min(mean(frenny));
if vex==2;
    U=N;
else
    U=B;
end
if plot_result==1;myfrenet(strode(:,1),strode(:,2),strode(:,3),mean(T)');end

for e=1:size(strode,1)
    fprintf('%s...',num2str(e));
normal=-U(e,:)'; %negative because the arror points in (see myfrenet)
temp_surf_coords=[];reach=reach_start; %reset reach to 2 mm
while isempty(temp_surf_coords)&reach<10
   %if reach>5;normal=-(normal);reach=.25;flip=flip+1;end %if nothing comes from positive direction, switch to negative
for t=0:increment:40;
normline_plus=strode(e,:)+t*normal';
normline_minus=strode(e,:)-t*normal';
[surfListplus] = isVertexInRadius2(filled_vertices, normline_plus, reach);
[surfListminus] = isVertexInRadius2(filled_vertices, normline_minus, reach);
if sum([surfListplus+surfListminus])>0;
indies=find([surfListplus+surfListminus]);
dists=eud(filled_vertices(indies,:),strode(e,:));
 temp_surf_coords=filled_vertices(indies(dists==min(dists)),:);
 break;
end
end
reach=reach+increment;
end %while loop extending normals
if isempty(temp_surf_coords)
    % still need to figure out a good solution for this
    disp('no surface point found, snapping to nearest surface vertex')
    disp('electrode may be floating')
    [~,temp_surf_coords]=mesh_vertex_nearest(filled_vertices,strode(e,:));
end
surf_coords(sorder==e,:)=temp_surf_coords;
end %strip electrodes loop
%[indi,~]=mesh_vertex_nearest(surf_coords,electrodes); %reorder the electrodes
%surf_coords=surf_coords(sorder,:);
elseif size(electrodes,1)<3
    for e=1:size(electrodes,1)
    [~,surf_coords(e,:)]=mesh_vertex_nearest(filled_vertices,electrodes(e,:));
    end
    
else
    disp('how many contacts on this electrode?')
    
end %decide if strip or grid
    
    %plot_result=0;
 if plot_result
    figure;
    hold on
    plotE(electrodes,'b.',30)
    plotE(surf_coords,'r.',30)
    plot_trode_lines(surf_coords,electrodes);
    plotE(filled_vertices,'k.',3);
 end

end %surf_norm function end

%%%
%make the normal line
% x=linspace(1,400,40);
% xyz=[normal(1)*x;normal(2)*x;normal(3)*x]';
% bline=xyz;
% normal=-normal;
% xyz=[normal(1)*x;normal(2)*x;normal(3)*x]';
% bline=[bline;xyz];
% %add to point
% bline=bline+electrodes(e,:);
% %
% for v=1:size(filled_vertices,1)
% dists=eud(bline,filled_vertices(v,:));
% vert_dists(v)=min(dists);
% end
% [~,i]=min(vert_dists);
% %%%%%%%%
