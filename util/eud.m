function d = eud(x,y)
%euclidian distance
%
%
% eud.m
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
d = sum(bsxfun(@minus,x,y).^2,2).^0.5;
end
