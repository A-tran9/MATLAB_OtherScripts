  %P300.m 
  % Kyle Mathewson , UIUC, 2012
  % P300 to test the emotiv


clear all
close all
sca;
WaitSecs(.01);
GetSecs;
%------------------------ 
%set up some constants
%------------------------
n_trials = 1000  ;
 
s = serial('COM2')
set(s,'baudrate',9600); 
fopen(s);  

%------------------------
% Create the stimuli
%------------------------



p.dur = .016; %duration of tone (seconds)
p.rampDur = .002; % duration of the ramp gradually turning the sound on and off
p.nrchannels = 1; % one channel only -> Mono sound

p.sampRate = 2*8192;  %Hz


% Perform basic initialization of the sound driver:
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


high_tone = sin(2*pi*t*1500).*ramp;
low_tone = sin(2*pi*t*1000).*ramp;

KbWait %wait for subject to      press button
block_start = GetSecs();
fwrite(s,99);
WaitSecs(2);


tic_log = zeros(60,1);

for i=1:30;
    WaitSecs(randi(3)/10);
    fwrite(s,66);
    tic_log(i) = GetSecs();
end
WaitSecs(2);

%------------------------
% Display the flashing stimuli
%------------------------

trial_type = zeros(n_trials,1);
trial_start = zeros(n_trials,1);
    
for i_trial = 1:n_trials    
    
    
%     WaitSecs((randi(500)/1000)+.8  );
    WaitSecs(.09);

    % Pick if its a target trial
    %------------------------------------------
    trial_type(i_trial) = randi(5); %randomly pick if this trial is a white high target
    
    if trial_type(i_trial) == 1
        curr_snd = high_tone; 
    else
        curr_snd = low_tone;
    end
    
    PsychPortAudio('FillBuffer', pahandle, curr_snd);
    trial_start(i_trial) = PsychPortAudio('Start', pahandle, 1, 0, 1);
    fwrite(s,trial_type(i_trial));
    pause(p.dur);
    PsychPortAudio('Stop', pahandle);
    
end

WaitSecs(2);
for i=1:30;
    WaitSecs(randi(3)/10);
    fwrite(s,66);
    tic_log(i+30) = GetSecs();
end
WaitSecs(2);

block_end = GetSecs();
fwrite(s,99);
  
[beh_name, beh_path] = uiputfile('*.mat','Save the behavioural .mat file');
save([beh_path beh_name])

 