function [fnames]=create_file_names(subject,ws)
%creates the file names for a particular subject
%
% create_file_names.m
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DIRECTORY SETUP
fnames=struct;
str=which('acorel.m');home_dir=str(1:end-8);
[ pathstring,~ ] = get_sub_dir();
fnames.spath=[pathstring filesep subject filesep];
spath=fnames.spath;
fnames.vol=[spath 'vol' filesep];
fnames.docs=[spath 'docs' filesep];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% POST-PROCESSING FILES
fnames.postproc=[spath 'postproc.mat'];
fnames.postgrid=[spath 'postgrid.mat'];
fnames.trodetype=[spath 'trodetype.txt'];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COORDINATE FILES (for various scanner spaces and associated info)
fnames.jacksheet=[spath 'docs' filesep 'jacksheet.txt'];
fnames.locations=[spath 'implant_locations.txt'];
fnames.ras_master=[spath 'RAS_master.txt']; % FSL coords
fnames.vox_master=[spath 'VOX_master.txt'];
fnames.ras_master_names=[spath 'RAS_master_names.txt'];
fnames.vox_master_names=[spath 'VOX_master_names.txt'];
fnames.ras=[spath 'RAS_coords.txt'];
fnames.mni_master=[spath 'MNI_coords.txt'];
fnames.smni=[spath 'SMNI_coords.txt'];
fnames.yang=[spath 'grid_proj_coords.txt'];
fnames.post_master=[spath 'POST_master.txt']; %ICP coords
fnames.surf_master=[spath 'SURF_master.txt'];
fnames.depth_master=[spath 'DEPTH_master.txt'];
fnames.depth_warp=[spath 'DWARP_master.txt'];
fnames.gras=[spath 'GRAS_master.txt']; %SPM coords
fnames.warpedcoords_txt=[spath 'MNI152_master.txt'];
fnames.grey_master=[spath 'GREY_master.txt'];
fnames.fsl_surf_master=[spath 'FSL_surf_master.txt'];
fnames.spm_surf_master=[spath 'SPM_surf_master.txt'];
fnames.resect_master=[spath 'resect_master.txt'];
fnames.spared_master=[spath 'spared_master.txt'];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VOLUME FILES
fnames.CT_nii=[spath 'vol' filesep 'CT.nii'];
fnames.c1T1=[spath 'vol' filesep 'c1T1.nii'];
fnames.aseg=[spath 'vol' filesep 'aseg.nii'];
fnames.pre=[spath 'vol' filesep 'T1.nii'];
fnames.post=[spath 'vol' filesep 'postARTS.nii'];
fnames.post1=[spath 'vol' filesep 'postT1.nii'];
fnames.filled=[spath 'vol' filesep 'filled.nii'];
fnames.lh_pial_vol=[spath 'vol' filesep 'lh_pial.nii'];
fnames.rh_pial_vol=[spath 'vol' filesep 'rh_pial.nii'];
fnames.res=[spath 'res' filesep 'resected_seg.nii'];
fnames.res_surf=[spath 'res' filesep 'resected.surf'];
fnames.res_surf_smooth=[spath 'res' filesep 'resected.surf.smooth'];
fnames.res_final=[spath 'res' filesep 'resected_final.nii'];
fnames.coords_nii=[spath 'vol' filesep 'coords.nii'];
fnames.warpedcoords_nii=[spath 'vol' filesep 'wcoords.nii'];
fnames.warpedT1=[spath 'vol' filesep 'y_T1.nii'];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TRANSFORM FILES (for various scanner spaces and registrations)
fnames.lh_icp=[spath 'vol' filesep 'LH_ICP.lta'];
fnames.rh_icp=[spath 'vol' filesep 'RH_ICP.lta'];
fnames.mni=[spath 'mri' filesep 'transforms' filesep 'talairach.xfm'];
fnames.xfm=[spath 'vol' filesep 'CT2MRI.lta'];
fnames.CT2MRI=[spath 'vol' filesep 'CT2MRI.mat'];
fnames.CT2MRIp=[spath 'vol' filesep 'CT2MRIp.lta'];
fnames.Preg=[spath 'vol' filesep 'pre2post.reg'];
fnames.spm=[spath 'vol' filesep 'spm_coreg.xfm'];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SURFACE FILES
%the pial surfaces and curvature files
fnames.lhpial=[spath 'surf' filesep 'lh.pial'];
fnames.rhpial=[spath 'surf' filesep 'rh.pial'];
fnames.lhcurv=[spath 'surf' filesep 'lh.curv.pial'];
fnames.rhcurv=[spath 'surf' filesep 'rh.curv.pial'];
fnames.filled_surf=[spath 'vol' filesep 'filled.surf'];
fnames.filled_surf_main=[spath 'vol' filesep 'filled.surf.main'];
fnames.filled_smooth=[spath 'vol' filesep 'filled.surf.smooth'];
fnames.lh_smooth=[spath 'vol' filesep 'lh.surf.smooth'];
fnames.lh_filled_surf=[spath 'vol' filesep 'lh_filled.surf'];
fnames.rh_filled_surf=[spath 'vol' filesep 'rh_filled.surf'];
fnames.rh_smooth=[spath 'vol' filesep 'rh.surf.smooth'];
fnames.lhspherereg=[spath 'surf' filesep 'lh.sphere.reg'];
fnames.rhspherereg=[spath 'surf' filesep 'rh.sphere.reg'];
% ATLAS SURF FILES
%lh_BA=[spath 'label' filesep 'lh.BA.annot'];
%lh_aparc=[spath 'label' filesep 'lh.aparc.annot'];
fnames.lh_DKTatlas40 = [spath 'label' filesep 'lh.aparc.DKTatlas40.annot'];
fnames.rh_DKTatlas40 = [spath 'label' filesep 'rh.aparc.DKTatlas40.annot'];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PARAMETER FILES
%freesurfer color look up table (for anatomical info)
fnames.LUT=[home_dir 'fs_matlab' filesep 'FreeSurferColorLUT.txt'];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  old and unused files, as of yet
fnames.CT_img=[spath 'vol' filesep 'CT.img'];
%CTali=[spath '\vol\' subject '_CT2MRI.mgh']; %for use with old penn system
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MULTIMODAL FILES
%
fnames.LO=[spath 'vol' filesep 'left_OR.nii'];
fnames.RO=[spath 'vol' filesep 'right_OR.nii'];
fnames.rVisual=[spath 'vol' filesep 'rVisual.img'];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
assignin(ws,'fnames',fnames);
assignin(ws,'spath',spath);
assignin(ws,'subject',subject);
        
end
%