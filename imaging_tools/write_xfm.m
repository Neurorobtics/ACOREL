function write_xfm(fname,T,notes,xfm_format)
%
% writes the 4x4 linear transform to a text file which can be read by
% read_xfm or read_lta
%
% fname - the name of the file to write ( .xfm)
% T - 3 x 4 linear transform
% notes - a string of notes to add on last line after transform
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read_xfm works by scanning til the words Linear_Tranform are detected,
% then extracting the 4 x 4 matrix that subsequently follows
%
%
% write_xfm.m
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
if ~exist('notes','var');notes=[];end
if ~exist('xfm_format','var');xfm_format='none';end
if size(T,1)~=4 | size(T,2)~=4
    disp('ERROR')
    disp(['The size of the transform matrix is incorrect, must be 4x4'])
    disp(['size is ' num2str(size(T,1)) ' x ' num2str(size(T,2))])
    return
end
fid = fopen(fname,'w');
if strcmpi(xfm_format,'lta')
% 1. write 'Linear_Transform'
%first two lines ar the file name and date, third is blank
fprintf(fid,'%s\n',notes);
fprintf(fid,'%s\n%s\n%s\n%s\n%s\n%s\n','type      = 0','nxforms   = 1','mean      = 0.0000 0.0000 0.0000','sigma     = 10000.0000','1 4 4');


% 2. write the 4 x 4 matrix
%have to do for loop cause fprintf doesnt support cells
                  for q=1:size(T,1)
fprintf(fid,'%5.5g %5.5g %5.5g %5.5g\n',T(q,:));
                  end

% % 3. write the notes
% fprintf(fid,'%s\n',notes);
%3. write Source volume info
fprintf(fid,'%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n',...
    'src volume info',...
    'valid = 1  # volume info valid',...
'filename = ',...
'volume = ',...
'voxelsize = ',...
'xras   = ',...
'yras   = ',...
'zras   = ',...
'cras   = ');
%4. write DST volume info
fprintf(fid,'%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n',...
    'dst volume info',...
    'valid = 1  # volume info valid',...
'filename = ',...
'volume = ',...
'voxelsize = ',...
'xras   = ',...
'yras   = ',...
'zras   = ',...
'cras   = ');
%5. write other info
fprintf(fid,'%s\n%s',...
    'subject subject-unknown',...
    'fscale ');
%%%%%%%%%%%%%%%%%%%
elseif ~strcmpi(xfm_format,'lta')
% 2. write the 4 x 4 matrix
%have to do for loop cause fprintf doesnt support cells
                  for q=1:size(T,1)
fprintf(fid,'%5.5g %5.5g %5.5g %5.5g\n',T(q,:));
                  end
end
% always remember to close the file when done :)
fclose(fid); 
end %function end

%%%


                  
                  %fprintf(fid,'%5.5g %5.5g %5.5g %s\n',coords(q,:),names{q});


%%%%%%






%% script end notes end
