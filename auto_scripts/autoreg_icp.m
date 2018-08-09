function autoreg_icp(subject,Rtoler,Ltoler,pre_coords)
%ICP co-reg
% subject='TJ041'; % string of the subject name in the subject folder
% toler = .1; % the ratio (0,1) of worst points which are excluded 
% hemi = 'both';
% hemi = 'left'; hemi = 'right';
% pre_coords = 'spm' or 'fsl'
%%%%%%%%%%%
% autoreg_icp.m
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
% instantiate the default file names
fnames=acorel(subject,0);
if ~exist('pre_coords','var');pre_coords='fsl';end
%
disp(['Checking for Electrode coordinates that exist for ' subject ' ...']);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmpi(pre_coords,'spm')
    disp('using SPM coregistration')
    ct_trans=fnames.spm;
    [coords,names]=read_coords(fnames.gras);
elseif strcmpi(pre_coords,'fsl')
    disp('using FSL coregistration')
    ct_trans=fnames.xfm;
    [coords,names]=read_coords(fnames.ras_master);
else
    disp('wrong pre_coords; please specify either "spm" or "fsl"')
end
%setup coord info
just_letters={};
for n=1:numel(names)
just_letters{n}=names{n}(1:sum(isstrprop(names{n}, 'alpha')));
end
[fam_names,~,fam_indexes]=unique(just_letters);
%determine if bilateral and
%split up left and right hemisphere coords
rdexes=[];ldexes=[];
for f=1:numel(fam_names)
    if strcmpi(fam_names{f}(1),'R')
        rdexes=[rdexes f];
    elseif strcmpi(fam_names{f}(1),'L')
        ldexes=[ldexes f];
    else
        error('which hemi does trode belong to?')
    end
end
%% get E coordinates and apply transform
r_coords=coords(ismember(fam_indexes,rdexes),:);
l_coords=coords(ismember(fam_indexes,ldexes),:);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
disp(['Checking if transform exists for ' subject ' ...']);

if exist(fnames.lh_icp,'file')&exist(fnames.rh_icp,'file')
    if ~isempty(l_coords)
    ICP_left=lta_read(fnames.lh_icp);
    LTrodes_Moved=[ICP_left*[l_coords ones(length(l_coords'),1)]']';
    LTrodes_Moved=[LTrodes_Moved(:,1:3)];
    %     LPoints_Moved=[ICP_left*[ct_clean(ct_clean(:,1)<0,:) ones(length(ct_clean(ct_clean(:,1)<0,:)'),1)]']';
    %     LPoints_Moved=[LPoints_Moved(:,1:3)];
    end
    if ~isempty(r_coords)
    ICP_right=lta_read(fnames.rh_icp);
    RTrodes_Moved=[ICP_right*[r_coords ones(length(r_coords'),1)]']';
    RTrodes_Moved=[RTrodes_Moved(:,1:3)];
    %     LPoints_Moved=[ICP_left*[ct_clean(ct_clean(:,1)<0,:) ones(length(ct_clean(ct_clean(:,1)<0,:)'),1)]']';
    %     LPoints_Moved=[LPoints_Moved(:,1:3)];
    end
elseif ~exist('fnames.lh_icp','file')&~exist('fnames.rh_icp','file')
if ~exist('Rtoler','var');Rtoler=.1;end
if ~exist('Ltoler','var');Ltoler=.1;end
its=20; %iterations
min_k=7; %post-arts mri filter minimum number of points
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp(['Beginning ICP registration for ' subject ' ...']);
disp(['Use minimum tolerances:']);
disp(['Left = ' num2str(Ltoler) '   and   Right = ' num2str(Rtoler)]);
disp(['Iterations = ' num2str(its)])
disp(['Min. signal-voids filter = ' num2str(min_k)])
% get the post-mri artifacts
mri_neg=MRIread(fnames.post); %freesurfer program to read the volume file
mri_vox=mri_binarize(mri_neg,1); %use 1 because it is pre-binarized
mri_points=vox2labelxyz(mri_vox,mri_neg.tkrvox2ras); %convert from vox -> RAS
% clean up the noise points
mri_filt = cloud_filter(mri_points,min_k);
% get the ct artifacts
[ct_ras]=ct2surf(fnames.CT_nii,ct_trans);
% strip the noise EXTREMELY close to the inflated brain surface
max_dist=1; %distance in millimeters for noise threshold (use 1 for really good reg)
[ ct_clean, ct_diffs, ct_strip ] = strip_noise2( ct_ras, fnames.filled, max_dist );
% downsample the CT points if need be
%ct_clean=cloud_filter
%%%%%%%%%%%%%
%FIRST do the right hemi
RPoints_Moved=[];RTrodes_Moved=[];Rerr=00;
    disp('beginning right ICP')
[Rr,Tr,Rerr] = icp(mri_filt(mri_filt(:,1)>0,:)',ct_clean(ct_clean(:,1)>0,:)',its,'Minimize','plane','WorstRejection',Rtoler); %'Extrapolation',true
RPoints_Moved=Rr*ct_clean(ct_clean(:,1)>0,:)' + repmat(Tr,1,length(ct_clean(ct_clean(:,1)>0,:)'));
RPoints_Moved=RPoints_Moved';

%SECOND do the left hemi
LPoints_Moved=[];LTrodes_Moved=[];Lerr=00;
    disp('beginning left ICP')
[Rl,Tl,Lerr] = icp(mri_filt(mri_filt(:,1)<0,:)',ct_clean(ct_clean(:,1)<0,:)',its,'Minimize','plane','WorstRejection',Ltoler); %'Extrapolation',true
%Minimize 'plane'
%WorsRejection .01
LPoints_Moved=Rl*ct_clean(ct_clean(:,1)<0,:)' + repmat(Tl,1,length(ct_clean(ct_clean(:,1)<0,:)'));
LPoints_Moved=LPoints_Moved';


if ~isempty(r_coords)
    %trodes
    Trodes_Moved=Rr*r_coords' + repmat(Tr,1,length(r_coords'));
    RTrodes_Moved=Trodes_Moved';
end
if ~isempty(l_coords)
    %trodes
    Trodes_Moved=Rl*l_coords' + repmat(Tl,1,length(l_coords'));
    LTrodes_Moved=Trodes_Moved';
end
% SAVE THE ICP REGISTRATION INFO
disp('writing ICP registration file for both hemispheres')
% Convert the rotation and translation matrixes into a single linear
% transform
ICP_right=roto_trans(Rr,Tr);
ICP_left=roto_trans(Rl,Tl);
% For Left
write_xfm(fnames.lh_icp,ICP_left,'lh_ICP','lta')
% For Right
write_xfm(fnames.rh_icp,ICP_right,'rh_ICP','lta')
%
%[surf_coords]=surf_norm(Trodes_Moved',filled.vertices,13,names);
disp([subject ' ICP results being plotted..']);
disp('used minimum tolerances of:');
disp(['Left = ' num2str(Ltoler) '  and   Right = ' num2str(Rtoler)]);
disp(['Left Error = ' num2str(Lerr(end,1)) '  and   Right Error = ' num2str(Rerr(end,1))]);

%%%%% PLOTTING Right
figure; hold on;
plotE(ct_clean(ct_clean(:,1)>0,:),'y.',5);
plotE(mri_filt(mri_filt(:,1)>0,:),'b.',5);
if ~isempty(RPoints_Moved);
plotE(RPoints_Moved,'r.',5);
end
%%%%% PLOTTING Left
figure; hold on;
plotE(ct_clean(ct_clean(:,1)<0,:),'y.',5);
plotE(mri_filt(mri_filt(:,1)<0,:),'b.',5);
if ~isempty(LPoints_Moved);
plotE(LPoints_Moved,'r.',5);
end
disp('done plotting')
%%%% APPLY XFM
disp('done computing ICP registration, please check results and adjust minimum tolerances')
end %check if registration already exists
if ~(isempty(l_coords)&isempty(r_coords)) %to write coordinate file or not
%%% SAVE THE NEW COORDINATES FILE
disp('writing coordinates file')
save_coords=[RTrodes_Moved;LTrodes_Moved];
save_names={names{ismember(fam_indexes,rdexes)},names{ismember(fam_indexes,ldexes)}};
[ sorted_coords,sorted_names ] = order_trodes(save_coords,save_names);
                  fid = fopen(fnames.post_master,'w');
                  %have to do for loop cause fprintf doesnt support cells
                  for q=1:size(save_coords,1)
                  %fprintf(fid,'%5.5g %5.5g %5.5g %s\n',coords(q,:),names{q});
                    fprintf(fid,'%5.5g %5.5g %5.5g %s\n',sorted_coords(q,:),sorted_names{q});
                  end
                  fclose(fid); 
%%%%%%
end
end %function end
