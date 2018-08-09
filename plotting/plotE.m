function h=plotE(ePoints,varargin)
%plots electrodes as markers in 3D coords
%plotE(points,markertype,trode_size)
%plotE([Nx3],'r.',35)
%
%
% plotE.m
%
% Original Author: Walter Hinds
%    $Date: 01/01/2017 00:04:12 $
%
% Copyright Â© 2017 Drexel University
%
% Terms and conditions for use, reproduction, distribution and contribution
% are found in the 'ACOREL Software License Agreement' contained
% in the file 'LICENSE' found in the ACOREL distribution.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%
if isempty(ePoints);return;end
if isempty(varargin);trode_size=35;markertype='r.'; % no varargs in
 % 1 varargin
elseif length(varargin)==1&isstr(varargin{1}) %markertype
    markertype=varargin{1};trode_size=27;
elseif length(varargin)==1&~isstr(varargin{1})&numel(varargin{1})==1 %trode size
    markertype='r.';trode_size=varargin{1};
elseif length(varargin)==1&~isstr(varargin{1})&numel(varargin{1})==3 %color
    trode_size=27;markertype=varargin{1};   
 % 2 varargin
elseif length(varargin)==2&isstr(varargin{1});
    markertype=varargin{1};trode_size=varargin{2};
elseif length(varargin)==2&~isstr(varargin{1})&~isempty(varargin{1});
    markertype=varargin{2};trode_size=varargin{1};
 elseif length(varargin)==2&isempty(varargin{1})
     markertype='r.';trode_size=varargin{2};
 elseif length(varargin)==2&isempty(varargin{2})
     markertype=varargin{1};trode_size=27;
 elseif length(varargin)==2&~isstr(varargin{1})&numel(varargin{1})==3 %color
    trode_size=varargin{2};markertype=varargin{1};
end;
%pre-designated strings 'points' 'trodes'
if strcmp(markertype,'points');
    markertype='k.';trode_size=5;

elseif strcmp(markertype,'trodes');
    markertype='r.';trode_size=27;
    
elseif numel(markertype)>3
    error('incorrect "markertype"');
elseif isempty(markertype)
    markertype='r.';
end
%which plot3 depends on which args go where
if numel(markertype)==3 
    h=plot3(ePoints(:,1),ePoints(:,2),ePoints(:,3),'marker','.','color',markertype,'markersize',trode_size);
elseif numel(trode_size)==3 
    h=plot3(ePoints(:,1),ePoints(:,2),ePoints(:,3),'marker','.','markersize',markertype,'color',trode_size);
else
h=plot3(ePoints(:,1),ePoints(:,2),ePoints(:,3),markertype,'markersize',trode_size);
end
%
end%function end






%end script
