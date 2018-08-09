function xyzlab =vox2labelxyz(points,vox2ras0,oneBase)
%
% looks to be the same as vox2xyz.m
%
% xyzlab = vox2labelxyz(points,vox2ras0)
% points - N x 3 array of row,column,slice
%[128 128 128] -> [0 0 0]

% Computes the xyz for use in a label of the voxels in
% the segmentation volume.
%
% segmri - MRI struct. eg, segmri = MRIread('segvol');
% segid - id to find in the seg (default is 1)
%
% xyzlab - xyz in segvol's RAS space (defined by segmri.vox2ras0)
%


%
% MRIseg2labelxyz.m
%
% Original Author: Doug Greve
% CVS Revision Info:
%    $Author: nicks $
%    $Date: 2011/03/02 00:04:12 $
%    $Revision: 1.3 $
%
% Copyright © 2011 The General Hospital Corporation (Boston, MA) "MGH"
%
% Terms and conditions for use, reproduction, distribution and contribution
% are found in the 'FreeSurfer Software License Agreement' contained
% in the file 'LICENSE' found in the FreeSurfer distribution, and here:
%
% https://surfer.nmr.mgh.harvard.edu/fswiki/FreeSurferSoftwareLicense
%
% Reporting: freesurfer@nmr.mgh.harvard.edu
%


xyzlab = [];
% if(nargin < 2 | nargin > 3)
%   fprintf('xyzlab = MRIseg2labelxyz(segmri,segid)\n');
%   return;
% end

if(~exist('vox2ras0','var')) vox2ras0 = 1; end
if(~exist('oneBase','var')) oneBase = 1; end

if ~oneBase
% Get list of voxels with seg id
% indlab = find(segmri.vol == segid);
% nlab = length(indlab);
nlab=size(points,1);
% Convert indices to row, col, slice
%[r c s] = ind2sub(segmri.volsize,indlab);
r=points(:,1);c=points(:,2);s=points(:,3);
crs = [c r s]' - 1 ; % 0-based
crs = [crs; ones(1,nlab)];

% Convert row, col, slice to XYZ
xyz1 = vox2ras0 * crs;
xyzlab = xyz1(1:3,:)';
end

if oneBase
    % Get list of voxels with seg id
% indlab = find(segmri.vol == segid);
% nlab = length(indlab);
nlab=size(points,1);
% Convert indices to row, col, slice
%[r c s] = ind2sub(segmri.volsize,indlab);
r=points(:,1);c=points(:,2);s=points(:,3);
crs = [c r s]'; % 0-based
crs = [crs; ones(1,nlab)];

% Convert row, col, slice to XYZ
xyz1 = vox2ras0 * crs;
xyzlab = xyz1(1:3,:)';
end

return;
