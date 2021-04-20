function popup(app, message, type, options)
    figure = app.UIFigure;
    app.Alert = uiconfirm(figure, message, type, 'Options', options);
end
