 h = uibuttongroup('visible','on','Position',[0 0 .2 1]);
        u0 = uicontrol('Style','Radio','String','Option 1',...
             'pos',[10 350 100 30],'parent',h,'HandleVisibility','off');
        u1 = uicontrol('Style','Radio','String','Option 2',...
             'pos',[10 250 100 30],'parent',h,'HandleVisibility','off');
        u2 = uicontrol('Style','Radio','String','Option 3',...
             'pos',[10 150 100 30],'parent',h,'HandleVisibility','off');
        h.SelectionChangeFcn = 'disp selectionChanged';
        h.SelectedObject = [];  % No selection
        h.Visible = 'on';