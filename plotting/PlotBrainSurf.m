function [Lhp,Rhp]=PlotBrainSurf(subject,varargin)
%[Lhp,Rhp]=PlotBrainSurf(subject,b_invCurv,surf,curv)
%Plots the 3D rendered brain surface as a patch
% subject = 'TJ056';
% b_invCurv - invert curvature
% surf - which surface to use
% curv - which curvature to use
%other possible inputs
%giffy - 0 or 1 to create a rotating gif
%colormap
%subject='TJ049';
%plots brain
%the patient's directory must have a folder labeled "surf" containing the surface files'
%%%%%%%%%%%%%USER EDIT REQUIRED%%%%%%%%%%%
%edit to reflect path to subjects directory
%ex: spath=['C:\Users\WHINDS\Dropbox\Coregistration\subjects\'];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
% PlotBrainSurf.m
%
% Original Author: Unknown
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
[ pathstring,~ ] = get_sub_dir(  );
spath=[pathstring filesep subject filesep];

            surf='pial';curv='curv.pial';b_invCurv=1;
            % Parse optional arguments
             if length(varargin) >= 1, b_invCurv = varargin{1};      end
            if length(varargin) >= 2, surf = varargin{2};             end
            if length(varargin) >= 3, curv = varargin{3};             end
           
                   
            %in case an average subject is specified, use avg curv
            if strfind(subject,'average');
            curv='curv';surf='pial';
            end


     fname = [spath 'surf' filesep 'lh.' surf];
     fname2=[spath 'surf' filesep 'lh.' curv];
     fname3=[spath 'surf' filesep 'rh.' surf];
     fname4=[spath 'surf' filesep 'rh.' curv];
     
     %in case an MNI N27 average subject is specified
            if strcmp(subject,'N27');
            fname = [fname '.gii'];
            fname2=[];
            fname3=[fname3 '.gii'];
            fname4=[];
            end
            
%code to "snap" a 3D-point (aka electrode) to the nearest vertex of the brain 'surface'
%      [vertex_coords, faces] = read_surf(fname);
%      [nearestIndexB,nearestValuesB] = mesh_vertex_nearest(vertex_coords,pointsB);
%      [nearestIndexR,nearestValuesR] = mesh_vertex_nearest(vertex_coords,pointsR);
            
%draw the left and right hemisphere separately
%set some default variables
az=270;el=0;af_bandFilter=1;
if ~ischar(b_invCurv)
    %print a normal surface with curvature face color
    [hf, Lhp, av_filtered] = mris_display(fname, fname2, az, el, af_bandFilter, b_invCurv);
    hold on;
    [hf, Rhp, av_filtered] = mris_display(fname3, fname4, az, el, af_bandFilter, b_invCurv);
elseif strcmp(b_inv_Curv,'annot')
    %plot a multi-color label brain with regions
    
else
    error('invalid argument')
end
       

lighting phong

%colormap('spring');
%scripts for loading electrode .txt files as an [Nx3] vector
% MM_coords_MR=load('C:\Users\WHINDS\Dropbox\Coregistration\subjects\TJ019\MM_coords_MR_19.txt');
% plot3(MM_coords_MR(:,1),MM_coords_MR(:,2),MM_coords_MR:,3),'b.','markersize',30);
%
%camlight(-90,0)
% camlight(90,0, 'infinite');
% camlight(-90,0, 'infinite');
camlight('headlight','infinite')
h=rotate3d;
set(h,'ActionPostCallback',@new_light)
shading interp;
camproj('orthographic');
set(gca,'visible','off') %removes the axes
colorbar('off') %removes the colorbar
axis vis3d %prevents axis from changing
set(gcf,'Color','white') %make sthe background color white
material dull; %makes the brain dull instead of shiny
caxis([-3 3]); %normalizes the curvature contrast (greyness of brain)
fprintf('\nPlease use "bview(az,el)" or the rotate button to ensure correct lighting angle\n')

    function new_light(obj,event_obj)
        delete(findobj(gca, 'type', 'light'));
        camlight('headlight','infinite')
    end
%
%END of surface rendering code
%
end %the end of the function call