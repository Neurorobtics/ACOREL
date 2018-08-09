function [ ct_clean , ct_strip ] = restrip_noise2( ct_diffs, ct_ras, max_dist )
%strip_noise Uses surface files from a 3D brain reconstruction to mask a co-registered CT
%volume such that noise which is beyond the brain's surface is excluded
%INPUT:
%           can accept a string or an array of RAS coords
%
%OUTPUT: ct_clean - a noise free array of CT points in RAS
%
% restrip_noise2.m
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist('max_dist','var');max_dist=7;end %most extreme was 8.8, usually 6 or 7 works well
%%%%%%%%%%%%%%%%%%%%%%%%%
%if you wish to change max_dist without having to wait.
ct_clean=ct_ras(ct_diffs(:,1)<max_dist|ct_diffs(:,2)==1,:);
ct_strip=ct_ras(ct_diffs(:,1)>max_dist&ct_diffs(:,2)==0,:);
    
    
end %function end

