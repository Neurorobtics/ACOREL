function save_coords(jacksheet,ras_master,xfm)
%RAS coords to Other...

%extact file path info from jacksheet
%
% save_coords.m
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
[dd,~,~]=fileparts(jacksheet);
subject=dd(end-9:end-5);
spath=dd(1:end-4);
%%% IF USER DOESN"T SUPPLY filepaths, guess at the defaults...
if ~exist('ras_master','var');ras_master=[spath 'RAS_master.txt'];end
if ~exist('xfm','var');xfm=[spath 'vol' filesep 'CT2MRI.lta'];end
[coords,names]=read_coords(ras_master);

    %convert back into CT voxel space
    M=[-1 0 0 128;0 0 1 -128;0 -1 0 128;0 0 0 1;];
    voxes=xyz2vox(coords,M,1);  %one base  
    L=lta_read(xfm);
    vox_coords=round(vox2vox(voxes,inv(L)));
    %save to VOX_master file
    vox_path=[spath 'VOX_master.txt'];
    fid = fopen(vox_path,'w');
    %have to do for loop cause fprintf doesnt support cells
    for q=1:size(vox_coords,1)
         fprintf(fid,'%5.5g %5.5g %5.5g %s\n',vox_coords(q,:),names{q});
    end
    fclose(fid);
    %%%%%%%%%%%%%%%
    %save to VOX_coords file based on 'jacksheet'
    %%%%%%%%%%%%%%%%
    [jack.chan, jack.name] = read_jack(jacksheet);
    %check to make sure there are enough points to fill out the jacksheet
    if size(vox_coords,1)>=size(jack.chan,1)
        vox_coords_path=[spath 'VOX_master_names.txt'];
        fid = fopen(vox_coords_path,'w');
        for j=1:size(jack.chan,1)
            ident=strcmp(jack.name(j),names);
            fprintf(fid,'%5.5g %5.5g %5.5g %s\n',vox_coords(ident,:),jack.name{j});
        end
        fclose(fid);
    end

    %vox_coords no chan
    
end %function end