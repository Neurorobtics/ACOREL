function [chan, name] = read_jack(fname)
% [code name rgb] = read_jack(fname)
%
% Reads a jacksheet text file
%
% read_jack.m
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
%initialize
chan = [];name = '';

fp = fopen(fname,'r');
if(fp == -1) 
  fprintf('ERROR: could not open %s\n',fname);
  return;
end


nthitem = 1;
while(1)
  
  % scroll through any blank lines or comments %
  while(1)
    tline = fgetl(fp);
    if(~isempty(tline) & tline(1) ~= '#') break; end
  end
  if(tline(1) == -1) break; end
    
  c = sscanf(tline,'%d',1); %chan number
  n = sscanf(tline,'%*d %s',1); %acronym name
%   r = sscanf(tline,'%*d %*s %d',1);
%   g = sscanf(tline,'%*d %*s %*d %d',1);
%   b = sscanf(tline,'%*d %*s %*d %*d %d',1);
%   v = sscanf(tline,'%*d %*s %*d %*d %*d %d',1);

  chan(nthitem,1) = c;
  name = strvcat(name,n');
  %rgbv(nthitem,:) = [r g b v];

  nthitem = nthitem + 1;
end
name=cellstr(name);
fclose(fp);

return;







