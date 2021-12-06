function sk_start_marking(file_name)
% To mark the electrode positions and save them in the same name with the .xyz format
% positions from a 3D head model
% 
% IMPORTANT
% --------------------------------------
% Please read the following before using
% --------------------------------------
%
% --- First Steps ---
% 1.) In the 'Load the toolboxes' section, make sure that the correct location of the fieldtrip toolbox is specified
% 2.) In the 'Inward Movement' section make sure the variable 'cfg.moveinward' has the desired value. I have set the default value of 12 mm.
% 3.) Now start the script by calling 'sk_start_marking('model_name')' ---> eg: model_name
%
% Usage
% sk_start_marking('model_name')
%               'model_name' is just an example model name
%
% Input
% file_name :   Please enter the file_name (the model file name) as string. Make sure
%               this is in the working folder
%
%
% Output
% A '.mat' file with the same name as the input file in the working folder 
%
%
% Helpful keys (mouse)
% 1.) The left mouse key is used to move the 3d model (head model) around,
% 2.) The center mouse key (unofrtunately not on a MAC) is used to click and fix the electrode position
%
% Helpful keys (keyboard)
% 1.) Alternative to the mouse the head model can be also moved with the keys 'w' 'a' 's' 'd'
% 2.) To correct the last wrongly clicked electrode position, press 'r'. This will undo the last click (only 1 as a time). Then the correct position can be closed again. 
% 3.) After all the electrodes are maked (32x4 = 128), then press 'q' to end the process. If there is a mismatch, there will be an error. 
%
%
%
% author: Saurabh Steixner-Kumar
%


wanted.save = 1; % save the marked electode positions (same name as the input filename)

% slash style (dependent on the OS)
if ispc
    slash = '\';
elseif isunix
    slash = '/';
end

%
%% Load the toolboxes
% fieldtrip toolbox (add the correct path here)
addpath(strcat(slash,'fieldtrip-...'));
% initialize the toolbox
ft_defaults;

%% Loading the required data
% output folder path
save_output = strcat(pwd,slash);
%
% read the model file
head_surface_default = ft_read_headshape((strcat(pwd,slash,file_name,'.obj')),'format','obj');
disp(head_surface_default); % display the loaded data

% convert the units from m to mm
head_surface_default = ft_convert_units(head_surface_default,'mm');

%% conversions
labeled_properly = 0;
while ~labeled_properly
    
    % visualize the mesh
    % ft_plot_mesh(head_surface);
    
    % mesh into ctf coordinates
    cfg = [];
    cfg.method = 'headshape';
    fiducials = sk_electrodeplacement(cfg,head_surface_default);
    fiducials.label = {'nas','lpa','rpa'};
    
    %clear the figures
    close all;
    
    
    % to get the nasion, rpa and lpa for correct positioning
    cfg = [];
    cfg.method = 'fiducial';
    cfg.coordsys = 'ctf';
    cfg.fiducial.nas    = fiducials.elecpos(1,:); %position of NAS
    cfg.fiducial.lpa    = fiducials.elecpos(2,:); %position of LPA
    cfg.fiducial.rpa    = fiducials.elecpos(3,:); %position of RPA
    head_surface = ft_meshrealign(cfg,head_surface_default);
    
    
    % visualize
    ft_plot_axes(head_surface);
    ft_plot_mesh(head_surface);
    done = 0;
    while ~done
        k = waitforbuttonpress; % wait for a keypress
        currkey=get(gcf,'CurrentKey');
        if k==1 && (strcmp(currkey, 'q'))
            labeled_properly = true;
            done = true;
        elseif k==1 && (strcmp(currkey, 'r'))
            done = true;
        end
    end    
end

%% get the electrode locations
cfg = [];
cfg.method = 'headshape';
elec = sk_electrodeplacement(cfg,head_surface);
% change the electrode names from default 1,2,3,4.. to something meaningful
elec_in_a_label = 32;
count_label = 0;temp_label = 'A';
for loop_elec = (elec_in_a_label *0+1):elec_in_a_label 
    count_label = count_label+1;
    elec.label(loop_elec) = {strcat(temp_label,num2str(count_label))};
end
count_label = 0;temp_label = 'B';
for loop_elec = (elec_in_a_label *1+1):elec_in_a_label *2
    count_label = count_label+1;
    elec.label(loop_elec) = {strcat(temp_label,num2str(count_label))};
end
count_label = 0;temp_label = 'C';
for loop_elec = (elec_in_a_label *2+1):elec_in_a_label *3
    count_label = count_label+1;
    elec.label(loop_elec) = {strcat(temp_label,num2str(count_label))};
end
count_label = 0;temp_label = 'D';
for loop_elec = (elec_in_a_label *3+1):elec_in_a_label *4
    count_label = count_label+1;
    elec.label(loop_elec) = {strcat(temp_label,num2str(count_label))};
end
clear count_label temp_label elec_in_a_label loop_elec


%clear the figures
close all;


% visualize so far
ft_plot_axes(head_surface);
ft_plot_mesh(head_surface);
ft_plot_sens(elec,'label','on')
% ft_plot_sens(elec)



%% Inward Movement
% Inward movement from the cap to the skin surface
% this moves the electrode positions from the surface of the cap to the
% actual location on the scalp. I am using the default value of 12 mm here.
% This value can be changed below
cfg = [];
cfg.method = 'moveinward'; %'moveinward' moves electrodes inward along their normals
cfg.moveinward = 12;     %cfg.moveinward     = number in mm, the distance that the electrode should be moved
                           %inward (negative numbers result in an outward move)
cfg.elec = elec;
elec = ft_electroderealign(cfg);

%%
% visualize all together
ft_plot_axes(head_surface);
ft_plot_mesh(head_surface);
ft_plot_sens(elec)


%% saving section
if wanted.save
    elec.sub_id = str2double(file_name);
    save(strcat(save_output,file_name),'elec');
end
%


%%
