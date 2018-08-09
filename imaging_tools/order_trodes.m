function [ sorted_coords,sorted_names ] = order_trodes(electrode_file,varargin)
%organizes the electrodes based on label names, into family and digit
%
% (later add inputs coords and names if no file is available)
%
% order_trodes.m
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ischar(electrode_file)
[electrode_coords,names]=read_coords(electrode_file);
else
    electrode_coords=electrode_file;
    names=varargin{1};
end
%% find unique names and group together
just_letters={};
for n=1:numel(names)
just_letters{n}=names{n}(1:sum(isstrprop(names{n}, 'alpha')));
end
[fam_names,~,fam_indexes]=unique(just_letters);
sorted_coords=[];sorted_names={};
%% order by digit
for i=1:numel(fam_names)
    temp_names=names(fam_indexes==i);
    temp_coords=electrode_coords(fam_indexes==i,:);
[trode_sort,trode_nums]=sort_trodes(temp_coords,temp_names);

    for k=1:sum(fam_indexes==i)
        sorted_coords(end+1,:)=temp_coords(trode_nums==k,:);
        sorted_names(end+1)=temp_names(trode_nums==k);
    end
%keyboard;
end

end

