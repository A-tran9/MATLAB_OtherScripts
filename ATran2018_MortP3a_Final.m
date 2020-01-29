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
%(check in Device Manager what the identity of the serial port is when 
%connecting the trigger box to confirm)

[TPort]=IOPort('OpenSerialPort','COM1','FlowControl=Hardware(RTS/CTS lines) SendTimeout=1.0 StopBits=1');

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
[nwind, rect]=Screen('OpenWindow',0,white);

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
trig=uint8(0);
blstltrig=uint8(1);
blstndtrig=uint8(2);
mstltrig=uint8(4);
mstndtrig=uint8(5);
resptrig=uint8(9);
congERNtrig=uint8(11);
incongERNtrig=uint8(12);
congCRNtrig=uint8(14);
incongCRNtrig=uint8(15);
slowtrig=uint8(7);

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

p3atrial=1

%ppdata=[blp3atrial#, blp3atrialtype, postp3atrial#, postp3atrialtype,
%prac button pressed, prac colour RGBcode, prac colour text, prac timing, main
%button pressed, main colour RGBcode, main colour text, main timing]
pptdata={0,0,0,0,0,[0 0 0],'colour',0,0,[0 0 0],'colour',0'};

%%EXP%% Baseline P3a Block %%EXP%%

for p3atrial=1:2
    
    p3atrial_type =  randi(10);
    IOPort('Write',TPort,uint8(0));
    if p3atrial_type <= 2
    wavedata = stl;
    trig = blstltrig;
    else
    wavedata = stnd;
    trig = blstndtrig;
    end
    pptdata(p3atrial,1)= {p3atrial};
    pptdata(p3atrial,2)= {p3atrial_type};
    
   
    PsychPortAudio('FillBuffer', audhand, wavedata);
    WaitSecs(.5);
    IOPort('Write',TPort,trig);
    PsychPortAudio('Start', audhand, 1, 0, 1);
    WaitSecs(.01);
    
    
p3atrial = p3atrial+1;
end


Screen('FillRect', nwind, white);
DrawFormattedText(nwind, ['You''ve completed this first baseline calibration measure. \n Next you will ' ...
    'be presented with some questionnaire items. \n Please complete the following questions in the browser.' ...
    '\n Press any button when you are ready to continue.'],  'center'  ,'center', black);
Screen('Flip', nwind,[],1); 
KbWait();

Screen('CloseAll'); 

url='https://psychologyuwaterloo.qualtrics.com/jfe/form/SV_8j1flH7AGd94WmF'
web(url,'-browser');

surveybutton1 = figure('Position',[680 558 200 80], 'numbertitle','off');
set(surveybutton1, 'MenuBar', 'none');
set(surveybutton1, 'ToolBar', 'none');
h = uicontrol('Position', [0 0 200 80], 'String', 'Press here once the survey is complete', ...
'Callback', 'uiresume(gcbf)');
uiwait(gcf);
close(surveybutton1);

[nwind, rect]=Screen('OpenWindow',0);
Screen('TextSize',nwind, 40);
DrawFormattedText(nwind, ['You will now complete a second calibration measure. \n Please keep your eyes fixed on the '...
    'central cross the entire time. \n Press any button when you are ready to continue.'],  'center'  ,'center', black);
Screen('Flip', nwind,[],1); %flip it to the screen
KbWait();

Screen('FillRect', nwind, white);
DrawFormattedText(nwind, '+',  'center'  ,'center', black);
Screen('Flip', nwind,[],0); %flip it to the screen

%%EXP%% Post-Manipulation P3a Block %%EXP%%

post_p3atrial=1


for post_p3atrial=1:2
    
    
    post_p3atrial_type =  randi(10);
    IOPort('Write',TPort,uint8(0));
    if post_p3atrial_type <= 2
    wavedata = stl;
    trig=mstltrig;
    else
    wavedata = stnd;
    trig=mstndtrig;
    end
    
   pptdata(post_p3atrial,3)= {post_p3atrial};
   pptdata(post_p3atrial,4)= {post_p3atrial_type};
    
    PsychPortAudio('FillBuffer', audhand, wavedata);
    WaitSecs(.5);
    IOPort('Write',TPort,trig);
    PsychPortAudio('Start', audhand, 1, 0, 1);
    WaitSecs(.01);

post_p3atrial = post_p3atrial+1;
end

Screen('FillRect', nwind, white);
DrawFormattedText(nwind, ['You''ve completed the second baseline calibration measure. \n Press any button'...
' to continue to the next task.'],  'center'  ,'center', black);
Screen('Flip', nwind,[],1); 
KbWait();

Screen('FillRect', nwind, white);
DrawFormattedText(nwind, 'RED\n  ''1''', [h_center-(h_center/4)], [v_center-25],[255 0 0]);
DrawFormattedText(nwind, 'GREEN\n     ''2''', [h_center-(h_center/8)], [v_center-25],[0 255 0]);
DrawFormattedText(nwind, 'BLUE\n   ''3''', [h_center+(h_center/10)], [v_center-25],[0 0 255]);
DrawFormattedText(nwind, 'YELLOW\n      ''4''', [h_center+(h_center/4)], [v_center-25],[255 255 0]);

DrawFormattedText(nwind, ['For this next task, you will be identifying the colour for different coloured words.'...
    '\n \n You will be using keys on the keyboard which each represent'...
    '\n \n \n \n \n When a word appears you will press the button that '...
    'corresponds to the COLOUR of that word. \n You will first perform 12 practice trials and be given feedback '...
    'for each trial then, \n you will perform the main block with no feedback. \n \n When you are ready to begin, '...
    'press any button.'], 'center'  ,'center', black);
Screen('Flip', nwind,[],1);
WaitSecs(.2);
KbWait();


%%EXP%% Practice Stroop Block %%EXP%%

blcong=datasample(cong,12);
blincong=datasample(incong,24);
blmat=vertcat(blcong,blincong);

for trial=1:2
        
        
        sampbltrial=datasample(blmat,1,'Replace',false);        
        coloroftrial = rgbColors(sampbltrial(1,2),:);
        wordoftrial = WORDCOLORS(sampbltrial(1,1));
        IOPort('Write',TPort,uint8(0));
                
        Screen('FillRect', nwind, white);
        DrawFormattedText(nwind, '+',  'center'  ,'center', black);
        Screen('Flip', nwind,[],1);
        WaitSecs(.5);
        Screen('FillRect', nwind, white);
        DrawFormattedText(nwind, wordoftrial{1,1},  'center'  ,'center', coloroftrial);
        starttime=Screen('Flip',nwind);
        WaitSecs(.2);
        Screen('FillRect', nwind, white);
        Screen('Flip',nwind);
        endtime=KbQueueWait();
        IOPort('Write',TPort,resptrig);
        [keyIsDown,secs,keyCode]=KbCheck(-1);
         x=find(keyCode>0);
         timing=endtime-starttime;
         if timing > .8
             responsecolor=[0 0 0];
         else
            switch x
                case 49
                 responsecolor=[255 0 0];
                case 50
                 responsecolor=[0 255 0];
                case 51
                 responsecolor=[0 0 255];
                case 52
                 responsecolor=[255 255 0];
            end
         end
         
%Evaluates the keyboard response (compares key press to correct response)
%and gives feedback, and sends triggers accordingly (inc or cong trial, ERN
%or CRN, or too slow)

         if responsecolor==[0 0 0];
            DrawFormattedText(nwind, 'TOO SLOW!',  'center'  ,'center', black);
            IOPort('Write',TPort,slowtrig);     
        elseif        responsecolor == coloroftrial & sampbltrial(1,1)~=sampbltrial(1,2);
            DrawFormattedText(nwind, 'CORRECT!',  'center'  ,'center', black);
            IOPort('Write',TPort,incongCRNtrig);       
        elseif        responsecolor == coloroftrial & sampbltrial(1,1)==sampbltrial(1,2);
            DrawFormattedText(nwind, 'CORRECT!',  'center'  ,'center', black);
            IOPort('Write',TPort,congCRNtrig);
         elseif sampbltrial(1,1)==sampbltrial(1,2);
            DrawFormattedText(nwind, 'INCORRECT!',  'center'  ,'center', black);
            IOPort('Write',TPort,congERNtrig);
        elseif  sampbltrial(1,1)~=sampbltrial(1,2);
            DrawFormattedText(nwind, 'INCORRECT!',  'center'  ,'center', black);
            IOPort('Write',TPort,incongERNtrig);
         end
         WaitSecs(.5);
         vbl=Screen('Flip',nwind); 
        Screen('Flip',nwind,vbl+1);
        pptdata(trial,5)={x};
        pptdata(trial,6)={coloroftrial};
        pptdata(trial,7)={wordoftrial};
        pptdata(trial,8)={timing};
end

                      
Screen('FillRect', nwind, white);
DrawFormattedText(nwind, ['You''ve completed the practice block. You will now begin the main task.'...
    '\n For the next task you will complete 5 blocks of 36 trials each. \n Press any button to continue.']...
    ,  'center'  ,'center', black);
Screen('Flip', nwind,[],1); 
KbWait();
Screen('FillRect', nwind, white);
Screen('Flip',nwind);


%%EXP%% Main Stroop Block %%EXP%%

 mcong=datasample(cong,12);
 mincong=datasample(incong,24);
 mmat=vertcat(mcong,mincong);
 
        block =1;
for block=1:1
for mtrial=1:2
        
        
        sampmtrial=datasample(mmat,1,'Replace',false);        
        mcoloroftrial = rgbColors(sampmtrial(1,2),:);
        mwordoftrial = WORDCOLORS(sampmtrial(1,1));
        IOPort('Write',TPort,uint8(0));
                
        Screen('FillRect', nwind, white);
        DrawFormattedText(nwind, '+',  'center'  ,'center', black);
        Screen('Flip', nwind,[],1);
        WaitSecs(.5);
        Screen('FillRect', nwind, white);
        DrawFormattedText(nwind, mwordoftrial{1,1},  'center'  ,'center', mcoloroftrial);
        mstarttime=Screen('Flip',nwind);
        WaitSecs(.2);
        Screen('FillRect', nwind, white);
        Screen('Flip',nwind);
        mendtime=KbQueueWait();
        IOPort('Write',TPort,resptrig);
        [keyIsDown,secs,mkeyCode]=KbCheck(-1);
         mx=find(mkeyCode>0);
         mtiming=mendtime-mstarttime;
         if mtiming > .8
             mresponsecolor=[0 0 0];
         else
            switch x
                case 49
                 mresponsecolor=[255 0 0];
                case 50
                 mresponsecolor=[0 255 0];
                case 51
                 mresponsecolor=[0 0 255];
                case 52
                 mresponsecolor=[255 255 0];
            end
         end
%Evaluates the keyboard response (compares key press to correct response)
%and gives feedback, and sends triggers accordingly (inc or cong trial, ERN
%or CRN, or too slow)
         if mresponsecolor==[0 0 0]           
            DrawFormattedText(nwind, 'TOO SLOW!',  'center'  ,'center', black);
            IOPort('Write',TPort,slowtrig);
         elseif        mresponsecolor == mcoloroftrial & sampmtrial(1,1)==sampmtrial(1,2)            
            IOPort('Write',TPort,congCRNtrig);
         elseif        mresponsecolor == mcoloroftrial & sampmtrial(1,1)~=sampmtrial(1,2)          
            IOPort('Write',TPort,incongCRNtrig);       
         elseif         sampmtrial(1,1)==sampmtrial(1,2)          
            IOPort('Write',TPort,congERNtrig);
         elseif        sampmtrial(1,1)~=sampmtrial(1,2)          
            IOPort('Write',TPort,incongERNtrig);        
         end
         WaitSecs(.5);
         vbl=Screen('Flip',nwind); 
        Screen('Flip',nwind,vbl+1); 
        pptdata(mtrial,9)={mx};
        pptdata(mtrial,10)={mcoloroftrial};
        pptdata(mtrial,11)={mwordoftrial};
        pptdata(mtrial,12)={mtiming};
end
        block = block + 1
end

        
        
Screen('FillRect', nwind, white);
DrawFormattedText(nwind, ['You''ve completed the study. Thank you for your conscientious participation.'...
    '\n Press any button to continue.'],  'center'  ,'center', black);
Screen('Flip', nwind,[],1); 
KbWait();

ListenChar(0); 
ShowCursor(); 
Screen('CloseAll'); 