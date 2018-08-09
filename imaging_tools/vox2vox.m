function [ new_voxels ] = vox2vox( voxels, transform , noInv)
%applies a vox2vox transform in the matlab environment
%
%
% vox2vox.m
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist('noInv','var');noInv=0;end
new_voxels=[];
if isempty(voxels);return;end
if ~noInv
Mvox=[voxels(:,2) voxels(:,1) voxels(:,3) ones(size(voxels,1),1)];
else
    % do not invert the y and z axis
    Mvox=[voxels(:,1) voxels(:,2) voxels(:,3) ones(size(voxels,1),1)];
end
Nvox=transform*Mvox';
new_voxels=[Nvox(2,:)' Nvox(1,:)' Nvox(3,:)'];

end

