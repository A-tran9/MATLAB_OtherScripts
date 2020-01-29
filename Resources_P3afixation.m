   % P300.m 
  % Kyle Mathewson , UIUC, 2012
  % P300 to test the emotiv

                 
clear all
close all
sca;
Screen('Preference', 'SkipSyncTests', 1); %for test on an LCD
Priority(2);
%------------------------
%set up some constants
%------------------------  
n_trials = 5; 
n_blocks = 3;                                         
     %% Set up parallel port
%initialize the inpoutx64 low-level I/O driver
%config_io;
%optional step: verify that the inpoutx64 driver was successfully installed
%global cogent; 
%if( cogent.io.status ~= 0 )
%   error('inp/outp installation failed');
%end
%write a value to the default LPT1 printer output port (at 0x378)
%address_eeg = hex2dec('B010');

%outp(address_eeg,0);  %set pins to zero  
%------------------------
%% Create the stimuli
%------------------------
% Generate data from tones *ATran
stnd = audioread('standard.wav');
stl = audioread('start.wav');


%% Open the main window and get dimensions
white=[255,255,255];  %WhiteIndex(window);
black=[0,0,0];   %BlackIndex(window);

grey= [128 128 128]; %background colour

%load the window up
screenNumber = max(Screen('Screens')); % Get the maximum screen number i.e. get an external screen if avaliable
[window,rect]=Screen(screenNumber ,'OpenWindow',black);
% [window,rect]=Screen(screenNumber ,'OpenWindow',grey(1), [100 100 800 800] ); %use this line for testing
HideCursor; %Comment this out for testing    

v_res = rect(4);
h_res = rect(3);
v_center = v_res/2;
h_center = h_res/2;
fixation = [h_center-10 v_center-10];
trigger_size = [0 0 0 0]; %use [0 0 1 1] for eeg, 100 100 for photodiode

% Get presentation timing information
refresh = Screen('GetFlipInterval', window); % Get flip refresh rate
slack = refresh/2; % Divide by 2 to get slack

%setup the fixation screen
fixate=Screen(window,'OpenoffScreenWindow',black);
    Screen(fixate, 'DrawLines', [-7 7 0 0; 0 0 -7 7], 1, white, [h_center,v_center],0);  %Print the fixation,
    
    
%% Instructions
Screen('DrawLines',window, [-7 7 0 0; 0 0 -7 7], 1, white, [h_center,v_center],0);  %Print the fixation,
Screen('DrawText',window,'Please keep your eyes fixed on the central cross the entire time.',fixation(1)-500,fixation(2)-100,white);  %Display instructions
Screen('Flip', window,[],0); %flip it to the screen
 KbWait; %wait for subject to press button
WaitSecs(2)
 
%% subject starts the experiment
KbWait %wait for subject to      press button
%outp(address_eeg,10); %send signal for the next block
block_start = GetSecs();
WaitSecs(.01);
%outp(address_eeg,0);
% fwrite(s,99);


%% put up fixation and blank
Screen('CopyWindow',fixate ,window,rect,rect);
tqfixate_onset = Screen(window, 'Flip');
WaitSecs(2);



%------------------------
%% Display the flashing stimuli
%------------------------

trial_type = zeros(n_trials,1); 
trial_start = zeros(n_trials,1);

for i_block = 1:n_blocks
    
for i_trial = 1:n_trials    
    
    
    WaitSecs((randi(500)/1000)+ISI_gap);
%     WaitSecs(.09);

    % Pick if its a target trial
    %------------------------------------------
    trial_type(i_trial) =  randi(5); %randomly pick if this trial is a white high target
     
    if trial_type(i_trial) == 1
        curr_snd = stnd;
    else
        curr_snd = stl;
    end
    
    PsychPortAudio('FillBuffer', pahandle, curr_snd);
   
    trial_start(i_trial) = PsychPortAudio('Start', pahandle, 1, 0, 1);
    %outp(address_eeg,trial_type(i_trial)); %send signal for the next block  trial_type(i_trial)
    WaitSecs(.01);
    %outp(address_eeg,0);    
    pause(p.dur);
    PsychPortAudio('Stop', pahandle);
    
end
   Screen('DrawText',window,'You have finished one block, press any key to continue',fixation(1)-500,fixation(2)-100,white);
   KbWait;
end



block_end = GetSecs();

Screen('DrawText',window,'Thank you for participating in the experiment. Please alert the experimenter that you are finished.',fixation(1)-500,fixation(2)-100,white);  %Display instructions
Screen('Flip', window,[],1); %flip it to the screen
WaitSecs(2)
 KbWait; %wait for subject to press button
%% Save the data and close the window, exit
Screen('Close', window);
ShowCursor;