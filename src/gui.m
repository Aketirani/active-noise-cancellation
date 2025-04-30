classdef gui < matlab.apps.AppBase
% Graphical User Interface
%
% Properties:
%   - UIFigure               : main figure window
%   - InfoTextArea           : area for displaying information
%   - RecordModeCheckBox     : checkbox for enabling record audio mode
%   - SimulateModeCheckBox   : checkbox for enabling simulate filters mode
%   - OptimizeModeCheckBox   : checkbox for enabling optimize parameters mode
%   - ReductionModeCheckBox  : checkbox for enabling noise reduction mode
%   - RunAppButton           : button for running the application
%   - CloseAppButton         : button for closing the application
%   - MenuBar                : menu bar for accessing different options
%   - Config                 : configuration struct that holds user-defined settings
%   - OutputTextArea         : area for displaying logs and output

    properties (Access = private)
        UIFigure               matlab.ui.Figure
        InfoTextArea           matlab.ui.control.TextArea
        RecordModeCheckBox     matlab.ui.control.CheckBox
        SimulateModeCheckBox   matlab.ui.control.CheckBox
        OptimizeModeCheckBox   matlab.ui.control.CheckBox
        ReductionModeCheckBox matlab.ui.control.CheckBox
        RunAppButton           matlab.ui.control.Button
        CloseAppButton         matlab.ui.control.Button
        MenuBar                matlab.ui.container.Menu
        Config                 struct
        OutputTextArea         matlab.ui.control.TextArea
    end

    methods (Access = private)
        % create new window with content
        function createWindow(~, title, content, position)
            newWindow = uifigure('Name', title, 'Position', position, 'Resize', 'off');
            uitextarea(newWindow, 'Position', [10 10 410 200], 'Value', {content}, 'Editable', false);
            uibutton(newWindow, 'push', 'Position', [180 20 80 30], 'Text', 'Close', ...
                'ButtonPushedFcn', @(btn, event) close(newWindow));
        end

        % update new window position relative to main window
        function position = updatePosition(app, windowHeight, windowWidth)
            mainWindowPos = app.UIFigure.Position;
            position = [mainWindowPos(1) + 10, mainWindowPos(2) + 40, windowWidth, windowHeight];
        end

        % show data descriptions in a new window
        function showDataDescriptions(app)
            content = sprintf(['Filter: The filtering coefficients used in noise cancellation algorithms.\n', ...
                'Noise: The noise signal used for testing noise reduction methods.\n', ...
                'Recording: The captured audio recording for processing in the system.\n', ...
                'Speech: The speech data used in the active noise cancellation algorithms.']);
            position = app.updatePosition(230, 430);
            app.createWindow('Data', content, position);
        end

        % show about information in a new window
        function showAbout(app)
            content = sprintf(['Active Noise Cancellation\n\n' ...
                'Author:\nAria Forsing Ketirani\n\n' ...
                'Description:\nThis project explores the applications of ANC methodology through implementation in MatLab.\n\n' ...
                '© 2024']);
            position = app.updatePosition(230, 430);
            app.createWindow('About', content, position);
        end

        % display images and allow navigation
        function showVisuals(app)
            imagePath = app.Config.plot_path;
            figIndex = 1;
            fig = figure('Name', 'Visuals', 'Position', [100, 100, 600, 600]);
            ax = axes(fig);
            imageFile = app.Config.fig1;
            img = imread(fullfile(imagePath, imageFile));
            imshow(img, 'Parent', ax);

            uicontrol('Style', 'pushbutton', 'String', 'Next', 'Position', [250, 60, 100, 40], ...
                'Callback', @(src, event) showNextImage(src, fig, ax, app, imagePath));
            uicontrol('Style', 'pushbutton', 'String', 'Close', 'Position', [250, 10, 100, 40], ...
                'Callback', @(src, event) closeFigure(src, fig));

            % show next image in sequence
            function showNextImage(~, ~, axHandle, app, imagePath)
                figIndex = mod(figIndex, 6) + 1;
                figName = sprintf('fig%d', figIndex);
                if isfield(app.Config, figName)
                    try
                        img = imread(fullfile(imagePath, app.Config.(figName)));
                        imshow(img, 'Parent', axHandle);
                    catch
                        warning('Failed to load image: %s', figName);
                    end
                end
            end

            % close figure window
            function closeFigure(~, figHandle)
                close(figHandle);
            end
        end

        % run application based on selected modes
        function runApplication(app, ~)
            logMessage(app, 'Running application...');
            try
                anc(app.RecordModeCheckBox.Value, app.SimulateModeCheckBox.Value, app.OptimizeModeCheckBox.Value, app.ReductionModeCheckBox.Value);
                logMessage(app, 'Application completed successfully.');
            catch ME
                logMessage(app, ['Error: ', ME.message]);
            end
        end

        % close the application
        function closeApplication(app, ~)
            delete(app);
        end

        % helper function to create checkboxes
        function checkbox = createCheckBox(app, text, x, y, tooltip)
            checkbox = uicheckbox(app.UIFigure, 'Text', text, 'Position', [x, y, app.UIFigure.Position(3) - 2 * x, 20], 'Tooltip', tooltip);
        end

        % helper function to log messages
        function logMessage(app, message)
            currentLogs = app.OutputTextArea.Value;
            currentLogs{end + 1} = message;
            app.OutputTextArea.Value = currentLogs;
            drawnow;
        end
    end

    methods (Access = private)
        % create all UI components
        function createComponents(app)
            try
                % load configuration
                app.Config = loadconfig('config/config.txt');
                image_fullpath = fullfile(app.Config.image_path, app.Config.image1);
                icon_run = fullfile(app.Config.image_path, app.Config.image2);
                icon_exit = fullfile(app.Config.image_path, app.Config.image3);

                % UIFigure setup
                app.UIFigure = uifigure('Visible', 'off', 'Position', [100 100 450 550], 'Name', 'ANC GUI', 'Resize', 'off');
                padding = 10;
                figureWidth = app.UIFigure.Position(3);
                figureHeight = app.UIFigure.Position(4);
                ax = uiaxes(app.UIFigure, 'Position', [padding, figureHeight - padding - 200, figureWidth, 200]);

                % try loading image
                try
                    img = imread(image_fullpath);
                    imshow(img, 'Parent', ax);
                catch
                    warning('Failed to load image: %s', image_fullpath);
                end

                % info text area
                app.InfoTextArea = uitextarea(app.UIFigure, 'Position', [padding, ax.Position(2) - 2 * padding, figureWidth - 2 * padding, 35], ...
                    'Value', {'This application implements various algorithms for active noise cancellation by', 'evaluating their performance through simulations and noisy speech processing'}, ...
                    'Editable', false, 'BackgroundColor', [1, 1, 0], 'FontName', 'Arial', 'FontSize', 11, 'FontWeight', 'bold');

                % checkboxes for modes with updated tooltips
                app.RecordModeCheckBox = app.createCheckBox('Record audio mode', padding, app.InfoTextArea.Position(2) - padding - 20, ...
                    'Record audio from a connected microphone to capture real-world sound for further processing');
                app.SimulateModeCheckBox = app.createCheckBox('Simulate filters mode', padding, app.RecordModeCheckBox.Position(2) - padding - 20, ...
                    'Simulate the operation of adaptive filters using predefined data to model and test filter behavior');
                app.OptimizeModeCheckBox = app.createCheckBox('Optimize parameters mode', padding, app.SimulateModeCheckBox.Position(2) - padding - 20, ...
                    'Find the best filter parameters to improve filter performance through optimization techniques');
                app.ReductionModeCheckBox = app.createCheckBox('Noise reduction mode', padding, app.OptimizeModeCheckBox.Position(2) - padding - 20, ...
                    'Apply noise reduction algorithms to clean noisy audio signals and improve clarity and quality');

                % output text area
                app.OutputTextArea = uitextarea(app.UIFigure, ...
                    'Position', [padding, app.ReductionModeCheckBox.Position(2) - 110, figureWidth - 2 * padding, 100], 'Editable', false, ...
                    'Value', {'Output logs will appear here.'}, 'BackgroundColor', [1, 1, 1], 'FontName', 'Courier', 'FontSize', 10);

                % run and close buttons
                app.RunAppButton = uibutton(app.UIFigure, 'push', 'Position', [figureWidth/3, app.OutputTextArea.Position(2) - padding - 30, figureWidth - 30 * padding, 30], 'Text', 'Run Application', ...
                    'ButtonPushedFcn', createCallbackFcn(app, @runApplication, true), 'BackgroundColor', [0, 0.5, 0], 'Icon', icon_run, 'FontName', 'Arial', 'FontSize', 11, 'FontWeight', 'bold');
                app.CloseAppButton = uibutton(app.UIFigure, 'push', 'Position', [figureWidth/3, app.RunAppButton.Position(2) - padding - 30, figureWidth - 30 * padding, 30], 'Text', 'Close Application', ...
                    'ButtonPushedFcn', createCallbackFcn(app, @closeApplication, true), 'BackgroundColor', [1, 0, 0], 'Icon', icon_exit, 'FontName', 'Arial', 'FontSize', 11, 'FontWeight', 'bold');

                % menu options
                app.MenuBar = uimenu(app.UIFigure, 'Text', 'Menu');
                uimenu(app.MenuBar, 'Text', 'Data', 'MenuSelectedFcn', @(src, event) app.showDataDescriptions());
                uimenu(app.MenuBar, 'Text', 'Visuals', 'MenuSelectedFcn', @(src, event) app.showVisuals());
                uimenu(app.MenuBar, 'Text', 'About', 'MenuSelectedFcn', @(src, event) app.showAbout());

                % show the UI
                app.UIFigure.Visible = 'on';
            catch ME
                disp('Error creating UI components:');
                disp(ME.message);
            end
        end
    end

    methods (Access = public)
        % constructor for the gui class
        function app = gui
            createComponents(app);
        end

        % destructor for the gui class
        function delete(app)
            delete(app.UIFigure);
        end
    end
end
