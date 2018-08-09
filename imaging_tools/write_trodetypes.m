function []=write_trodetypes(fname,strip_names,depth_names,grid_names)
% writes the relevant electrode types by name
%
% see also: read_trodetypes.m
%
% write_trodetypes.m
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
%%%%%%%%%%

                  fid = fopen(fname,'w');
                  %fprintf(fid,'%s %s %s\n','STRIPS','DEPTHS','GRIDS');
                  %have to do for loop cause fprintf doesnt support cells
                  for q=1:numel(strip_names)
        
                      fprintf(fid,'%s %s\n',strip_names{q},'strip');
                  end
                  for q=1:numel(depth_names)
        
                      fprintf(fid,'%s %s\n',depth_names{q},'depth');
                  end
                  for q=1:numel(grid_names)
        
                      fprintf(fid,'%s %s\n',grid_names{q},'grid');
                  end
                  fclose(fid);


end%function end