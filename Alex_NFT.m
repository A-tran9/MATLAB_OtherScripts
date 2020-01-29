clear all

close all

%% Operating Initializations for: Keyboard responses, Sounds, IOPort, Screen %%
%Setting up basic operations for MATLAB EEG Experiment
%Coded by Alex Tran, PhD, (c) 2018
%Questions? 9trana@gmail.com, a_tran@hotmail.com

%**Keyboard**%

%Define the numerical codes for each key press on the keyboard; 
KbName('UnifyKeyNames');
%Defines variables for: checking if the key is down, the time at keyboard check, and
%numerical code of the key that is pressed
[keyIsDown,secs,keyCode]=KbCheck;

%****Sound****%

%Sound card preparation
InitializePsychSound;

%Sets a call-able handle to the audio operations
pahandle = PsychPortAudio('Open', [], [], 0, 44000, 2);

%****IOPort****%

%Creates a virtual serial port based on COM3 (check in Device Manager when
%connecting the trigger box to confirm)
%[TPort]=IOPort('OpenSerialPort','COM3','FlowControl=Hardware(RTS/CTS lines) SendTimeout=1.0 StopBits=1');

%****Screen****%

%Defines the colours white grey and black
white = WhiteIndex(0);
grey = white / 2;
black = BlackIndex(0);

%Initializes the screen, gives the screen the handle 'window' and fills it white
[window, rect]=Screen('OpenWindow',0,[white]);

%Sets default text characteristics for the window with the specified handle
Screen('TextSize',window, 40);

%These variables determine the center of the screen
v_res = rect(4);
h_res = rect(3);
v_center = v_res/2;
h_center = h_res/2;

%Assigns 'fixation' to be a variable representing the center of the screen
fixation = [h_center-10 v_center-10];

%% Stimulus development and preparation %%
%Setting up P3a sound stimuli and Stroop keys
%Coded by Alex Tran, PhD, (c) 2018
%Questions? 9trana@gmail.com, a_tran@hotmail.com


%Naming and assigning triggers values to our stimuli(must be 8-bit integers)

bl1tg=uint8(1);

%Assigning keys to different colours, use 'UnifyKeyNames' to know what key
%strings will represent which physical keys on the keyboard
RED=KbName('1!');   
    keypRED = zeros(1,256);
    keypRED ([RED]) = 1;
    
GREEN=KbName('2@');    
    keypGREEN = zeros(1,256);
    keypGREEN ([GREEN]) = 1;

BLUE=KbName('3#');
    keypBLUE = zeros(1,256);
    keypBLUE ([BLUE])=1;
        
YELLOW=KbName('4$');    
    keypYELLOW = zeros(1,256);
    keypYELLOW ([YELLOW])=1;
    
    keysOfInterest=zeros(1,256);
	keysOfInterest([RED, GREEN, BLUE, YELLOW])=1;
	
    KbQueueCreate(-1, keysOfInterest);
    KbQueueStart; 

    WORDCOLORS = {'RED', 'GREEN', 'BLUE', 'YELLOW'};

    rgbColors = [255 0 0; 0 255 0; 0 0 255; 255 255 0];


   
starttime=Screen('Flip',window);

KbQueueFlush;

PsychPortAudio('Volume', pahandle, 0.8);


% Demographics, general habit questionnaire, personality questionnaires
%    need to figure out how to create text boxes
%    COLLECT LIKERT
%    WRITTEN TO CELL

% Baseline LFA session, 2 minutes eyes open 2 minutes eyes closed; 
%    picture & audio need to be presented

% Training period
%    DRAWFORMATTED TEXT
%    visual example? thermometer? coloured screen?
%    8 blocks, 5 minutes each, 1 minute of rest between
%    COLLECT LIKERT
%    Navon task; concrete manipulation check

% Post-baseline LFA session, 2 minutes eyes open 2 minutes eyes closed; 

% Handgrip task
%    DRAWFORMATTED TEXT

% Post-session questionnaire
%    what were you thinking about?
%    level of focus throughout the experiment
%    awareness of internal states
%    general affect
%    BISBAS-State
%    Exercise intentions
%    ID number and continue session?

DrawFormattedText(window, '+',  'center'  ,'center', black);
Screen('DrawText',window,'Please keep your eyes fixed on the central cross the entire time.',...
    fixation(1)-550,fixation(2)-150,black);  %Display instructions
Screen('DrawText',window,'When you are ready to begin, press any button.',fixation(1)-400,...
    fixation(2)-100,black);  %Display instructions
Screen('Flip', window,[],1); %flip it to the screen
KbWait();

Screen('FillRect', window, [white]);
DrawFormattedText(window, '+',  'center'  ,'center', black);
Screen('Flip', window,[],1); %flip it to the screen

p3atrial=1
p3atrialmatrix = [0,0];

for p3atrial=1:5
    %IOPort('Write',TPort,uint8(0))
    WaitSecs(.5);
    p3atrial_type =  randi(10)
    if p3atrial_type <= 2
    wavedata = stl;
    %IOPort('Write',TPort,blstltrig)
    else
    wavedata = stnd;
    %IOPort('Write',TPort,blstndtrig)    
    end
    p3atrialmatrix = [p3atrialmatrix ; [p3atrial, p3atrial_type]]; 
    PsychPortAudio('FillBuffer', pahandle, wavedata);
    PsychPortAudio('Start', pahandle, 1, 0, 1);
    p3atrial = p3atrial+1;
end

sca;