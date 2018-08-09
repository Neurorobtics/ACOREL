function [ surf_coords ] = surf_norm( electrodes, filled_vertices, e_int, names,plot_result )
%surf_norm -
%
% e_int - the electrode interval for grids 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist('e_int','var');e_int=10;end
if ~exist('plot_result','var');plot_result=0;end
% First determine type of implant (grid vs strip)

if size(electrodes,1)>8;
% grid projection
for e=1:size(electrodes,1)
%find nearest neighbors
[verticesList, ~] = getVerticesAndFacesInSphere2(electrodes, e, e_int+.22*e_int);
X=electrodes(verticesList,:);
[coeff,score,roots] = princomp(X);
basis = coeff(:,1:2);

normal = coeff(:,3);
temp_surf_coords=[];reach=.25;flip=0;
while isempty(temp_surf_coords)&flip~=2
    if reach>5;normal=-(normal);reach=.25;flip=flip+1;end %if nothing comes from positive direction, switch to negative
for t=1:.1:40;
normline_plus=electrodes(e,:)+t*normal';
[surfListplus] = isVertexInRadius2(filled_vertices, normline_plus, reach);
if sum(surfListplus)>0;
indies=find(surfListplus);
try
temp_surf_coords=filled_vertices(indies,:);
catch
    %I think I fixed this lower down with eud..
    disp('might find two close surf points')
    dists1=eud(filled_vertices(surfListplus,:),normline_plus);
    dists2=eud(filled_vertices(surfListminus,:),normline_minus);
    temp_surf_coords=filled_vertices(indies(dists==min(dists1)),:);
end
%if ismember(e,[50,55,60]);keyboard;end
break
end
end
reach=reach+.1;
end
[~,m]=min(eud(electrodes(e,:),temp_surf_coords)); %in case there are multiple vertexes, pick the closest
surf_coords(e,:)=temp_surf_coords(m,:);
%(filled_vertices-electrodes(e,:))*normal

%calculate the residuals
[n,p] = size(X);
meanX = mean(X,1);
Xfit = repmat(meanX,n,1) + score(:,1:2)*coeff(:,1:2)';
residuals = X - Xfit;
end% electrode loop end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
else % strip projection
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
[~,vex]=min([dot(N(1,:),mean(T)');dot(B(1,:),mean(T)')]);
if vex==2;
    U=N;
else
    U=B;
end
for e=1:size(strode,1)
    fprintf('%s...',num2str(e));
normal=-U(e,:)'; %negative because the arror points in (see myfrenet)
temp_surf_coords=[];reach=.05;flip=0;
while isempty(temp_surf_coords)&flip~=2
   if reach>5;normal=-(normal);reach=.25;flip=flip+1;end %if nothing comes from positive direction, switch to negative
for t=1:.1:40;
normline=strode(e,:)+t*normal';
[surfList] = isVertexInRadius2(filled_vertices, normline, reach);
if sum(surfList)==0;continue;end
indies=find(surfList);
dists=eud(filled_vertices(surfList,:),normline);
temp_surf_coords=filled_vertices(indies(dists==min(dists)),:);
end
reach=reach+.1;
end
if isempty(temp_surf_coords)
    error('no surface point found')
    temp_surf_coords=mesh_vertex_nearest(filled_vertices,strode(e,:));
end
surf_coords(e,:)=temp_surf_coords;
end
%[indi,~]=mesh_vertex_nearest(surf_coords,electrodes); %reorder the electrodes
surf_coords=surf_coords(sorder,:);

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

