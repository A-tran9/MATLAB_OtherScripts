trig7=uint8(17);      %Joanna Scanlon, September 2015
%NOTE: Trigger 11 = Trial 1 Eyes closed - start
%      Trigger 12 = Trial 1 Eyes closed - end
%      Trigger 13 = Trial 1 Eyes open - start
%      Trigger 14 = Trial 1 Eyes open -  end

%      Tri gger  21 = Trial 2 Eyes closed - start
%      Trigger 22 = Trial 2 Eyes closed - end
%      Trigger 23 = Trial  2 Eyes open - start
%      Trigger 24 = Trial 2 Eyes open -  end
%    If there are more trials, the pattern just continues with 31, 32, 33,
%    34, 41...
% clear all
% close all

function Baseline_Alpha()

try

% % HideCursor
Priority(2);

%%settings
n_blocks = 2; %how many times do you want to go through eyes closed-open cycle 
trial_time = 3; %%in minutes - Change this according to how long you want to measure alpha waves

%%
p.dur = .016; %duration of tone (seconds)
p.rampDur = .002; % duration of the ramp gradually turning the sound on and off
p.nrchannels = 1; % one channel only -> Mono sound
p.sampRate = 2*8192;  %Hz

     %% Set up parallel port
%initialize the inpoutx64 low-level I/O driver
config_io;
%optional step: verify that the inpoutx64 driver was successfully installed
global cogent;
if( cogent.io.status ~= 0 )
   error('inp/outp installation failed');
end
%write a value to the default LPT1 printer output port (at 0x378)
address_eeg = hex2dec('B010');

outp(address_eeg,0);  %set pins to zero

black = [0 0 0];
screenNumber = max(Screen('Screens')); % Get the maximum screen number i.e. get an external screen if avaliable
[win,rect]=Screen(screenNumber ,'OpenWindow',black(1));
% % [win,rect]=Screen(screenNumber ,'OpenWindow',black(1), [100 100 800 800] ); %use this line for testing

% %THIS IS THE TRIGGER  


InitializePsychSound;
pahandle = PsychPortAudio('Open', [], [], 0, p.sampRate, p.nrchannels);

% build the sounds
% base tone:
t = linspace(0,p.dur,p.dur*p.sampRate);
% ramp starts at 0, becomes 1 over the course of .05s and ramps down again
% at the end
ramp = ones(size(t));
ramp(t<p.rampDur) = linspace(0,1,sum(t<p.rampDur));
ramp(t>p.dur-p.rampDur) = linspace(1,0,sum(t>p.dur-p.rampDur));

%get the screen resolution (hint, check the workspace)
v_res = rect(4);
h_res = rect(3);
v_center = v_res/2;
h_center = h_res/2;
h_right = h_res - h_res/4;
fixation = [h_center-10 v_center-10];
trigger_size = [0 0 0 0]; %use [0 0 1 1] for eeg, 100 100 for photodiode
low_tone = sin(2*pi*t*1000).*ramp;

%load the window up
white= [255 255 255]; %background colour
red = [255 0 0];
black = [0 0 0];
blue = [0 128 255];


%
% screenNumber = max(Screen('Screens')); % Get the maximum screen number i.e. get an external screen if avaliable
% [window,rect]=Screen(screenNumber ,'OpenWindow',white(1));

%Instruction
Screen('DrawText',win,'Instructions: ',fixation(1)-600,fixation(2)-140,white);
Screen('DrawText',win,'To advance to the next screen, press any key on the keyboard.',fixation(1)-600,fixation(2)-100,white);
Screen('DrawText',win,'Try it now!',fixation(1)-500,fixation(2)-60,white);
curr_snd = low_tone;
%Display instructions
Screen('Flip', win,[],0); %flip it to the screen
WaitSecs(0.5);
KbWait; %wait for subject to press button

Screen('DrawText',win,'Good job!',fixation(1)-600,fixation(2)-100,white);
Screen('DrawText',win,'Now keep doing that once your done reading what is on the screen, to go through the instructions.',fixation(1)-600,fixation(2)-60,white);
%Display instructions
Screen('Flip', win,[],0); %flip it to the screen
WaitSecs(0.5);
KbWait; %wait for subject to press button

Screen('DrawText',win,'This part of the experiment is meant to measure the baseline levels of some of your brain waves,',fixation(1)-700,fixation(2)-100,white);
Screen('DrawText',win,'by recording your brain while in a resting state, with eyes open and closed.',fixation(1)-700,fixation(2)-60,white);
%Display instructions
Screen('Flip', win,[],0); %flip it to the screen
WaitSecs(0.5);
KbWait; %wait for subject to press button

Screen('DrawText',win,'First, we will ask that you sit quietly with your eyes closed for 3 minutes.',fixation(1)-600,fixation(2)-100,white);
Screen('DrawText',win,'After 3 minutes, you will be signalled by a tone to open your eyes.',fixation(1)-600,fixation(2)-60,white);
%Display instructions
Screen('Flip', win,[],0); %flip it to the screen
WaitSecs(0.5);
KbWait; %wait for subject to press button

Screen('DrawText',win,'Then, we will ask you to sit for 3 minutes with your eyes open,',fixation(1)-600,fixation(2)-100,white);
Screen('DrawText',win,'staring at the fixation cross on the screen.',fixation(1)-600,fixation(2)-60,white);
Screen('DrawText',win,'Again, a tone will notify you that the 3 minutes is over.',fixation(1)-600,fixation(2)-20,white);
%Display instructions
Screen('Flip', win,[],0); %flip it to the screen
WaitSecs(0.5);
KbWait; %wait for subject to press button

Screen('DrawText',win,'After this the task will be repeated:  ',fixation(1)-500,fixation(2)-100,white);
Screen('DrawText',win,'3 minutes with eyes closed, 3 minutes with eyes open,',fixation(1)-500,fixation(2)-60,white);
Screen('DrawText',win,'signalled with the sound of a tone.',fixation(1)-500,fixation(2)-20,white);
%Display instructions
Screen('Flip', win,[],0); %flip it to the screen
WaitSecs(0.5);
KbWait; %wait for subject to press button

Screen('DrawText',win,'Please let the experimenter know if you have any questions, ',fixation(1)-500,fixation(2)-100,white);
Screen('DrawText',win,'or press the button on the intercom if you need anything during the task.',fixation(1)-500,fixation(2)-60,white);
%Display instructions
Screen('Flip', win,[],0); %flip it to the screen
WaitSecs(0.5);
KbWait; %wait for subject to press button

trial_type = zeros(n_blocks,1);
trial_start = zeros(n_blocks,1);



for i_block = 1:n_blocks
    
    curr_snd = low_tone;
    Trigger =  (i_block*10);
    PsychPortAudio('FillBuffer', pahandle, curr_snd);
    
    %%     Screen('DrawText',window,'Feel free to take a quick break here. ',fixation(1)-500,fixation(2)-140,white);
    Screen('DrawText',win,'When you are ready, press any key and close your eyes. ',fixation(1)-500,fixation(2)-100,white);
    Screen('DrawText',win,'Only open them again when your hear the tone.',fixation(1)-500,fixation(2)-60,white);
    %Display instructions
    Screen('Flip', win,[],0); %flip it to the screen
    WaitSecs(0.5);
    KbWait; %wait for subject to press button
    
    
    
    %% SEND TRIGGER 1-EYES closed-START
    outp(address_eeg,Trigger + 1); %send signal for the next block
    WaitSecs(.01);
    outp(address_eeg,0);
    
    Screen('DrawLines',win, [-7 7 0 0; 0 0 -7 7], 1, black, [h_center,v_center],0);  %Print the fixation,
    Screen('Flip', win,[],0); %flip it to the screen
    WaitSecs(trial_time*60)  %%Use when running-Commented out for testing
% %     WaitSecs (0.5);
    %KbWait; %Comment out for Running
    
    
    
    %% PLAY TONE
    %SEND TRIGGER 2- EYES CLOSED END
    %  outp(address_eeg,trial_type(i_block)); %send signal for the next block
    %     WaitSecs(.01);
    %     outp(address_eeg,0);
    
    trial_start(i_block) = PsychPortAudio('Start', pahandle, 1, 0, 1);
    outp(address_eeg,Trigger + 2); %send signal for the next block
    WaitSecs(.01);
    outp(address_eeg,0);
    pause(p.dur);
    PsychPortAudio('Stop', pahandle);
    
    Screen('DrawText',win,'Feel free to take a quick break here. ',fixation(1)-500,fixation(2)-140,white);
    Screen('DrawText',win,'When you are ready, press any key and stare at the fixation, ',fixation(1)-500,fixation(2)-100,white);
    Screen('DrawText',win,'until you hear the tone. ',fixation(1)-500,fixation(2)-60,white);
    Screen('Flip', win,[],0); %flip it to the screen
    WaitSecs(0.5);
    KbWait; %wait for subject to press button
    %%
    
    
    %SEND TRIGGER 3-EYES open-START
   
    outp(address_eeg,Trigger + 3); %send signal for the next block
    WaitSecs(.01);
    outp(address_eeg,0);
    
    % Screen('DrawText',win,'If you can see this, close your eyes again. ',fixation(1)-500,fixation(2)-100,white);
    % Screen('DrawText',win,'Only open them again when your hear the tone.',fixation(1)-500,fixation(2)-140,white);
    Screen('DrawLines',win, [-7 7 0 0; 0 0 -7 7], 1, white, [h_center,v_center],0);  %Print the fixation,
    %Display instructions
    Screen('Flip', win,[],0); %flip it to the screen
    WaitSecs(trial_time*60) %%Commented out for testing-use for running!
    %WaitSecs(0.5);
    %KbWait; %Comment out for running!
    
    %% SEND TRIGGER-EYES OPEN- END
    %PLAY TONE
    %
    trial_start(i_block) = PsychPortAudio('Start', pahandle, 1, 0, 1);
    outp(address_eeg,Trigger + 4); %send signal for the next block
    WaitSecs(.01);
    outp(address_eeg,0);
    pause(p.dur);
    PsychPortAudio('Stop', pahandle);
    
    Screen('DrawText',win,['You are now finished block ' num2str(i_block) ' out of 2. Press any key to continue.'],fixation(1)-500,fixation(2)-100,white);
    Screen('Flip', win,[],0); %
    WaitSecs(0.5);
    KbWait; %Comment out for running!
       
end

Screen('DrawText',win,'Thank you for participating in this task. Please alert the experimenter that you are finished.',fixation(1)-500,fixation(2)-100,white);  %Display instructions
Screen('Flip', win,[],0); %flip it to the screen
WaitSecs(0.5)
KbWait; %wait for subject to press button
ShowCursor;
Screen('Close', win);

catch
    
Screen('Close',win);
rethrow(lasterror);
    
end
end
% sca




