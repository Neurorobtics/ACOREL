function [ all_surf_coords,orig_coords,orig_names ] = subTrode_projection( subject,whichcoords,coords_fname)
%Automatically project the subjects electrodes to the surface

% ONLY DOES SURFACE

% DOES NOT WRITE DEPTHS

%whichcoords = 'pre';
%whichcoords = 'post';
%%%%%%%%%%%%%%%%%%
% subTrode_projection.m
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
%if ~exist('skipDepths','var');skipDepths=[];end
if ~exist('whichcoords','var');whichcoords='post';end
fnames=acorel(subject,0);
if ~exist('coords_fname','var');coords_fname=fnames.surf_master;end

[skipStrips,skipDepths,skipGrids]=read_trodetypes(fnames.trodetype);
if strcmpi(whichcoords,'post')
%find the coords
[coords,names]=read_coords(fnames.post_master);
elseif strcmpi(whichcoords,'pre')
[coords,names]=read_coords(fnames.ras_master); 
elseif strcmpi(whichcoords,'gras')
[coords,names]=read_coords(fnames.gras); 
else
    error('which coords?')
end
%find unique names
just_letters={};
for n=1:numel(names)
just_letters{n}=names{n}(1:sum(isstrprop(names{n}, 'alpha')));
end
[fam_names,~,fam_indexes]=unique(just_letters);
%%%
  tempskipDepths=[];tempskipGrids=[];tempskipStrips=[];
%parse out depths
if iscell(skipDepths)|~isnumeric(skipDepths)
    for d=1:numel(skipDepths)
        tempskipDepths(end+1)=find(strcmp(fam_names,skipDepths{d}));
    end
    skipDepths=tempskipDepths;
end
%parse out grids
if iscell(skipGrids)|~isnumeric(skipGrids)
    for d=1:numel(skipGrids)
        tempskipGrids(end+1)=find(strcmp(fam_names,skipGrids{d}));
    end
    skipGrids=tempskipGrids;
end
%parse out stripss
if iscell(skipStrips)|~isnumeric(skipStrips)
    for d=1:numel(skipStrips)
        tempskipStrips(end+1)=find(strcmp(fam_names,skipStrips{d}));
    end
    skipStrips=tempskipStrips;
end
%%%%%%
    %get smooth vertices
[rh_smooth.vertices,rh_smooth.faces]=read_surf(fnames.rh_smooth);
rh_smooth.faces=rh_smooth.faces+1;
[lh_smooth.vertices,lh_smooth.faces]=read_surf(fnames.lh_smooth);
lh_smooth.faces=lh_smooth.faces+1;
filled.vertices=[rh_smooth.vertices;lh_smooth.vertices];
clear('lh_smooth','rh_smooth')
% get the pial surface
     %get pial vertices
        [rh_pial.vertices,rh_pial.faces]=read_surf(fnames.rhpial);
        rh_pial.faces=rh_pial.faces+1;
        [lh_pial.vertices,lh_pial.faces]=read_surf(fnames.lhpial);
        lh_pial.faces=lh_pial.faces+1;
        pial.vertices=[rh_pial.vertices;lh_pial.vertices];
        clear('lh_pial','rh_pial')
all_surf_coords=[];orig_coords=[];orig_names={};
for i=1:numel(fam_names)
    %skip any depth electrodes as they will be warped later
    if ismember(i,skipDepths);
        continue;
    end
    if ismember(i,skipGrids);

    end
    if ismember(i,skipStrips);   
        %%%%%%%%%%%%%%
        %  ONLY DOING SMOOOTH FOR STRIPS NOW
    end
    % determine which hemisphere to use
    % NOTE: Usually it is best to use all vertices now, but sometimes
    % inter-hemispheric electrodes can cause problems depending on which
    % hemisphere you use
%     if strcmpi(fam_names{i}(1),'r')
%         filled=rh_smooth;
%     elseif strcmpi(fam_names{i}(1),'l')
%         filled=lh_smooth;
%     else
%         error('which hemisphere does this family belong to?')
%     end
[ surf_coords ] = surf_norm2( coords(fam_indexes==i,:), filled.vertices,13,names(fam_indexes==i,:) );
%
%if strcmpi(fam_names(i),'RFA');keyboard;end % for debugging individual
%strips
%
all_surf_coords(end+1:end+sum(fam_indexes==i),:)=surf_coords;
orig_coords(end+1:end+sum(fam_indexes==i),:)=coords(fam_indexes==i,:);
orig_names(end+1:end+sum(fam_indexes==i))=names(fam_indexes==i);
disp(['completed trode family ' fam_names{i}])
end
% snap to pial surface
[~,pial_coords]=mesh_vertex_nearest(pial.vertices,all_surf_coords);
%
% DO THE DEPTHS (STILL EXPERIMENTAL)
all_depth_coords=[];
if ~isempty(skipDepths) & 1==2 %still experimental
    orig_depth_coords=[];
    for i=1:numel(fam_names)
        if ismember(i,skipDepths);
            regP=.7;
            %experimental DEPTH WARP
            [new_depths]=warp_depths(all_surf_coords,orig_coords,coords(fam_indexes==i,:),regP);
            all_depth_coords(end+1:end+sum(fam_indexes==i),:)=new_depths;
            orig_depth_coords(end+1:end+sum(fam_indexes==i),:)=coords(fam_indexes==i,:);
            orig_names(end+1:end+sum(fam_indexes==i))=names(fam_indexes==i);
            disp(['completed trode family ' fam_names{i}])
        end
    end
else % just add the depths on the end
    
    orig_depth_coords=[];
    for i=1:numel(fam_names)
        if ismember(i,skipDepths);
            
            [new_depths]=coords(fam_indexes==i,:);
            all_depth_coords(end+1:end+sum(fam_indexes==i),:)=new_depths;
            orig_depth_coords(end+1:end+sum(fam_indexes==i),:)=coords(fam_indexes==i,:);
            orig_names(end+1:end+sum(fam_indexes==i))=names(fam_indexes==i);
            disp(['added depth trode family ' fam_names{i}])
        end
    end
    
end

% WRITE TO A TXT FILE
%order electrodes
all_trodes=[pial_coords;all_depth_coords];
[ sorted_coords,sorted_names ] = order_trodes(all_trodes,orig_names);

                  fid = fopen(coords_fname,'w');
                  %have to do for loop cause fprintf doesnt support cells
                  for q=1:size(sorted_coords,1)
                  %fprintf(fid,'%5.5g %5.5g %5.5g %s\n',coords(q,:),names{q});
                    fprintf(fid,'%5.5g %5.5g %5.5g %s\n',sorted_coords(q,:),sorted_names{q});
                  end
                  fclose(fid); 
% %CALCULATE MNI COORDS AND SAVE THEM
% [mni_coords]=ras2mni(sorted_coords,subject);
% write_coords(mni_coords,sorted_names,fnames.mni_master)
%return;
anatomy_too=0;
if anatomy_too
%FIND CLOSEST REGION AND SAVE IT
[anatomy]=subAutolabel(subject);
                  fid = fopen(fnames.locations,'w');
                  %have to do for loop cause fprintf doesnt support cells
                  for q=1:numel(anatomy)
                      hem=strsplit(anatomy{q});
                      if numel(hem)==1;hem{2}=' ';end
                  %fprintf(fid,'%5.5g %5.5g %5.5g %s\n',coords(q,:),names{q});
                    fprintf(fid,'%s %s %s\n',hem{1},hem{2},sorted_names{q});
                  end
                  fclose(fid); 
end %anatomy IF
%write_coords(coords,names,fname )
% PLOT THE RESULTS OF THE PROJECTION
% figure;hold on;
% plotE(filled.vertices,'k.',4)
% plotE(post_coords,'b.');
% plotE(surf_coords,'r.');
%plot_trode_lines(
end

