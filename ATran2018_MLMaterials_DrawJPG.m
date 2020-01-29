[wind,rect]=Screen('OpenWindow',0)
test=imread('cards.jpg.')
Screen('PutImage', wind, test, rect)
Screen('Flip', wind,[],0)
WaitSecs(2);
eeglab;
sca;