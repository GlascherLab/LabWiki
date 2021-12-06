function sk_check_triggers(file_name)
% To check and recover trigger values saved in the EEG recoded file from the Actiview software
% 
% IMPORTANT
% --------------------------------------
% Please read the following before using
% --------------------------------------
%
% --- First Steps ---
% 1.) In the 'Load the toolboxes' section, make sure that the correct location of the fieldtrip toolbox is specified
% 2.) Now start the script by calling 'sk_check_triggers('EEG_fileanme')' ---> eg: EEG_fileanme
%
% Usage
% sk_check_triggers('EEG_fileanme')
%               'EEG_fileanme' is just an example EEG recoded file name
%
% Input
% file_name :   Please enter the file_name (recoded EEG file name) as string. Make sure
%               this is in the working folder
%
%
% Output
% Displays the unique EEG triggers and their count.
% Followed by this are the photodiode triggers and their count%
%
%
% author: Saurabh Steixner-Kumar
%


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

%% Calculation
events = ft_read_event(file_name); % EEG file name
events_trigger = events(strcmp({events.type}, 'STATUS'));
byte.second = nan(1,size(events_trigger,2)); % The photodiode triggers
byte.first = nan(1,size(events_trigger,2)); % The EEG triggers
for loop_triggers = 1:size(events_trigger,2)
    in_binary = dec2bin(events_trigger(loop_triggers).value,24)-'0';
    binary_usb = in_binary(9:16);
    binary_usb_1 = in_binary(17:24);
    byte.second(loop_triggers) = bin2dec(num2str(binary_usb));
    byte.first(loop_triggers) = bin2dec(num2str(binary_usb_1));
end

% to check the number of eeg triggers
trigg = unique(byte.first);
for loop_trig = 1:length(trigg)
    trig_number(loop_trig,1:2) = [trigg(loop_trig), length(find(byte.first==trigg(loop_trig)))];
end
display(trig_number)

% to check the number of photo diode triggers
trigg = unique(byte.second);
for loop_trig = 1:length(trigg)
    trig_number(loop_trig,1:2) = [trigg(loop_trig), length(find(byte.first==trigg(loop_trig)))];
end
display(trig_number)

%%
