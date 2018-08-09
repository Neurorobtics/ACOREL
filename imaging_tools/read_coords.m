function [coords, names, chans] = read_coords(fname)
%returns the Nx3 array of 'coords' and Nx1 cell of 'names'
% and Nx1 array of channels
%
%
% read_coords.m
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin==0|~exist('fname','var')|isempty(fname);
    [fthing,pstring,istring]= uigetfile('*.*') ;
 fname=[pstring fthing];
end
%
coords=[];names=[];chans=[];
%
fid=fopen(fname);
if fid==-1;disp('no such coords file');disp('returning empty matrices');return;end
% tline=fgets(fid);
% C=textscan(tline,'%n %n %n %s %n');

C=textscan(fid,'%n %n %n %s %n');
coords=[C{1} C{2} C{3}];
    if isempty(C{4})
        names=C{4};
    elseif ischar(C{4}{1})
        names=C{4};
    end
    if isempty(C{5})
        names=C{5};
    elseif ~isnan(C{5}(1))
        chans=C{5};
    elseif isnan(C{5}(1))
        %disp('no channels extracted')
    elseif numel(C)>5
        disp('greater than 5 columns (i.e. coords,names,chans)....check file')
    end
    fclose(fid);
end %function end