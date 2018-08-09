function [varargout]=acorel(subject,protocol,varargin)
%[varargsout]=acorel(subject,protocol)
%Automatically co-register and localize electrodes
%INPUT: subject - a string corresponding to the patient code, 
%                   ex: subject='TJ055';
%       protocol - which automized protocol to run
%                   ex: [1 2 3], 'all'
%
% acorel.m
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
GUI_mode=0;
        if ~exist('protocol','var')|~exist('subject','var')
            disp('No protocol specified: Entering GUI mode');
            GUI_mode=1;protocol='none';
            if ~exist('subject','var');subject=[];end
        end
        if ischar(protocol);
            if strfind('all',protocol);protocol=[0 1 2 3 4];end
        end
        if GUI_mode
            acorel_GUI(subject)
            return;
        end
            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BEGIN PROTOCOL SCRIPTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% 0. INITIALIZE FILE NAMES (~0 minutes)
% Create strings of all the file names
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if protocol==0
    %create variables in base workspace
    ws='base';
else
    %create variables in caller function (acorel)
    ws='caller';
end
varargout{1}=create_file_names(subject,ws);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%1. AUTO-LOCALIZATION (~10 minutes)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if protocol==1
%AUTOLOC after recon-all (incorporates noise stripping)
    [ct_ras]=ct2surf(fnames.CT_nii,fnames.xfm);
    if numel(varargin)==1
        max_dist=varargin{1};
    else
        %max_dist=9; %for poor registrations..
         max_dist=7; %for better registrations
    end
    %about 5 - 6 minutes
    [ ct_clean, ct_diffs, ct_strip ] = strip_noise2( ct_ras, fnames.filled, max_dist );
    %[ ct_clean , ct_strip ] = restrip_noise( ct_diffs, ct_disp, ct_ras, max_dist );
    %[eRAS,~]=autolocPOST(ct_points);
    %return the useful variables
    %varargout{1}=ct_points;varargout{2}=eRAS;%varargout{3}=denSTATS;
    %begin GUI
    postprocPOST(subject, ct_ras, ct_diffs, ct_strip);
end %protocol #1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if protocol==2
%2. ENHANCED AUTO-REG
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%NEW METHOD (uses the point clouds)
autoreg_icp(subject)
%OLD METHOD (uses the centroids)
%[new_electrodes,transform,d]=autoreg(post_volume,electrodes_MM,'horn');
%Two different algorithms can be used to fit the CT electrodes to the MRI
%target points: horn quaternerion or procrustes, 'horn' and 'proc',
%respectively
end %protocol #2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if protocol==3
%3. AUTO-LABEL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[labels]=autolabel(aseg_volume,new_electrodes);
%plot_label
end %protocol #3
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if protocol==4
%4. GENERATE IMAGES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%PlotBrainSurf(subject)
%plot_label
plot_depths(pre_volume,depth_coords,'g.');
%savemultifigs
%make_gif
end %protocol #4
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end %function end statement



