function postprocPOST(subject,varargin)
%
%[postproc]=postproc(subject,ct_points, eRAS, jacksheet)
%Post processing performed on automatic algoirthm
%INPUT:
%subject - the patient ID (string)
%ct_ras - The ct artifact points in the patients native RAS space
%ct_diffs - The difference between an artifact point and its closest surface points
%ct_strip - the stripped points
%OUTPUT:
%electrodes - [Nx3] vector of final electrode coordinates
%postproc -structure with fields
% 'surf' - surface electrode points
% 'depth' - depth electrode points
% 'noise' - (false-positives) incorrect electrode points
% 'missing' - (false-negatives) electrode centroids missed by the algorithm
%varagin{3}=jacksheet;
%
% postprocPOST.m
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
%Get path info
[ pathstring,~ ] = get_sub_dir(  );
spath=[pathstring filesep subject filesep];
%%%%%%%
% GUI %
%%%%%%%
%Initialize figure and gui data structure (trodes)
h=figure;set(h,'Position',[100 100 500 550],'Tag','GUI');
%Make figure
g=figure;hold on;set(g,'Position',[800 100 600 600],'Tag','GRAPH');
if numel(varargin)==0 
    %load the saved variables
    load([spath 'postproc.mat'])
    trodes.fnames=acorel(subject,0);
        figure(findobj('Tag','GRAPH'))
        %Plot the CT artifacts
        trodes.arts=plotE(trodes.ct_points,'k.',4); %plot the CT points
        try
        trodes.stripd=plotE(trodes.ct_strip,'y.',4); %plot the CT stripped points
        set(trodes.stripd,'Visible','off'); %default has the stripped points hidden
        catch
            disp('no stripped arts')
        end
        
        %Plot the electrode centroid markers
        o=1;t=size(trodes.postproc,1);
        while o<=t
           %%%see if there are any duplicate coords
           duplicates=find(sum(reshape(ismember([trodes.postproc{:,1}],[trodes.postproc{o,1}]),[size(trodes.postproc,2) size(trodes.postproc,1)]))==3);
             if   numel(duplicates)>1
                 %combine the strings
                 trodes.postproc{o,3}=[trodes.postproc{o,3} trodes.postproc{duplicates(2:end),3}];
                 trodes.postproc=trodes.postproc(~ismember([1:size(trodes.postproc)],[duplicates(2:end)]),:);
             end
           %%%%%%
            if strcmp(trodes.postproc{o,3},'noise');o=o+1;continue;end
            markertype='g.';
            if ~isempty(trodes.postproc{o,3});markertype='y.';end        
            trodes.postproc{o,2}=plotE(trodes.postproc{o,1},markertype,35);
            o=o+1;
            t=size(trodes.postproc,1);
        end
else
    disp('no saved postproc.mat; creating new GUI and performing initial auto-localization')
    try
        trodes=guidata(findobj('Tag','GUI'));
        trodes.fnames=acorel(subject,0);
        trodes.ct_ras=varargin{1};
        trodes.ct_diffs=varargin{2};
        trodes.ct_strip=varargin{3};
        trodes.max_dist=7;
        [ trodes.ct_points , trodes.ct_strip ] = restrip_noise2( trodes.ct_diffs, trodes.ct_ras, trodes.max_dist );
        %calculate the initial eRAS
        [trodes.epoints,~]=autolocPOST(trodes.ct_points);
        trodes.brush='2';trodes.cloud=[];trodes.noise=[];
        trodes.radius=3; %electrode radius in mm
        trodes.reply=[];trodes.dist=[];trodes.prox=[];
        %initialize graph
        figure(findobj('Tag','GRAPH'))
        trodes.arts=plotE(trodes.ct_points,'k.',4); %plot the CT points
        trodes.stripd=plotE(trodes.ct_strip,'y.',4); %plot the CT stripped points
        set(trodes.stripd,'Visible','off');
        %initialize postproc structure
        for e=1:size(trodes.epoints,1)
        postproc{e,1}=[trodes.epoints(e,:)];
        postproc{e,2}=plotE(trodes.epoints(e,:),'g.',35);
        postproc{e,3}={};
        end
        trodes.postproc=postproc;
    catch
        disp('ERROR: PLEASE SUPPLY CORRECT INPUT ARGS -> ( subject, ct_ras, ct_diffs,ct_disp ) ')
%         trodes.ct_ras=ct_ras;
%         trodes.ct_diffs=ct_diffs;
%         trodes.ct_disp=ct_disp;
    end
end
%if ~exist('eRAS','var');disp('error...');return;end
%%%%%%%%%
% GRAPH %
%%%%%%%%%
%MAKE the brain figure
%this option slows down the 3D image
trodes.Lbrain=[];trodes.Rbrain=[];
try
[Lbrain,Rbrain]=PlotBrainSurf(subject,1);
trodes.Lbrain=Lbrain;trodes.Rbrain=Rbrain;
set(Lbrain,'Visible','off');set(Rbrain,'Visible','off');
end
%%%%%%%%%%%%%%%%%% data initialized
guidata(findobj('Tag','GUI'),trodes); %updates the GUI data variable 'trodes'
clear 'trodes'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%MESSAGE TEXT
uicontrol(findobj('Tag','GUI'),'Style','text',...
        'Position',[12 290 105 20],...
        'String','Message Display: ','FontWeight','bold')
%MESSAGE EDIT box
uicontrol(findobj('Tag','GUI'),'Style','edit',...
        'String',[],'FontWeight','bold',...
        'Position',[12 220 476 70],...
        'Tag',['editMessage'],...
        'Callback',{},...
        'Visible','on')
 %DISPLAYS MESSAGES on GUI
function dispMsg(msgStr)
set(findobj(findobj('Tag','GUI'),'Tag','editMessage'),'String',msgStr); %update a field on the gui
end %noise button function   
    
%INDEX TEXT
uicontrol(findobj('Tag','GUI'),'Style','text',...
        'Position',[12 505 80 20],...
        'String','Index #','FontWeight','bold')
%INDEX EDIT box
uicontrol(findobj('Tag','GUI'),'Style','edit',...
        'String',[],'FontWeight','bold',...
        'Position',[12 485 80 20],...
        'Tag',['editIndex'],...
        'Callback',{},...
        'Visible','on')
%NEYBS TEXT
uicontrol(findobj('Tag','GUI'),'Style','text',...
        'Position',[12 463 80 20],...
        'String','Neighbors','FontWeight','bold')
%NEYBS EDIT box
uicontrol(findobj('Tag','GUI'),'Style','edit',...
        'String',[],'FontWeight','bold',...
        'Position',[12 443 80 20],...
        'Tag',['editNeybs'],...
        'Callback',{},...
        'Visible','on')
%COORDS TEXT
uicontrol(findobj('Tag','GUI'),'Style','text',...
        'Position',[175 505 100 20],...
        'String','Coords (mm)','FontWeight','bold')
%COORDS EDIT box
uicontrol(findobj('Tag','GUI'),'Style','edit',...
        'String',[],'FontWeight','bold','FontSize',10,...
        'Position',[100 475 220 30],...
        'Tag',['editCoords'],...
        'Callback',{},...
        'Visible','on')
%NAME edit box
uicontrol(findobj('Tag','GUI'),'Style','edit',...
        'String',[],'FontWeight','bold','FontSize',12,...
        'Position',[330 470 150 30],...
        'Tag',['editName'],...
        'Callback',{},...
        'Visible','on','BackgroundColor',[.5 .5 0])
    
%NAME TEXT
uicontrol(findobj('Tag','GUI'),'Style','text',...
        'String','__  LABEL  __','FontWeight','bold',...
        'Position',[330 505 150 20])
    
%BRUSH TEXT
uicontrol(findobj('Tag','GUI'),'Style','text',...
        'Position',[330 420 160 20],...
        'String','Brush Radius (pixels)')
%BRUSH EDIT box
uicontrol(findobj('Tag','GUI'),'Style','edit',...
        'String','3',...
        'Position',[330 400 160 20],...
        'Tag',['editBrush'],...
        'Callback',{@editBrush_Callback},...
        'Visible','on')
% --- Executes on edit in editBrush.
function [trodes]=editBrush_Callback(hObj, eventdata)
val = get(hObj,'String');
trodes=guidata(findobj('Tag','GUI'));
trodes.brush=(val);
dispMsg(['brush size = ' trodes.brush]);
guidata(findobj('Tag','GUI'),trodes)
end %noise checkbox function
% --- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%NOISE CHECKBOX
uicontrol(findobj('Tag','GUI'),'Style','checkbox',...
        'String',['Noise '],...
        'Position',[12 380 100 20],...
        'Value',0,...
        'Tag',['checkboxNoise'],...
        'Callback',{@checkboxNoise_Callback},...
        'Visible','on')
% --- Executes on button press in checkboxNoise.
function [trodes]=checkboxNoise_Callback(hObj, eventdata)
val = get(hObj,'Value');
trodes=guidata(findobj('Tag','GUI'));
if val
 %enable clicking and keyboard function for the graph
 set(findobj('Tag','GRAPH'), 'WindowButtonDownFcn', {@callbackPickA3DPoint});
    [~, msgid] = lastwarn;
    if strcmp(msgid,'MATLAB:modes:mode:InvalidPropertySet')
        set(hObj,'Value',0);
        dispMsg('Please UN-CHECK any Buttons on the GRAPH before selecting a function');
        lastwarn('');
        return
    end
 trodes.cloud=cell2mat(trodes.postproc(:,1))';
 trodes.brush='1';
 set(findobj('Tag','editBrush'),'String',trodes.brush);
 %uncheck the other buttons
 set(findobj('Tag','checkboxLabel'),'Value',0);set(findobj('Tag','checkboxNew'),'Value',0);%set(findobj('Tag','checkboxDepth'),'Value',0);
 %highlight the checbox and un-highlight the others
 set(findobj('Tag','checkboxLabel'),'BackgroundColor',[0.9412    0.9412    0.9412]);
 set(findobj('Tag','checkboxNew'),'BackgroundColor',[0.9412    0.9412    0.9412]);
 set(findobj('Tag','checkboxNoise'),'BackgroundColor',[1    0    0]);
  set(findobj('Tag','GRAPH'), 'WindowKeyPressFcn', {@noiseLabel});
 dispMsg('CHECKed NOISE');
else
    dispMsg('un-checked NOISE');
    set(findobj('Tag','checkboxNoise'),'BackgroundColor',[0.9412    0.9412    0.9412]);
end
guidata(findobj('Tag','GUI'),trodes)
end %noise checkbox function
function [trodes]=noiseLabel(hObj, eventData)
    switch eventData.Key
        case 'return'
           %[trodes]=pushbuttonLabel_Callback(hObj, eventData);
        case 'space'
            
        case 'backspace'
            [trodes]=pushbuttonNoise_Callback(hObj, eventData);
        case 'delete'
            [trodes]=pushbuttonNoise_Callback(hObj, eventData);
    end
            
end % noiseLabel function
% 
%NOISE BUTTON
uicontrol(findobj('Tag','GUI'),'Style','pushbutton',...
        'String',['REMOVE'],'FontWeight','bold',...
        'Position',[175 380 100 20],...
        'Tag',['pushbuttonNoise'],...
        'Callback',{@pushbuttonNoise_Callback},...
        'Visible','on','ForegroundColor',[1 0 0])
% --- Executes on button press in pushbuttonNoise.
function [trodes]=pushbuttonNoise_Callback(hObj, eventdata)
 trodes=guidata(findobj('Tag','GUI'));
 trodes.postproc{trodes.vert,3}='noise';
  figure(findobj('Tag','GRAPH'));
  delete(trodes.postproc{trodes.vert,2});
    dispMsg('REMOVED NOISE');
    guidata(findobj('Tag','GUI'),trodes)
end %noise button function
%
%NEW CHECKBOX
uicontrol(findobj('Tag','GUI'),'Style','checkbox',...
        'String',['New '],...
        'Position',[12 415 100 20],...
        'Value',0,...
        'Tag',['checkboxNew'],...
        'Callback',{@checkboxNew_Callback},...
        'Visible','on')
% --- Executes on button press in checkboxNew.
function [trodes]=checkboxNew_Callback(hObj, eventdata)
val = get(hObj,'Value');
if val
    %enable clicking and keyboard function for the graph
    set(findobj('Tag','GRAPH'), 'WindowButtonDownFcn', {@callbackPickA3DPoint_new});
    [~, msgid] = lastwarn;
    if strcmp(msgid,'MATLAB:modes:mode:InvalidPropertySet')
        set(hObj,'Value',0);
        dispMsg('Please UN-CHECK any Buttons on the GRAPH before selecting a function'); 
        lastwarn('');
        return
    end
    trodes=guidata(findobj('Tag','GUI'));
 trodes.cloud=trodes.ct_ras';
 trodes.brush=get(findobj('Tag','editBrush'),'String');
 %uncheck the other buttons
 set(findobj('Tag','checkboxLabel'),'Value',0);set(findobj('Tag','checkboxDepth'),'Value',0);set(findobj('Tag','checkboxNoise'),'Value',0);
  %highlight the checbox and un-highlight the others
 set(findobj('Tag','checkboxLabel'),'BackgroundColor',[0.9412    0.9412    0.9412]);
 set(findobj('Tag','checkboxNoise'),'BackgroundColor',[0.9412    0.9412    0.9412]);
 set(findobj('Tag','checkboxNew'),'BackgroundColor',[0    1    0]);
 
 set(findobj('Tag','GRAPH'), 'WindowKeyPressFcn', {@newLabel});
 guidata(findobj('Tag','GUI'),trodes)
 dispMsg('CHECKed NEW');
else
    dispMsg('un-checked NEW');
    set(findobj('Tag','checkboxNew'),'BackgroundColor',[0.9412    0.9412    0.9412]);
end
end %new checkbox function
function [trodes]=newLabel(hObj, eventData)
    switch eventData.Key
        case 'return'
           [trodes]=pushbuttonNew_Callback(hObj, eventData);
        case 'space'
            
        case 'backspace'
           % [trodes]=pushbuttonUNDO_Callback(hObj, eventData);
        case 'delete'
            %[trodes]=pushbuttonUNDO_Callback(hObj, eventData);
    end
            
end % newLabel function
%NEW BUTTON
uicontrol(findobj('Tag','GUI'),'Style','pushbutton',...
        'String',['NEW '],'FontWeight','bold',...
        'Position',[175 415 100 20],...
        'Tag',['pushbuttonNew'],...
        'Callback',{@pushbuttonNew_Callback},...
        'Visible','on','ForegroundColor',[0 1 .1])
% --- Executes on button press in pushbuttonNoise.
function [trodes]=pushbuttonNew_Callback(hObj, eventdata)
 trodes=guidata(findobj('Tag','GUI'));
 figure(findobj('Tag','GRAPH'));
 %dispMsg()
 %creat a new point in the postproc structure
 trodes.postproc{end+1,1}=trodes.middle;
 trodes.postproc{end,2}=plotE(trodes.middle,'g.',27);
 trodes.postproc{end,3}={};
 trodes.epoints(end+1,:)=trodes.middle;
 %trodes.noise=[trodes.vert, trodes.noise];
 %postproc(trodes.vert).chan=[];
  figure(findobj('Tag','GRAPH'));
  delete(findobj(gca,'Tag','pt')); % try to find the old point
  delete(findobj(gca,'Tag','pts')); % try to find the old point
    dispMsg('ADDED POINT to postproc cell');
    guidata(findobj('Tag','GUI'),trodes)
    
end %noise button function
% --- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%LABEL CHECKBOX
uicontrol(findobj('Tag','GUI'),'Style','checkbox',...
        'String',['Label '],...
        'Position',[12 345 100 20],...
        'Value',0,...
        'Tag',['checkboxLabel'],...
        'Callback',@checkboxLabel_Callback,...
        'Visible','on')
    % --- Executes on button press in checkboxNew.
function [trodes]=checkboxLabel_Callback(hObj, eventdata)
val = get(hObj,'Value');
if val
    %enable clicking and keyboard function for the graph
    set(findobj('Tag','GRAPH'), 'WindowButtonDownFcn', {@callbackPickA3DPoint});
    [~, msgid] = lastwarn;
    if strcmp(msgid,'MATLAB:modes:mode:InvalidPropertySet')
        set(hObj,'Value',0);
        dispMsg('Please UN-CHECK any Buttons on the GRAPH before selecting a function'); 
        lastwarn('');
        return
    end
 trodes=guidata(findobj('Tag','GUI'));  
 trodes.cloud=cell2mat(trodes.postproc(~strcmp(trodes.postproc(:,3),'noise'),1))';
 trodes.brush='1';
 set(findobj('Tag','editBrush'),'String',trodes.brush);
 %uncheck the other buttons
 set(findobj('Tag','checkboxDepth'),'Value',0);set(findobj('Tag','checkboxNew'),'Value',0);set(findobj('Tag','checkboxNoise'),'Value',0);
 %highlight the checbox and un-highlight the others
 set(findobj('Tag','checkboxNoise'),'BackgroundColor',[0.9412    0.9412    0.9412]);
 set(findobj('Tag','checkboxNew'),'BackgroundColor',[0.9412    0.9412    0.9412]);
 set(findobj('Tag','checkboxLabel'),'BackgroundColor',[.5    .5    0]);
 set(findobj('Tag','GRAPH'), 'WindowKeyPressFcn', {@multiLabel});
 guidata(findobj('Tag','GUI'),trodes)
 dispMsg('CHECKed LABEL');
else
    dispMsg('un-checked LABEL');
    set(findobj('Tag','checkboxLabel'),'BackgroundColor',[0.9412    0.9412    0.9412]);
end
end %noise checkbox function
%LABEL BUTTON
uicontrol(findobj('Tag','GUI'),'Style','pushbutton',...
        'String',['LABEL '],'FontWeight','bold',...
        'Position',[175 345 100 20],...
        'Tag',['pushbuttonLabel'],...
        'Callback',{@pushbuttonLabel_Callback},...
        'Visible','on','ForegroundColor',[.5 .5 0])
% --- Executes on button press in pushbuttonNoise.
function [trodes]=pushbuttonLabel_Callback(hObj, eventdata)
    trodes=guidata(findobj('Tag','GUI'));
    %extract the user supplied identifier from the box
    trodes.ident=get(findobj('Tag','editLabel'),'String');
%     ident1=str2num(trodes.ident(end));
%     ident2=str2num(trodes.ident(end-1));
%     if isempty(ident1)
%         ident=1;
%         trodes.abr=[trodes.ident];
%         trodes.name=[trodes.abr num2str(ident)];
%     else
%         if isempty(ident2)
%             ident=ident1;
%             trodes.abr=trodes.ident(1:end-1);
%             trodes.name=[trodes.abr num2str(ident)];
%         else
%             ident=(ident2*10)+ident1;
%             trodes.abr=trodes.ident(1:end-2);
%             trodes.name=[trodes.abr num2str(ident)];
%         end
%         
%     end
    %
    dig=0;num_ident=1;
    while ~isempty(str2num(trodes.ident(end-dig)))
        if dig==0;num_ident=0;end
        num_ident = str2num(trodes.ident(end-dig))*(10^(dig)) + num_ident;
        dig=dig+1;
    end
    trodes.abr=trodes.ident(1:end-dig);
    trodes.name=[trodes.abr num2str(num_ident)];
    
    trodes.postproc{trodes.vert,3}=trodes.name;
    figure(findobj('Tag','GRAPH')); try delete(trodes.postproc{trodes.vert,2});end
    trodes.postproc{trodes.vert,2}=plotE(trodes.centr,'y.',30);
    dispMsg(['LABELED ' trodes.name]);
    guidata(findobj('Tag','GUI'),trodes)
    %first find out if auto-label is checked
%     isauto=get(findobj('Tag','checkboxAuto'),'Value');
%     if isauto
%         [strip_verts,trodes.postproc]=find_labels(trodes.centr,trodes.ident,trodes.postproc,jack);
%         %then label them on the graph
%         for s=1:numel(strip_verts)
%             trodes.chan=trodes.postproc{strip_verts(s),2};
%             trodes.centr=trodes.postproc{strip_verts(s),1};
%             figure(findobj('Tag','GRAPH'));plotE(trodes.centr,'y.',30);Etext(trodes.centr,trodes.chan,'black');
%         end
%         dispMsg(['AUTO-LABELED ' num2str(numel(strip_verts)) ' points']);
%         guidata(findobj('Tag','GUI'),trodes)
%     end%isauto
    %first find out if multi-label is checked
    ismulti=get(findobj('Tag','checkboxMulti'),'Value');
    if ismulti
        set(findobj('Tag','editLabel'),'String',[trodes.abr num2str(num_ident+1)]); 
    end%ismulti
end %label button function
%LABEL EDIT box
uicontrol(findobj('Tag','GUI'),'Style','edit',...
        'String',['ex: RST1 or RST'],...
        'Position',[330 345 160 20],...
        'Tag',['editLabel'],...
        'Callback',@editLabel_Callback,...
        'Visible','on')
function editLabel_Callback(hObj, eventdata)
val = get(hObj,'String');
dispMsg(val)
end %edit label function
%AUTO-label CHECKBOX
uicontrol(findobj('Tag','GUI'),'Style','checkbox',...
        'String',['Auto-Label '],...
        'Position',[175 310 100 20],...
        'Value',0,...
        'Tag',['checkboxAuto'],...
        'Callback',@checkboxAuto_Callback,...
        'Visible','on')
function checkboxAuto_Callback(hObj, eventdata)
val = get(hObj,'Value');
if val
    dispMsg('checked Auto-Label')
else
    dispMsg('un-checked Auto-Label');
end
end %auto checkbox function
%MULTI-label CHECKBOX
uicontrol(findobj('Tag','GUI'),'Style','checkbox',...
        'String',['Multi-Label '],...
        'Position',[330 310 100 20],...
        'Value',0,...
        'Tag',['checkboxMulti'],...
        'Callback',@checkboxMulti_Callback,...
        'Visible','on')
function checkboxMulti_Callback(hObj, eventData)
val = get(hObj,'Value');
if val
    dispMsg('checked Multi-Label')
    set(findobj('Tag','GRAPH'), 'WindowKeyPressFcn', {@multiLabel});
else
    dispMsg('un-checked Multi-Label');
end
end %multi checkbox function
function [trodes]=multiLabel(hObj, eventData)
    switch eventData.Key
        case 'return'
           [trodes]=pushbuttonLabel_Callback(hObj, eventData);
        case 'space'
            
        case 'backspace'
            [trodes]=pushbuttonUNDO_Callback(hObj, eventData);
        case 'delete'
            [trodes]=pushbuttonUNDO_Callback(hObj, eventData);
        otherwise
            %
    end
            
end % multiLabel function
%UNDO BUTTON
uicontrol(findobj('Tag','GUI'),'Style','pushbutton',...
        'String',['UNDO '],...
        'Position',[440 310 50 20],...
        'Tag',['pushbuttonUNDO'],...
        'Callback',{@pushbuttonUNDO_Callback},...
        'Visible','on','ForegroundColor',[0 .5 .5])
% --- Executes on button press in pushbuttonUNDO.
function [trodes]=pushbuttonUNDO_Callback(hObj, eventdata)
    trodes=guidata(findobj('Tag','GUI'));
    try
    delete(trodes.postproc{trodes.vert,2}); %get rid of yellow
    catch
        dispMsg('No label to UNDO')
    end
    dispMsg([trodes.postproc{trodes.vert,3} ' removed'])
    set(findobj(findobj('Tag','GUI'),'Tag','editName'),'String',''); %update a field on the gui
    trodes.postproc(trodes.vert,3)={{}}; %clear label
    trodes.postproc{trodes.vert,2}=plotE(trodes.postproc{trodes.vert,1},'g.',27); %plot green
    guidata(findobj('Tag','GUI'),trodes)
    
end %undo button function

%Store BUTTON
uicontrol(findobj('Tag','GUI'),'Style','pushbutton',...
        'String',['CONVERT'],...
        'Position',[10 10 100 40],...
        'Tag',['pushbuttonStore'],...
        'Callback',{@pushbuttonStore_Callback},...
        'Visible','off')
% --- Executes on button press in pushbuttonSave.
function [trodes]=pushbuttonStore_Callback(hObj, eventdata)
    trodes=guidata(findobj('Tag','GUI'));
    assignin('base','postproc',trodes.postproc);
    dispMsg('Storing the coordinates based on jacksheet...');
    %write coordinates on the jacksheet
    %save all the coordinates based on the jacksheet
    save_coords(jacksheet);
    %guidata(findobj('Tag','GUI'),trodes)
end %store button function
%Save EDIT
uicontrol(findobj('Tag','GUI'),'Style','edit',...
        'String',[spath],...
        'Position',[10 60 220 40],...
        'Tag',['editSave'],...
        'Callback',@editSave_Callback,...
        'Visible','on')
% --- Executes on button press in editSave.
function editSave_Callback(hObj, eventdata)
  dispMsg('Will save coords to path:');
  dispMsg(get(hObj,'String'));
end %editSave edit function
%Save BUTTON
uicontrol(findobj('Tag','GUI'),'Style','pushbutton',...
        'String',['SAVE-FILE'],...
        'Position',[130 10 100 40],...
        'Tag',['pushbuttonSave'],...
        'Callback',@pushbuttonSave_Callback,...
        'Visible','on')
% --- Executes on button press in pushbuttonSave.
function [trodes]=pushbuttonSave_Callback(hObj, eventdata)
    trodes=guidata(findobj('Tag','GUI'));
    lead_path=get(findobj('Tag','editSave'),'String');
    assignin('base','postproc',trodes.postproc);
    dispMsg('Saved the Electrodes and Labels');
    %prepare variables to store
    labeled_trodes=~cellfun('isempty',[trodes.postproc(:,3)]);
    coords=[];names=[];
    for q=1:size(trodes.postproc,1)
        if ~labeled_trodes(q)|strcmp(trodes.postproc{q,3},'noise');continue;end; %skip the noise points
        coords(end+1,:)=trodes.postproc{q,1};
        names{end+1}=trodes.postproc{q,3};
    end %
    %save the postproc variable for later use
    save([lead_path 'postproc.mat'],'trodes'); %,'eRAS','ct_points','jacksheet'
    %%%%% Create the RAS Master file %%%%%%%%%%%%%%%
    % and VOX master
    T=lta_read(trodes.fnames.xfm);
    vox_coords=xyz2vox(coords);
    ct_vox_coords=round(vox2vox(vox_coords,inv(T)));
                    names=names';
                  name_path=[lead_path 'RAS_master.txt'];
                  fid = fopen(name_path,'w');
                  name_path2=[lead_path 'VOX_master.txt'];
                  fid2 = fopen(name_path2,'w');
                  %have to do for loop cause fprintf doesnt support cells
                  for q=1:size(coords,1)
                  fprintf(fid,'%5.5g %5.5g %5.5g %s\n',coords(q,:),char(names{q}));
                  fprintf(fid2,'%5.5g %5.5g %5.5g %s\n',ct_vox_coords(q,:),char(names{q}));
                  end
                  fclose(fid);fclose(fid2);
        % Look for Jacksheet and if it exists, store the coordinates and name associations
        if exist(trodes.fnames.jacksheet,'file');
            save_coords(trodes.fnames.jacksheet);
        end
end %saveFile button function
%POINTS CHECKBOX
uicontrol(findobj('Tag','GUI'),'Style','checkbox',...
        'String',['E-POINTS '],...
        'Position',[10 190 100 20],...
        'Value',1,...
        'Tag',['checkboxPoints'],...
        'Callback',@checkboxPoints_Callback,...
        'Visible','on')
function [trodes]=checkboxPoints_Callback(hObj, eventdata)
val = get(hObj,'Value');
trodes=guidata(findobj('Tag','GUI'));
    if val
        %plot the ePoints
        for e=1:size(trodes.postproc,1)
            if strcmp(trodes.postproc{e,3},'noise');continue;end;
            try
                set(trodes.postproc{e,2},'Visible','on');
            catch
            end
        end
    else
        %make ePoints invisible
        for e=1:size(trodes.postproc,1)
            if strcmp(trodes.postproc{e,3},'noise');continue;end;
            try
                set(trodes.postproc{e,2},'Visible','off');
            catch
            end
        end
    end
end
%ARTIFACTS CHECKBOX
uicontrol(findobj('Tag','GUI'),'Style','checkbox',...
        'String',['ARTIFACTS '],...
        'Position',[130 190 100 20],...
        'Value',1,...
        'Tag',['checkboxArts'],...
        'Callback',@checkboxArts_Callback,...
        'Visible','on')
function checkboxArts_Callback(hObj, eventdata)
val = get(hObj,'Value');
trodes=guidata(findobj('Tag','GUI'));
    if val
        %plot the artifacts
        set(trodes.arts,'Visible','on');
    else
        %make artifacts invisible
        set(trodes.arts,'Visible','off');
    end
end
%STRIPPED ARTIFACTS CHECKBOX
uicontrol(findobj('Tag','GUI'),'Style','checkbox',...
        'String',['STRIPPED '],...
        'Position',[130 170 100 20],...
        'Value',0,...
        'Tag',['checkboxStrip'],...
        'Callback',@checkboxStrip_Callback,...
        'Visible','on')
function checkboxStrip_Callback(hObj, eventdata)
val = get(hObj,'Value');
trodes=guidata(findobj('Tag','GUI'));
try
    if val
        %plot the stripped artifacts
        set(trodes.stripd,'Visible','on');
    else
        %make stripped artifacts invisible
        set(trodes.stripd,'Visible','off');
    end
end
end
%BRAIN CHECKBOX
uicontrol(findobj('Tag','GUI'),'Style','checkbox',...
        'String',['BRAIN '],...
        'Position',[250 190 100 20],...
        'Value',0,...
        'Tag',['checkboxBrain'],...
        'Callback',@checkboxBrain_Callback,...
        'Visible','on')
function checkboxBrain_Callback(hObj, eventdata)
val = get(hObj,'Value');
trodes=guidata(findobj('Tag','GUI'));
    if val
        %plot the ePoints
        set(trodes.Lbrain,'Visible','on');set(trodes.Rbrain,'Visible','on');
    else
        %make ePoints invisible
        set(trodes.Lbrain,'Visible','off');set(trodes.Rbrain,'Visible','off');
    end
end
%BRAIN SLIDER
uicontrol(findobj('Tag','GUI'),'Style','slider',...
        'Min',0.1,'Max',1,'Value',.8,...
        'Position',[360 190 100 20],...
        'Tag',['sliderBrain'],...
        'Callback',@sliderBrain_Callback,...
        'Visible','on')
function sliderBrain_Callback(hObj, eventdata)
val = get(hObj,'Value');
figure(findobj('Tag','GRAPH'))
alpha(val);
end %brain slider
%%%%%%%%%%%%%%%%%
%Auto-Detect BUTTON
uicontrol(findobj('Tag','GUI'),'Style','pushbutton',...
        'String',['AUTO-DETECT'],...
        'Position',[300 10 100 40],...
        'Tag',['pushbuttonAutoDet'],...
        'Callback',@pushbuttonAutoDet_Callback,...
        'Visible','on')
% --- Executes on button press in pushbuttonSave.
function [trodes]=pushbuttonAutoDet_Callback(hObj, eventdata)
    dispMsg('BUSY: Auto-detecting... (may take up to a minute)...'); pause(3);
    trodes=guidata(findobj('Tag','GUI'));
%     trodes.reply=input('Warning: You will lose all labeled points. Are you sure? y/n: ');
%     if strfind(['y Y'],trodes.reply)
        trodes.radius=str2num(get(findobj('Tag','editTrode'),'String'));
        trodes.minpts=str2num(get(findobj('Tag','editMinPts'),'String'));
        %make ePoints invisible
        for e=1:size(trodes.postproc,1)
            try
                set(trodes.postproc{e,2},'Visible','off');
            catch
            end
        end
        [trodes.epoints,~]=autolocPOST(trodes.ct_points,trodes.radius,[],trodes.minpts);
        %initialize postproc structure & plot the new points
        figure(findobj('Tag','GRAPH'))
        postproc={};
        for e=1:size(trodes.epoints,1)
        postproc{e,1}=[trodes.epoints(e,:)];
        postproc{e,2}=plotE(trodes.epoints(e,:),'g.',35);
        postproc{e,3}={};
        end
        trodes.postproc=postproc;
        %%%%%%%%
        dispMsg('Auto-detected new E-points');

        guidata(findobj('Tag','GUI'),trodes);
    %end
end %Auto-Detect button function

%AUTODETECT TEXT
uicontrol(findobj('Tag','GUI'),'Style','text',...
        'Position',[300 100 100 30],...
        'String','E-Radius (mm)')
%TRODE EDIT box
uicontrol(findobj('Tag','GUI'),'Style','edit',...
        'String',['3'],...
        'Position',[300 60 100 30],...
        'Tag',['editTrode'],...
        'Callback',@editTrode_Callback,...
        'Visible','on')
function editTrode_Callback(hObj, eventdata)
val = get(hObj,'String');
dispMsg(['Detection radius = ' val ' (mm)'])
end %edit trode function
%AUTODETECT TEXT
uicontrol(findobj('Tag','GUI'),'Style','text',...
        'Position',[235 100 60 30],...
        'String','Min. Points')
%TRODE EDIT box
uicontrol(findobj('Tag','GUI'),'Style','edit',...
        'String',['4'],...
        'Position',[235 60 60 30],...
        'Tag',['editMinPts'],...
        'Callback',@editMinPts_Callback,...
        'Visible','on')
function editMinPts_Callback(hObj, eventdata)
val = get(hObj,'String');
dispMsg(['Minimum Points for auto-detect = ' val ])
end %edit trode function
% --- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%DEPTH CHECKBOX
% uicontrol(h,'Style','checkbox',...
%         'String',['Depth '],...
%         'Position',[12 275 100 20],...
%         'Value',0,...
%         'Tag',['checkboxDepth'],...
%         'Callback',@checkboxDepth_Callback,...
%         'Visible','on')
%     % --- Executes on button press in checkboxNew.
% function [trodes]=checkboxDepth_Callback(hObj, eventdata)
% val = get(hObj,'Value');
% if val
%  trodes=guidata(findobj('Tag','GUI'));  
%  trodes.cloud=trodes.ct_points';
%  trodes.brush=1;
%  set(findobj('Tag','editBrush'),'String',num2str(trodes.brush));
%  %uncheck the other buttons
%  set(findobj('Tag','checkboxLabel'),'Value',0);set(findobj('Tag','checkboxNew'),'Value',0);set(findobj('Tag','checkboxNoise'),'Value',0);
%  set(g, 'WindowButtonDownFcn', {@callbackPickA3DPoint});
%  guidata(findobj('Tag','GUI'),trodes)
%  dispMsg('CHECKed DEPTH');
% else
%     dispMsg('un-checked DEPTH');
% end
% end %depth checkbox function
%DEPTH BUTTON
% uicontrol(h,'Style','pushbutton',...
%         'String',['DEPTH LABEL '],...
%         'Position',[175 275 100 20],...
%         'Tag',['pushbuttonDLabel'],...
%         'Callback',{@pushbuttonDLabel_Callback},...
%         'Visible','on')
% % --- Executes on button press in pushbuttonDepth Label.
% function [trodes]=pushbuttonDLabel_Callback(hObj, eventdata, jack)
%     trodes=guidata(findobj('Tag','GUI'));
%     %extract the user supplied identifier from the box
%     trodes.ident=get(findobj('Tag','editDLabel'),'String');
%     ident=str2num(trodes.ident);
%     if isempty(ident);
%         trodes.chan=find(strcmp(trodes.ident,jack.name));
%         trodes.name=trodes.ident;
%     elseif isnumeric(ident);
%         trodes.name=jack.name{ident};
%         trodes.chan=ident;
%     end
%     %
%     contacts=str2num(get(findobj('Tag','editDLabel2'),'String'));
%         [depths]=find_depths(trodes.prox,trodes.dist,contacts);
%         %then label them on the graph
%         for s=1:size(depths,1)
%             %creat a new point in the postproc structure
%             trodes.epoints(end+1,:)=depths(s,:);
%             trodes.postproc{end+1,1}=depths(s,:);
%             trodes.postproc{end,2}=trodes.chan+s-1;
%             trodes.postproc{end,3}=[trodes.name(1:end-1) num2str(s)];
% 
%             trodes.centr=depths(s,:);
%             %now plot
%             figure(findobj('Tag','GRAPH'));
%             plotE(trodes.centr,'y.',30);Etext(trodes.centr,trodes.chan+s-1,'black');
%         end
%         dispMsg(['AUTO-LABELED ' num2str(size(depths,1)) ' DEPTHS']);
%         guidata(findobj('Tag','GUI'),trodes)
%     
% end %depth label button function
%DEPTH EDIT box
% uicontrol(h,'Style','edit',...
%         'String',['ex: LAH1 or 1'],...
%         'Position',[330 275 160 20],...
%         'Tag',['editDLabel'],...
%         'Callback',@editDLabel_Callback,...
%         'Visible','on')
% function editDLabel_Callback(hObj, eventdata)
% val = get(hObj,'String');
% dispMsg(val)
% end %edit label function
% %Proximal Pushbutton
% uicontrol(h,'Style','pushbutton',...
%         'String',['PROXIMAL '],...
%         'Position',[175 240 100 20],...
%         'Value',0,...
%         'Tag',['pushbuttonProximal'],...
%         'Callback',@pushbuttonProximal_Callback,...
%         'Visible','on')
% function pushbuttonProximal_Callback(hObj, eventdata)
%  trodes=guidata(findobj('Tag','GUI'));
%  %creat a new point in the postproc structure
%  trodes.prox=trodes.centr;
%   figure(findobj('Tag','GRAPH'));plotE(trodes.centr,'b.',30);
%     dispMsg('SELECTED PROXIMAL');
%     guidata(findobj('Tag','GUI'),trodes)
% end %distal pushbutton function
%Distal Pushbutton
% uicontrol(h,'Style','pushbutton',...
%         'String',['DISTAL '],...
%         'Position',[280 240 100 20],...
%         'Value',0,...
%         'Tag',['pushbuttonDistal'],...
%         'Callback',@pushbuttonDistal_Callback,...
%         'Visible','on')
% function pushbuttonDistal_Callback(hObj, eventdata)
%  trodes=guidata(findobj('Tag','GUI'));
%  %creat a new point in the postproc structure
%  trodes.dist=trodes.centr;
%   figure(findobj('Tag','GRAPH'));plotE(trodes.centr,'c.',30);
%     dispMsg('SELECTED DISTAL');
%     guidata(findobj('Tag','GUI'),trodes)
% end %proximal pushbutton function
% %DEPTH EDIT box 2
% uicontrol(h,'Style','edit',...
%         'String',['8'],...
%         'Position',[10 240 160 20],...
%         'Tag',['editDLabel2'],...
%         'Callback',@editDLabel2_Callback,...
%         'Visible','on')
% function editDLabel2_Callback(hObj, eventdata)
% val = get(hObj,'String');
% dispMsg(val)
% end %edit label function
%%%%%%%%%%%%%%%%%
%STRIP NOISE BUTTON
uicontrol(findobj('Tag','GUI'),'Style','pushbutton',...
        'String',['STRIP-NOISE'],...
        'Position',[410 10 90 40],...
        'Tag',['pushbuttonStrip'],...
        'Callback',@pushbuttonStrip_Callback,...
        'Visible','on')
% --- Executes on button press in pushbuttonStrip.
function [trodes]=pushbuttonStrip_Callback(hObj, eventdata)
    dispMsg('Stripping artifact points');
    trodes=guidata(findobj('Tag','GUI'));
        trodes.max_dist=str2num(get(findobj('Tag','editMaxD'),'String'));
        %%%%%%%% PLOT %%%%%%%%%%%%%%
        figure(findobj('Tag','GRAPH'));
         [ trodes.ct_points , trodes.ct_strip ] = restrip_noise2( trodes.ct_diffs, trodes.ct_ras, trodes.max_dist );
         %delete the old dots!
       delete(trodes.arts);delete(trodes.stripd);
        %initialize graph
        figure(findobj('Tag','GRAPH'))
        trodes.arts=plotE(trodes.ct_points,'k.',4); %plot the CT points
        trodes.stripd=plotE(trodes.ct_strip,'y.',4); %plot the CT stripped points
        val=get(findobj('Tag','checkboxStrip'),'Value');
        if ~val
        set(trodes.stripd,'Visible','off');
        end         
        dispMsg('Done');
        guidata(findobj('Tag','GUI'),trodes);
    %end
end %saveFile button function
%STRIP TEXT
uicontrol(findobj('Tag','GUI'),'Style','text',...
        'Position',[410 100 90 30],...
        'String','Noise-Strip Dist. (mm)')
%MaxD EDIT box
uicontrol(findobj('Tag','GUI'),'Style','edit',...
        'String',['7'],...
        'Position',[410 60 90 30],...
        'Tag',['editMaxD'],...
        'Callback',@editMaxD_Callback,...
        'Visible','on')
function editMaxD_Callback(hObj, eventdata)
val = get(hObj,'String');
dispMsg(['Noise stripping distance = ' val ' (mm)'])
end %edit trode function
% reply=[];
% while isempty(strfind(reply,'done'))
%     reply = input(['Type "save" or "done" when finished...'],'s');
%     if ~isempty(strfind(reply,'save'))
%         dispMsg('Saving the coordinates, figures, and .mat files...');
%         trodes=guidata(findobj('Tag','GUI'));
         %postproc=trodes.postproc;
%         reply='done';
%     elseif ~isempty(strfind(reply,'done'))
%         dispMsg('Quitting without saving...');
%     else
%         dispMsg('error: not a valid reply; "save" or "done" ');
%     end
% end %while loop end statement
% %SNAP BUTTON
% uicontrol(findobj('Tag','GUI'),'Style','pushbutton',...
%         'String',['SNAP-2-SURF'],...
%         'Position',[300 10 100 20],...
%         'Tag',['pushbuttonSnap'],...
%         'Callback',@pushbuttonSnap_Callback,...
%         'Visible','on')
% --- Executes on button press in pushbuttonSnap.
% function pushbuttonSnap_Callback(hObj, eventdata, trodes)
%     trodes=guidata(findobj('Tag','GUI'));
%     %extract the user supplied identifier from the box
%     trodes.ident=get(findobj('Tag','editLabel'),'String');
%     
%  trodes.postproc.surf{end+1,:}={trodes.vert, trodes.chan, trodes.name, trodes.centr};
%   figure(findobj('Tag','GRAPH'));plotE(trodes.centr,'y.',30);
%     dispMsg(['LABELED ' trodes.name]);
%     guidata(findobj('Tag','GUI'),trodes)
% end %snap button function
end%main postproc function