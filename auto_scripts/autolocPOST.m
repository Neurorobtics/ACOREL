function [ePoints,denSTATS]=autolocPOST(ct_points,SURFradius,neybor_ratio,ney_abs)
%Automatically locate the electrode centroids. 
%Assumes the volume has had wires removed in pre-processing.
%INPUT: CT_img
%ex. CT_img=['C:\Users\WHINDS\Dropbox\Coregistration\subjects\' subject '\tal\images\combined\' subject '_CT_combined.img'];
%
% autolocPOST.m
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% change this depending on directory
%
ePoints=[];denSTATS=[];
if ~exist('SURFradius','var');SURFradius=2.9;end
if ~exist('neybor_ratio','var');neybor_ratio=.05;end
if isempty(neybor_ratio);neybor_ratio=.05;end
if ~exist('ney_abs','var');ney_abs=4;end
%if neybor_ratio>1;
    hires=0; %usually a higher resolution will be about half ~.5
    volres=1;
%Now Set some variables/parameters
if hires
    min_dist=13/volres; %11.5 millimeters (the macros are usually ~ 10 MM apart on the strips
    min_err=60;  %the minimum allowed euclidian distance for a pair of points
    min_neighbors=20; %can be used to hasten the scan if a certain neighbor threshold is desired.
     %use a higher percentage the better the resolution (.67)
    trode_size=44; %makes the centroid appear larger so it is not obscured
else %normalized volume [256x256x256]
    min_dist=12.1; %number of millimeters between electrodes on strips
    min_err=60;  %the minimum allowed euclidian distance for a pair of points
    min_neighbors=6; %can be used to hasten the scan if a certain neighbor threshold is desired.
    %neybor_ratio=.05; %use a lower percentage if volume is normalized (downsampled)
    trode_size=35; %lower resolution can get by with a smaller dot
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%figure;hold on;
%plot3(ct_points(:,1),ct_points(:,2),ct_points(:,3),'k.');
%Step #1
%Density-Based Scanning Algorithm
%finds the nearest neighbors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%volres=mean(old_ct.volres);
%Uses brute force to calculate the density stats for each point
denSTATS = MRIdbscan(ct_points,SURFradius,min_neighbors);
%then apply a ruleset to find putative points
[elect_vert] = find_E_vertSURF(denSTATS,neybor_ratio,ney_abs,SURFradius);
ePoints=ct_points(elect_vert,:);
%%%%%%%% PLOT %%%%%%%%%%%%%%
% figure;hold on;
% plot3(ct_points(:,1),ct_points(:,2),ct_points(:,3),'k.');
% es=plotE(ePoints,'r.',trode_size);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% USE STRIP GEOMETRY TO  EXCLUDE NOISE
%[noise,trodeNaybars]=find_strip(ePoints,6,min_dist); %extra step of processing for the CT trodes
%ePoints=ePoints(~ismember(1:size(ePoints,1),noise),:); %this should take out the points that violate strip geometry

% variables that can vary (somehow correlated). ELECTradius, min_neighbors, neybor_ratio
%
end %function end statement



