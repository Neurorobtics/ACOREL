function [ pathstring,listings ] = get_sub_dir(  )
%
% SUBJECTS DIRECTORY is manually entered into a text file in the ACOREL
% home folder
% automatically retrieves the subjects directory
%
% get_sub_dir.m
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
%find the home directory
    str=which('acorel.m');
    home_dir=str(1:end-8);

    fid=fopen([home_dir 'subjects_path.txt'],'r');
    
if fid~=-1
    pathstring=fread(fid,'*char');
    listings=dir(pathstring);
    pathstring=pathstring';
    fclose(fid);
    
else   
    str=which('acorel.m');
    home_dir=str(1:end-8);
    %no subjects path specified, so user is required to supply one
    pathstring=uigetdir('');
    if pathstring==0;
        error('must pick a subject directory')
    end
    listings=dir(pathstring);
    fid=fopen([home_dir 'subjects_path.txt'],'w');
    fprintf(fid,'%s',pathstring);
    fclose(fid);
end


%function to getui
end

