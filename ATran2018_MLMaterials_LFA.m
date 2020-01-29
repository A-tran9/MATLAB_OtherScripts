% Basic LFA baseline measure script
% Coded by Alex Tran, PhD, (c) 2019
% Questions? 9trana@gmail.com, a_tran@hotmail.com
% Needs to have screen initializations, e.g., OpenWindow, Open AudioPort
% Make sure to define background colour of screen, triggers, sounds, and
% screen dimensions (rect)
run ATran2018_MLMaterials_GeneralInitialization.m

PsychPortAudio('Close',audhand);
audhand = PsychPortAudio('Open', [], [], 0, 22050, 2);

lfatiming=30; %length of time for LFA block
bkgrndc=white; %background colour of the screen
windowname=nwind; %Screen handle, defined in main script
trig1=uint8(1); %trigger for eyes open
trig2=uint8(2); %trigger for eyes closed

%Read's .wav files, assigns them to a two-column variable, 'lfaec' and
%'lfaeo' and takes the frequency from the wave files
[lfaecy, ~] = psychwavread('Stim_eyesclosed.wav');
[lfaeoy, freq] = psychwavread('Stim_eyesopen.wav');
lfaec=lfaecy';
lfaeo=lfaeoy';
audioportname=audhand;


% Draws text instructions on to the screen buffer (must be flipped on to screen)
DrawFormattedText(windowname, ['First we will begin with a resting EEG measure.'...
    '\n \n You will be given a fixation cross, please keep your eyes fixed '...
    'on the central cross the entire time. \n\nWhen you are ready to begin,'...
    'press any button.'],  'center'  ,'center', black)
Screen('Flip', windowname); %flips text on to the screen

KbStrokeWait; %waits for a KeyBoard stroke before progressing

IOPort('Write',TPort,uint8(0),0); %clears the IOPort

% Draws a fixation cross using pre-defined text size during screen
% initialization (must be flipped on to screen)
DrawFormattedText(windowname, '+',  'center'  ,'center', black);
Screen('Flip', windowname); %flips text on to the screen

IOPort('Write',TPort,trig1,0);%sends trigger to the IOPort

WaitSecs(lfatiming);%Time period for LFA block, shorten for debugging script

IOPort('Write',TPort,uint8(0),0);%clears the IOPort

Screen('FillRect', windowname, bkgrndc, rect);% clear screen 1; draws a rectangle with colour of background
Screen('Flip', windowname,[],0); % clear screen 2; flips rectangle to screen

DrawFormattedText(windowname, ['You''ve completed an ''eyes open'' baseline measure.'...
    '\n Press any button to continue to an ''eyes closed'' '...
    'baseline measure.'],  'center'  ,'center', black);
Screen('Flip', windowname,[],1); %flip text on to the screen

KbStrokeWait(); % waits for a KeyBoard stroke before progressing

Screen('FillRect', windowname, bkgrndc, rect); % clear screen 1; draws a rectangle with colour of background
Screen('Flip', windowname,[],0); % clear screen 2; flips rectangle to screen

PsychPortAudio('FillBuffer', audioportname, lfaec);  
PsychPortAudio('Start', audioportname, 1, 0, 1);

IOPort('Write',TPort,trig2,0);%sends trigger to the IOPort

WaitSecs(lfatiming);%Time period for LFA block, shorten for debugging script

PsychPortAudio('FillBuffer', audioportname, lfaeo);  
PsychPortAudio('Start', audioportname, 1, 0, 1);

IOPort('Write',TPort,uint8(0),0);%clears the IOPort

DrawFormattedText(windowname, ['You''ve completed the baseline calibration'...
    ' measure. \n Press any button to continue the experiment.']...
    ,  'center'  ,'center', black);
Screen('Flip', windowname,[],1); 

KbStrokeWait();% waits for a KeyBoard stroke before progressing

Screen('FillRect', windowname, bkgrndc, rect); % clear screen 1; draws a rectangle with colour of background
Screen('Flip', windowname,[],0); % clear screen 2; flips rectangle to screen

sca;