function [mri_points,mri_bin]=mri_binarize(mri,range)
%[mri_points,mri_bin]=mri_binarize(mri,range)
%Input:
%mri - an mri (structure from MRIread output)
%range - [min max] inclusive thresholds for binarization, use 'max' for
%*if range is one value, it is the matched value for binarization
%DEFAULT range =1;
%suprathreshold (as in CT artifact detection)
%Output:
%mri_points - an [Nx3] array of points within the range of binarized values
%mri_bin - a new struct with the binarized volume
%
% mri_binarize.m
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if~exist('range','var')
    range=[];
end
if isstruct(mri)&isfield(mri,'vol')
%extract volume from structure filed .vol, and make a copy for mri_bin
mri_vol=mri.vol;mri_bin=mri;
else
    mri_vol=mri;mri_bin=struct();
end
%check if supra threshold is desired, plus other range instances
multi_range=0; %assume normal range unless there are 3 or more elements
if isequal(range,'max')
    min_r=max(max(max(mri_vol)));
    max_r=max(max(max(mri_vol)));
elseif ~ischar(range(1))
    if numel(range)==2
        min_r=range(1);
        max_r=range(2);
    elseif numel(range)==1
        min_r=range;
        max_r=range;
    elseif isempty(range)
        min_r=1;
        max_r=inf;
    elseif numel(range)>2
        multi_range=1;
    end
elseif ischar(range(1))
        range=str2num(range);
    if numel(range)==2
        min_r=range(1);
        max_r=range(2);
    elseif numel(range)==1
        min_r=range;
        max_r=range;
    elseif isempty(range)
        min_r=1;
        max_r=inf;
    elseif numel(range)>2
        multi_range=1;
    end
else
    error('not a valid range');
end
if ~multi_range
[x1,y1,z1]=ind2sub([size(mri_vol,1),size(mri_vol,2),size(mri_vol,3)],find(mri_vol>=min_r&mri_vol<=max_r)); %use 4095 for hi res CT intensity
mri_points=[x1 y1 z1];
%binarize the volume
mri_vol(mri_vol<min_r&mri_vol>max_r)=0;
mri_vol(mri_vol>=min_r&mri_vol<=max_r)=1;
mri_bin.vol=mri_vol;
end
if multi_range
        mri_vol(mri_vol==range)=1;
        mri_bin.vol=mri_vol;
        [x1,y1,z1]=ind2sub([size(mri_vol,1),size(mri_vol,2),size(mri_vol,3)],find(mri_vol==1)); %use 4095 for hi res CT intensity
        mri_points=[x1 y1 z1];
end


end%function end