function M=roto_trans(R,T)
%% writes the 3x3 rotation and 3x1 translation to a linear transform to a Matrix 4x4 which can be read by
% read_xfm or read_lta
%INPUT:
% R - the 3x3 rotation matrix
% T - 3 x 1 translation
% 
%OUTPUT
% M - the 4x4 linear transform
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read_xfm works by scanning til the words Linear_Tranform are detected,
% then extracting the 4 x 4 matrix that subsequently follows
%
%%%%%%%%%%%
% roto_trans.m
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

Tmat=[1 0 0 T(1);...
    0 1 0 T(2);...
    0 0 1 T(3);...
    0 0 0 1];
Rmat=[R(1,:) 0;...
    R(2,:) 0;...
    R(3,:) 0;...
    0 0 0 1];
M=Rmat*Tmat;





end % function end

%% NOTES
%The matrix $ T$ will be referred to as a homogeneous transformation matrix. 
%It is important to remember that $ T$ represents a rotation followed by a translation (not the other way around). 
%Each primitive can be transformed using the inverse of $ T$, resulting in a transformed solid model of the robot.
%The transformed robot is denoted by $ {\cal A}(x_t,y_t,\theta)$, and in this case there are three degrees of freedom. 
%The homogeneous transformation matrix is a convenient representation of the combined transformations; 
%therefore, it is frequently used in robotics, mechanics, computer graphics, and elsewhere. 
%It is called homogeneous because over $ {\mathbb{R}}^3$ it is just a linear transformation without any translation.
%The trick of increasing the dimension by one to absorb the translational part is common in projective geometry
% H. Pottman and J. Wallner. 
% Computational Line Geometry. 
% Springer-Verlag, Berlin, 2001

%