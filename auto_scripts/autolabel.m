function [labels]=autolabel(aseg_volume,electrode_coords,LUT)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%elect_coords must be in tkr-ras millimeters (mm)
%if the recon-all has been performed, an aseg+aparc.mgz should have been
%created with it, this will have the anaotomies
%
% autolabel.m
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
labels={};
aseg=MRIread(aseg_volume); %load the volume
aseg_vol=aseg.vol;%[256x256x256] volume matrix
tkrvox2ras=aseg.tkrvox2ras;%transform
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%find anatomical locations from LUT
Z3 =xyz2vox(electrode_coords,tkrvox2ras);
[code, name, rgbv] = read_fscolorlut(LUT);
aseg_points=[];
for e=1:size(Z3,1)
    %round to nearest voxel integer
    i=round(Z3(e,1));j=round(Z3(e,2));k=round(Z3(e,3));
    %create aseg_points array - [x,y,z,ID#]
    aseg_points(end+1,:)=[i j k aseg_vol(i,j,k)];
labels{e}=name(find(code==aseg_vol(i,j,k)),:);
end
%
%files for automatically labeling the anatomy corresponding to electrode
%locations
% rhAPARC_label=['C:\Users\WHINDS\Dropbox\Coregistration\subjects\' subject '\label\rh.aparc.annot'];
% lhAPARC_label=['C:\Users\WHINDS\Dropbox\Coregistration\subjects\' subject '\label\lh.aparc.annot'];
% [vertices,label,colortable]=read_annotation(rhAPARC_label);
end%function end statement