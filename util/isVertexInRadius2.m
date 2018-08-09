function result = isVertexInRadius2(vertex, origin, radius)

%
% isVertexInRadius2.m
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



result=eud(vertex,origin)<=radius;


        
     