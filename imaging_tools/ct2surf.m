function [ct_ras]=ct2surf(CT_nii,xfm,Preg)
%%% LOAD CT volume
% CT_nii - the filepath to the CT volume
% xfm - the transform (LTA file) from the CT volume -> Surface (preMRI)
% Preg - 
%
% ct_ras - the 3D points of the CT electrode artifacts
%%%%%%%%%%%%%%%%%
% ct2surf.m
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
ct=MRIread(CT_nii);
ct_vox=mri_binarize(ct,'max');
%%% XFM into POST MRI space
L=lta_read(xfm);
ct_brain=vox2vox(ct_vox,L);
M=[-1 0 0 128;0 0 1 -128;0 -1 0 128;0 0 0 1;];
ct_brain_ras=vox2labelxyz(ct_brain,M);
ct_ras=ct_brain_ras;
if exist('Preg','var')&nargin>2;
    try
    %%% XFM into PRE MRI space
    pre2post=reg_read(Preg);
    preRAS=inv(pre2post)*[ct_brain_ras,ones(size(tkrRAS,1),1)]';
    ct_ras=preRAS(1:3,:)';
    catch
    ct_ras=ct_brain_ras;
    end
end
end %function end