clear all

close all

%% Operating Initializations for: Keyboard responses, Sounds, IOPort, Screen %%
%Setting up basic operations for MATLAB EEG Experiment
%Coded by Alex Tran, PhD, (c) 2018
%Questions? 9trana@gmail.com, a_tran@hotmail.com

%****Keyboard****%

%Sets the default numerical codes for each key button-press on the keyboard; 
KbName('UnifyKeyNames');

%Defines the 3 variables for: checking if the key is down, the time at 
%keyboard check, and numerical code of the key that was pressed
[keyIsDown,keysecs,keyCode]=KbCheck;

%****Sound****%

%Sound card preparation
InitializePsychSound;

%Sets a call-able handle 'audhand' to the audio operations
audhand = PsychPortAudio('Open', [], [], 0, 48000, 2);

%****IOPort****%

%Creates a virtual serial port with call-able handle 'TPort' based on COM3 
% (check in Device Manager what the identity of the serial port is when 
% connecting the trigger box to confirm)
% [TPort]=IOPort('OpenSerialPort','COM3','FlowControl=Hardware(RTS/CTS lines) SendTimeout=1.0 StopBits=1');

%****Screen****%
%Defines the basic colours of the screen: white, grey and black
%Other colours MUST BE DEFINED if you would like to use them
white = WhiteIndex(0);
grey = white / 2;
black = BlackIndex(0);

%Initializes the screen, gives the screen the call-able handle 'nwind' and
%sets the variable 'rect' to be the screen resolution.
%rect is a 4-column variable with the 3rd-column being the width, and the 
%4th-column is the height it also fills the screen white (which was defined above)
[nwind, rect]=Screen('OpenWindow',0,[white]);

%Sets default text size for the 'nwind' screen handle
Screen('TextSize',nwind, 40);

%These variables determine the center of the screen based on the 'rect'
%variable and names them as v_res (vertical resolution) and h_res
%(horizontal), it also determines the center point of vertical and
%horizontal
v_res = rect(4);
h_res = rect(3);
v_center = v_res/2;
h_center = h_res/2;

%Assigns 'fixation' to be a variable representing the center of the screen
fixation = [h_center-10 v_center-10];

%% Pre-stimulus development of: Sounds, Triggers, Keyboard assignment, and Stroop Matrix %%
%Setting up P3a sound stimuli and Stroop keys
%Coded by Alex Tran, PhD, (c) 2018
%Questions? 9trana@gmail.com, a_tran@hotmail.com

%Read's .wav files, assigns them to a two-column variable, 'stndy' and
%'stly' and takes the frequency from the startle wave file
[stndy, ~] = psychwavread('Stim_standard.wav');
[stly, freq] = psychwavread('Stim_start.wav');

%Transposes the variables to a two-row variable to be read by the
%PsychAudioPort, as a two-column variable cannot be played as a sound
stnd=stndy';
stl=stly';

%Naming and assigning values to our triggers stimuli (they must be 8-bit 
%integers) for more help search the 'uint8' function; 
%Note: it creates an 8-bit value from the number you put in, however because 
%it only has a max of 8-bits, the triggers number inputs will not be the
%number you get as a trigger output (e.g., uint8(17) will not appear as the 
%trigger number 17)
stltrig=uint8(1);
stndtrig=uint8(2);
ERNtrig=uint8(11);
CRNtrig=uint8(12);
FRN=uint8(17);

%This code creates a variable RED which will be the numerical representation
%of a physical keyboard button; use the function 'KbName('KEYBOARD BUTTON')' 
%to know how each key on the keyboard is represented numerically
RED=KbName('1!');

%Makes a row of 256 zeros
keypRED = zeros(1,256);

%Puts the number 1 at the column which represents the numerical value of
%the keyboard button you decided to represent the colour RED
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

%Creates the variable 'keysOfInterest' which is a row of 256 zeros
keysOfInterest=zeros(1,256);

%Changes certain values in the specific columns of the 'keysOfInterest' to be
%1s insted of 0s, but only for the numerical key codes we have chosen as our 
%physical keyboard buttons (the buttons representing the colours R G B Y)
keysOfInterest([RED, GREEN, BLUE, YELLOW])=1;

%Creates a keyboard queue that only responds to the buttons we have defined
%in the 'keysOfInterest' variable
KbQueueCreate(-1, keysOfInterest);

%Initiates the keyboard queue
KbQueueStart; 

%Creates a 'cell' (only way we can store multiple string variables together) 
%that has the text stimuli that we want; this is done using curly
%brackets '{}'
WORDCOLORS = {'RED', 'GREEN', 'BLUE', 'YELLOW'};

%Creates a matrix where each row is a different RGB value
rgbColors = [255 0 0; 0 255 0; 0 0 255; 255 255 0];


%Setting up a 4 Colour and 4 Word Stroop Condition Matrix
%Coded by Alex Tran, PhD, (c) 2018
%Questions? 9trana@gmail.com, a_tran@hotmail.com

%Creates and sorts a repeating 1-4 column vector, 4x with 1 column 
%'STroopWorDs'; this will be needed to set up all permutations of words and
%colours
StWd = sort(repmat([1 2 3 4]',4,1));

%Creates a repeating 1-4 'column' vector, 4x with 1 column
%'STroopCoLours'; this will be combined with the words to create all
%possible combinations of colours and words
StCl = repmat([1 2 3 4]',4,1);

%Horizontal concatenation of the two column vectors we just created
%'FuLlCoNDition' matrix
FlCnd = horzcat(StWd,StCl);

%Creates a k variable that is the total number of rows of the FlCnd matrix
%which should be 16 in our 4 colour, 4 word example (will automaticallly be
%changed if you add more or fewer colours and words to the code above)
[k,~]=size(FlCnd);

%Creates a for-loop that spans the total number of rows and separates the
%congruent from the incongruent stimuli into separate variables, with 0's
%as place holders 'ZeRosCoNGruent' 'ZeRosINCoNGruent'
   for i=1:k
       if FlCnd(i,1) == FlCnd(i,2);
          zrcng(i,:) = FlCnd(i,:);
       else
          zrincng(i,:)= FlCnd(i,:);
       end
   end
   
%Deletes all rows with 0s, creating a 'CONGruent' and 'INCONGruent' matrix
cong = zrcng(any(zrcng,2),:);
incong = zrincng(any(zrincng,2),:);


%% Actual Experiment %%

%Records when the experiment begins
studystarttime=Screen('Flip',nwind);

%Flushes and keyboard presses just in case, but should be none
KbQueueFlush;

%Sets the volume for this experiment for the audio handle 'audhand'
PsychPortAudio('Volume', audhand, 1);

%Draws a fixation cross using our text size specifications on
%initialization on to the screen buffer (not yet shown)
DrawFormattedText(nwind, '+',  'center'  ,'center', black);

%Draws text instructions on to the screen buffer (not yet shown)
Screen('DrawText',nwind,'Please keep your eyes fixed on the central cross the entire time.',fixation(1)-550,fixation(2)-150,black);
Screen('DrawText',nwind,'When you are ready to begin, press any button.',fixation(1)-400,fixation(2)-100,black);

%Anything drawn on the buffer gets 'flipped' on to the screen (every screen
%related drawing function above now gets shown)
Screen('Flip', nwind,[],1);

%Waits for any button to be pressed
KbWait();

%Draws a white rectangle on to the screen buffer (not yet shown)
Screen('FillRect', nwind, [white]);

%Draws a fixation cross on the screen buffer (not yet shown)
DrawFormattedText(nwind, '+',  'center'  ,'center', black);

%Anything drawn on the buffer gets 'flipped' on to the screen (every screen
%related drawing function above now gets shown)
Screen('Flip', nwind,[],1); 

for post_p3atrial=1:180
    
    WaitSecs(.5476);
    post_p3atrial_type =  randi(10);
    if post_p3atrial_type < 3
    wavedata = stl;
    trig = stltrig;
    else
    wavedata = stnd;
    trig = stndtrig;
    end
   
%     
%     IOPort('Write',TPort,uint8(0));
    PsychPortAudio('FillBuffer', audhand, wavedata);  
    PsychPortAudio('Start', audhand, 1, 0, 1);
%     IOPort('Write',TPort,trig);
    
post_p3atrial = post_p3atrial+1;
end

Screen('FillRect', nwind, [white]);
DrawFormattedText(nwind, 'You''ve completed the baseline calibration measure. \n Press any button to continue to the next task.',  'center'  ,'center', black);
Screen('Flip', nwind,[],1); 
KbWait();

Screen('FillRect', nwind, [white]);
DrawFormattedText(nwind, 'For this next task, you will be identifying the colour for different coloured words. \n \n You will be using the ''1'', ''2'', ''3'', ''4'' keys, the keys are Red, Green, Blue and Yellow respectively (R, G, B, Y). \n Press the keys on the keyboard to respond to each prompt. \n You will first perform 12 practice trials and be given feedback for \n each trial then you will perform the main block. \n \n When you are ready to begin, press any button.',  'center'  ,'center', black);
Screen('Flip', nwind,[],1);
WaitSecs(.2);
KbWait();

   
Screen('FillRect', nwind, [white]);
Screen('Flip', nwind,[],1);
WaitSecs(.2);

for trial=1:15
        
        blcong=datasample(cong,12)
        blincong=datasample(incong,24)
        blmat=vertcat(blcong,blincong)
        trial=datasample(blmat,1,'Replace',false)
               
        
        coloroftrial = rgbColors(trial(1,2),:);
        wordoftrial = WORDCOLORS(trial(1,1));
%         IOPort('Write',TPort,uint8(0));
        
        
        Screen('FillRect', nwind, [white]);
        DrawFormattedText(nwind, '+',  'center'  ,'center', black);
        Screen('Flip', nwind,[],1);
        WaitSecs(.5);
        Screen('FillRect', nwind, [white]);
        DrawFormattedText(nwind, wordoftrial{1,1},  'center'  ,'center', coloroftrial);
        starttime=Screen('Flip',nwind);
        WaitSecs(.2);
        Screen('FillRect', nwind, [white]);
        Screen('Flip',nwind);
%         IOPort('Write',TPort,uint8(4));
        endtime=KbQueueWait();
        [keyIsDown,keysecs,keyCode]=KbCheck(-1);
         x=keyCode;
%          IOPort('Write',TPort,uint8(5));
            if endtime-starttime >.8
                 responsecolor=[0 0 0];
            elseif x == keypRED
                 responsecolor=[255 0 0];
            elseif x == keypGREEN
                 responsecolor=[0 255 0];
            elseif x == keypBLUE
                 responsecolor=[0 0 255];
            elseif x == keypYELLOW
                 responsecolor=[255 255 0];
            end
%             IOPort('Write',TPort,uint8(4));
            
            
        if            responsecolor == coloroftrial;
            DrawFormattedText(nwind, 'CORRECT!',  'center'  ,'center', black);
%             IOPort('Write',TPort,CRNtrig);
        elseif responsecolor == [0 0 0]
            DrawFormattedText(nwind, 'TOO SLOW!',  'center'  ,'center', black);
%             IOPort('Write',TPort,FRN);
        else
            DrawFormattedText(nwind, 'INCORRECT!',  'center'  ,'center', black);
%             IOPort('Write',TPort,ERNtrig);       
        end
%         IOPort('Write',TPort,uint8(0));
%         IOPort('Write',TPort,uint8(3));
        WaitSecs(.5);
%         IOPort('Write',TPort,uint8(4));
        vbl=Screen('Flip',nwind); 
        Screen('Flip',nwind,vbl+1); 
end
           
Screen('FillRect', nwind, [white]);
DrawFormattedText(nwind, 'You''ve completed the practice block. You will now begin the main task. \n For the next task you will complete 5 blocks of 24 trials each. \n Press any button to continue.',  'center'  ,'center', black);
Screen('Flip', nwind,[],1); 
KbWait();
Screen('FillRect', nwind, [white]);
Screen('Flip',nwind);
WaitSecs(.2);


block=1
for block=1:3
    WaitSecs(.2);
    Screen('FillRect', nwind, [white]);
    DrawFormattedText(nwind, 'You are about to being a block, press any key to continue.',  'center'  ,'center', black);
    Screen('Flip', nwind,[],1);
    KbWait();
   
    for mtrial=1:36
        
        mcong=datasample(cong,12)
        mincong=datasample(incong,24)
        mmat=vertcat(mcong,mincong)
        mtrial=datasample(mmat,1,'Replace',false)
               
        
        mcoloroftrial = rgbColors(mtrial(1,2),:);
        mwordoftrial = WORDCOLORS(mtrial(1,1));
%         IOPort('Write',TPort,uint8(0));
        
        Screen('FillRect', nwind, [white]);
        Screen('Flip',nwind);        
        WaitSecs(.2);
        Screen('FillRect', nwind, [white]);
        DrawFormattedText(nwind, mwordoftrial{1,1},  'center'  ,'center', mcoloroftrial);
        mstarttime=Screen('Flip',nwind);
        WaitSecs(.2);
        Screen('FillRect', nwind, [white]);
        Screen('Flip',nwind);
        mendtime=KbQueueWait(-1);
        [keyIsDown,msecs,mkeyCode]=KbCheck(-1);
        mx=mkeyCode;
         if    mendtime-mstarttime > .8
                mresponsecolor = [0 0 0]
            elseif mx == keypRED
                 mresponsecolor=[255 0 0];
            elseif mx == keypGREEN
                 mresponsecolor=[0 255 0];
            elseif mx == keypBLUE
                 mresponsecolor=[0 0 255];
            elseif mx == keypYELLOW
                 mresponsecolor=[255 255 0];
            end
        if mresponsecolor == mcoloroftrial
%               IOPort('Write',TPort,CRNtrig);
            elseif mresponsecolor == [0 0 0]
            DrawFormattedText(nwind, 'TOO SLOW!',  'center'  ,'center', black);
            IOPort('Write',TPort,FRN);          
%             else IOPort('Write',TPort,ERNtrig);
        end
        WaitSecs(.5);
        vbl=Screen('Flip',nwind); 
        Screen('Flip',nwind,vbl+1); 
    end
        block=block+1;
        
    Screen('FillRect', nwind, [white]);
    DrawFormattedText(nwind, 'One of your 3 blocks are now completed, press a key to continue',  'center'  ,'center', black);
    Screen('Flip', nwind,[],1);
    KbWait();
end  
         
    WaitSecs(.2);
  


Screen('FillRect', nwind, [white]);
DrawFormattedText(nwind, 'You''ve completed the study. Thank you for your conscientious participation. \n Press any button to continue.',  'center'  ,'center', black);
Screen('Flip', nwind,[],1); 
KbWait();


ListenChar(0); 
ShowCursor(); 
Screen('CloseAll'); 