function [elect_vert] = find_E_vertSURF(denSTATS,ney,ney_abs,SURFradius)
%finds the putative electrode vertices
%
%
% find_E_vertSURF.m
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist('ney','var');ney=.05;end
if ~exist('ney_abs','var');ney_abs=3;end
if ~exist('SURFradius','var');SURFradius=1;disp('SURFradius = 1');end
%check if being used with GUI, then perform differently
if ney==1;
    ney=.0001;ney_abs=0;
    gui_new=1;
else
    gui_new=0;
end

nearestVerts={denSTATS(:).nearestVerts};
%distanceVerts={denSTATS(:).nearestVerts};
neighborVectM=[denSTATS(:).neighborVectM];
neybors=[denSTATS.neybors];neighborDens=[denSTATS(:).dens];
sorted1=sort(neybors,'descend');

elect_vert=[];
old_vert=[];all_dverts=[];all_NVM=[];all_dens=[];all_neybs=[];

for dex=1:length(denSTATS)
    %a little bit of code to make sure the algorithm starts with points who have the most
    %neybors
    if  sorted1(dex)==0;continue;end
    vert=find(neybors==sorted1(dex));
    if numel(vert)>1;
        vert=vert( ~(neighborVectM(vert)==0|isinf(neighborVectM(vert))|ismember(vert,old_vert)) );
        [~,vert2]=min(neighborVectM(vert));
        if numel(vert2)>1;
            disp('keyboard;')
        end
        vert=vert(vert2);
    
    end
    if isempty(vert);continue;end
    old_vert(end+1)=vert;
    dverts=denSTATS(vert).distanceVerts;
    verts=nearestVerts{vert};
    nverts=verts(~ismember(verts,elect_vert)); %so as not to compete with others
    %nverts=nverts(neighborVectM(nverts)~=0);
    neybsVectM=neighborVectM(nverts);
    neybsVectM=neybsVectM(neybsVectM~=0);
    dens=neighborDens(vert);
    %%%%%%%%%%%%%%%%%%%%%%
    % LOGIC DECISION TREE
    %%%%%%%%%%%%%%%%%%%%%%
    % if these are triggered, point is passed over
    %
    % 1. magnitude of summed neighbor vectors larger than neighbor
    % 2. more neighbors
    % 3. none that were already selected and none with mag=0
    % 4. must be above .05 quantile
    % 5. at least six points within 1 mm
    % 6. at most mag<90, and at least 3 neighbors
    if ...
       (~any(~(neighborVectM(vert)<=neybsVectM)) | ~any(~(neybors(vert)>=neybors(nverts)))... %highest density value 1. and 2.
       | ~any(~(dens<=neighborDens(nverts))))...%|(sum(dverts==1)>=6 & sum(dverts==sqrt(2))>=12 & sum(dverts==sqrt(3))>=8)) ...      
         & neighborVectM(vert)>0 ... %3.
         & ~any(ismember(verts,elect_vert))...%don't pick any already chosen 3.
              & neybors(vert)>=quantile(neybors(neybors>0),ney)... %4. must be above .165 quantile in number of neighbors within radius 
              & (sum(dverts<=1)>=6 |  gui_new)... %  5. at least 6 points within 1 mm
              & (neighborVectM(vert)<90 |  gui_new) ... %
                 & neybors(vert)>=ney_abs
              %only works for 1mm space
              %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %& ~any(ismember(verts(dverts<quantile(dverts,.999)),elect_vert))... %this requirement appears to not affect results, perhaps the normalize vector magnitude nullifies it         
          %& sum(dverts<=median(dverts))>sum(dverts>mean(dverts)) ...
                %     & sum(dverts<=median(dverts))>sum(dverts>mean(dverts)) ...
%         &sum(neybors(vert)<neybors(nearestVerts{vert}))==0 ... %must be best or tied for most neighbors
%         &neybors(vert)<quantile(neybors,.9) ... %must be below the .9 quantile
%         &avg_dist(vert)<=peak_dist
         %& sum(dverts<=median(dverts))>sum(dverts>mean(dverts))... % hmmm
           
           all_dverts=[all_dverts sum(denSTATS(vert).distanceVerts<=SURFradius/2)]; % save this stat for later filtering 
           all_NVM=[all_NVM neighborVectM(vert)];
           all_dens=[all_dens dens];
           all_neybs=[all_neybs neybors(vert)];
        elect_vert=[elect_vert,vert];
    end  
end %loop through vertices
% add a final loop through the finished vertices and remove those unlike
% the others (9/2/15 wh)
%keyboard;
%all_deverts={denSTATS(elect_vert).distanceVerts};

delete_elect_vert=[];dscale=[];
for d=1:length(elect_vert)
    vert=elect_vert(d);
     %if all_dverts(d)<quantile(all_dverts,.17) + all_NVM(d)>quantile(all_NVM,.84) + all_dens(d)>quantile(all_dens,.83) + all_neybs(d)<quantile(all_neybs,.17)
         dscale(d,1)=all_dverts(d)<quantile(all_dverts,.17);
         dscale(d,2)=all_NVM(d)>quantile(all_NVM,.84);
         dscale(d,3)=all_dens(d)>quantile(all_dens,.83);
         dscale(d,4)=all_neybs(d)<quantile(all_neybs,.17);
         if sum(dscale(d,:)==1)>1
             delete_elect_vert=[delete_elect_vert,d];
         end
         
     %end
     
end %final loop through elect_verts to filter false-positives
%elect_vert(delete_elect_vert)=[];
old_elect_vert=elect_vert;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% more rigorous loop through with new logic
elect_vert=[];
old_vert=[];vscale=[];

for dex=1:length(denSTATS)
    %a little bit of code to make sure the algorithm starts with points who have the most
    %neybors
    if  sorted1(dex)==0;continue;end
    vert=find(neybors==sorted1(dex));
    if numel(vert)>1;
        vert=vert( ~(neighborVectM(vert)==0|isinf(neighborVectM(vert))|ismember(vert,old_vert)) );
        [~,vert2]=min(neighborVectM(vert));
        if numel(vert2)>1;
            disp('keyboard;')
        end
        vert=vert(vert2);
    
    end
    if isempty(vert);continue;end
    %%
    if ismember(vert,old_elect_vert(delete_elect_vert));continue;end
   
    %%%
    old_vert(end+1)=vert;
    dverts=denSTATS(vert).distanceVerts;
    verts=nearestVerts{vert};
    nverts=verts(~ismember(verts,elect_vert)); %so as not to compete with others
    %nverts=nverts(neighborVectM(nverts)~=0);
    neybsVectM=neighborVectM(nverts);
    neybsVectM=neybsVectM(neybsVectM~=0);
    dens=neighborDens(vert);
    %%%%%%
         vscale(vert,1)=sum(denSTATS(vert).distanceVerts<=SURFradius/2)<quantile(all_dverts,.17);
         vscale(vert,2)=neighborVectM(vert)>quantile(all_NVM,.84);
         vscale(vert,3)=dens>quantile(all_dens,.83);
         vscale(vert,4)=neybors(vert)<quantile(all_neybs,.17);
         if sum(vscale(vert,:)==1)>2; continue;end
    %%%%
    if ...
       (~any(~(neighborVectM(vert)<=neybsVectM)) | ~any(~(neybors(vert)>=neybors(nverts)))... %highest density value
       | ~any(~(dens<=neighborDens(nverts))))...%|(sum(dverts==1)>=6 & sum(dverts==sqrt(2))>=12 & sum(dverts==sqrt(3))>=8)) ...      
         & neighborVectM(vert)>0 ...
         & ~any(ismember(verts,elect_vert))...%don't pick any already chosen
              & neybors(vert)>=quantile(neybors(neybors>0),ney)... %must be above .165 quantile in number of neighbors within radius 
              & (sum(dverts<=1)>=6 |  gui_new)... %  
              & (neighborVectM(vert)<90 |  gui_new) ...
                 & neybors(vert)>=ney_abs
              %only works for 1mm space
              %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        %& ~any(ismember(verts(dverts<quantile(dverts,.999)),elect_vert))... %this requirement appears to not affect results, perhaps the normalize vector magnitude nullifies it         
          %& sum(dverts<=median(dverts))>sum(dverts>mean(dverts)) ...
                %     & sum(dverts<=median(dverts))>sum(dverts>mean(dverts)) ...
%         &sum(neybors(vert)<neybors(nearestVerts{vert}))==0 ... %must be best or tied for most neighbors
%         &neybors(vert)<quantile(neybors,.9) ... %must be below the .9 quantile
%         &avg_dist(vert)<=peak_dist
         %& sum(dverts<=median(dverts))>sum(dverts>mean(dverts))... % hmmm
           
%            all_dverts=[all_dverts sum(denSTATS(vert).distanceVerts<=SURFradius/2)]; % save this stat for later filtering 
%            all_NVM=[all_NVM neighborVectM(vert)];
%            all_dens=[all_dens dens];
%            all_neybs=[all_neybs neybors(vert)];
        elect_vert=[elect_vert,vert];
    end  
end %loop through vertices
%new_thresh=quantile(neybors(elect_vert),.05)

end %function end