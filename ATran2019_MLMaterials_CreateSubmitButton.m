%%Initializations can be found and explained elsewhere (EquipmentTest.m)%%

white = WhiteIndex(0);
grey = white / 2;
black = BlackIndex(0);
[nwind, rect]=Screen('OpenWindow',0,grey);
Screen('TextSize',nwind, 40);
v_res = rect(4);
h_res = rect(3);
v_center = v_res/2;
h_center = h_res/2;

%%End of Initializations%%


%Defines the dimensions of your button; 1/12 of the horizonal resolution,
%and 1/15 of the vertical resolution

buttonwidth= h_res/12;
buttonheight = v_res/15;

%Defines the margins of the screen; 1/18 from the right and bottom
xmargin = h_res/18;
ymargin = v_res/18;

%Defines the colour of the submit button (subcol) and the confirmation
%colour; i.e., the colour it turns when you selected it (confcol)
subcol = [255 255 255];
confcol = [0 0 255];

%Calculates the upper left co-ordinate of the button
buttonUL=[h_res-(buttonwidth+xmargin)...
v_res-(buttonheight+ymargin)];

%Calculates the lower right co-ordinate of the button
buttonLR =[(h_res-xmargin)...
    (v_res-ymargin)];

%Creates the button matrix
EndButton=[buttonUL buttonLR];

%Draws the button
Screen('FillRect', nwind, subcol, EndButton);
Screen('Flip', nwind);

%Waits for a mouse to click the button; there is a dependency on CogToolBox
%here
answer = Wait4Mouse(EndButton);

%Confirms the answer with a colour change
Screen('FillRect', nwind, confcol, EndButton);
Screen('Flip', nwind,0);
WaitSecs(1);
sca;