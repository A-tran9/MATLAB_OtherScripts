clear all

close all

KbName('UnifyKeyNames');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%

white = WhiteIndex(0);
grey = white / 2;
black = BlackIndex(0);
InitializePsychSound;
[stndy, ~] = psychwavread('standard.wav');
[stly, freq] = psychwavread('startp3a1.wav');
stnd=stndy';
stl=stly';
pahandle = PsychPortAudio('Open', [], [], 0, freq, 2);

[window, rect]=Screen('OpenWindow',0);
[keyIsDown,secs,keyCode]=KbCheck;

RED=KbName('1!'); GREEN=KbName('2@'); BLUE=KbName('3#'); YELLOW=KbName('4$');

    keypRED = zeros(1,256);
    keypRED ([RED]) = 1;
    keypGREEN = zeros(1,256);
    keypGREEN ([GREEN]) = 1;
    keypBLUE = zeros(1,256);
    keypBLUE ([BLUE])=1;
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

PsychPortAudio('Volume', pahandle, 0.5);

Screen('DrawLines',window, [-7 7 0 0; 0 0 -7 7], 1, white, [h_center,v_center],0);  %Print the fixation,
Screen('DrawText',window,'Please keep your eyes fixed on the central cross the entire time. When you are ready to begin, press any button.',fixation(1)-600,fixation(2)-100,white);  %Display instructions
Screen('Flip', window,[],0); %flip it to the screen
WaitSecs(1)
p3atrial=1

for p3atrial=1:10
    wavedata = 
    
PsychPortAudio('FillBuffer', pahandle, wavedata);

PsychPortAudio('Start', pahandle, 1, 0, 1);
p3atrial = p3atrial+1;
end

for phase = 1

    design=repmat([1 2 3 4], 2)';
    if phase == 1
        designRand=Shuffle(design);
        Word=WORDCOLORS(designRand(1:8));
        Color=rgbColors(designRand(:,2),:);
        
    end
    for trial=1:8
        coloroftrial = Color(trial,:);
        if phase == 1
        DrawFormattedText(window, Word{trial},  'center'  ,'center', coloroftrial);
        WaitSecs(rand+.5) 
        starttime=Screen('Flip',window); 
        endtime=KbQueueWait();
        [keyIsDown,secs,keyCode]=KbCheck(-1);
        x=keyCode;
            if x == keypRED
                responsecolor=[255 0 0];
            elseif x == keypGREEN
                 responsecolor=[0 255 0];
            elseif x == keypBLUE
                 responsecolor=[0 0 255];
            elseif x == keypYELLOW
                 responsecolor=[255 255 0]; 
            end
        if responsecolor == coloroftrial
            DrawFormattedText(window, 'CORRECT!',  'center'  ,'center', black);
        else DrawFormattedText(window, 'INCORRECT!',  'center'  ,'center', black);
            
        end
        
        vbl=Screen('Flip',window); 
        Screen('Flip',window,vbl+1); 
        end
         
            end
end

pahandle = PsychPortAudio('Open', [], [], 0, freq, nrchannels);


ListenChar(0); 
ShowCursor(); 
Screen('CloseAll'); 