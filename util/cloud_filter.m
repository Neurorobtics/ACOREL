function mri_filt = cloud_filter(mri_points,min_k,epsi)
%
%
% cloud_filterl.m
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

%epsi = radius
if ~exist('epsi','var');epsi=1;end
[d_class,type]=dbscan(mri_points,1,epsi);
classes=(-1:max(d_class));
[counts,bin] = histc(d_class,classes);

mri_filt = mri_points(~ismember(d_class,[classes(counts<min_k) -1]),:);
end