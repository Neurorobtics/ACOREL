function [strip_names,depth_names,grid_names]=read_trodetypes(fname)
% retrieves the relevant electrode types by name
%
% see also: write_trodetypes.m
%
% read_trodetypes.m
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
strip_names={};depth_names={};grid_names={};
fid=fopen(fname);
if fid==-1;disp(fname);error('no such coords file or trodetype');end
C=textscan(fid,'%s %s');
names=C{1};
types=C{2};
for t=1:length(names)
  if strcmp(types{t},'strip')
      strip_names(end+1)=names(t);
  end
  if strcmp(types{t},'depth')
      depth_names(end+1)=names(t);
  end
  if strcmp(types{t},'grid')
      grid_names(end+1)=names(t);
  end
end    
    fclose(fid);
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INDEXS
%find unique names
% just_letters={};
% for n=1:numel(names)
% just_letters{n}=names{n}(1:sum(isstrprop(names{n}, 'alpha')));
% end
% [fam_names,~,fam_indexes]=unique(just_letters);
%    tempskipDepths=[];tempskipGrids=[];
% %parse out depths
% if iscell(skipDepths)|~isnumeric(skipDepths)
%     for d=1:numel(skipDepths)
%         tempskipDepths(end+1)=find(strcmp(fam_names,skipDepths{d}));
%     end
%     skipDepths=tempskipDepths;
% end
% %parse out grids
% if iscell(skipGrids)|~isnumeric(skipGrids)
%     for d=1:numel(skipGrids)
%         tempskipGrids(end+1)=find(strcmp(fam_names,skipGrids{d}));
%     end
%     skipGrids=tempskipGrids;
% end

end%function end