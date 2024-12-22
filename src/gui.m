classdef gui < matlab.apps.AppBase
% Graphical User Interface
%
% Properties:
%   - UIFigure               : main figure window
%   - InfoTextArea           : area for displaying information
%   - RecordModeCheckBox     : checkbox for enabling record mode
%   - SimulateModeCheckBox   : checkbox for enabling simulate mode
%   - OptimizeModeCheckBox   : checkbox for enabling optimize parameters mode
%   - NoiseReductionCheckBox : checkbox for enabling noise reduction mode
%   - RunAppButton           : button for running the application
%   - CloseAppButton         : button for closing the application
%   - MenuBar                : menu bar for accessing different options
%   - Config                 : configuration struct that holds user-defined settings

    properties (Access = private)
        UIFigure               matlab.ui.Figure
        InfoTextArea           matlab.ui.control.TextArea
        RecordModeCheckBox     matlab.ui.control.CheckBox
        SimulateModeCheckBox   matlab.ui.control.CheckBox
        OptimizeModeCheckBox   matlab.ui.control.CheckBox
        NoiseReductionCheckBox matlab.ui.control.CheckBox
        RunAppButton           matlab.ui.control.Button
        CloseAppButton         matlab.ui.control.Button
        MenuBar                matlab.ui.container.Menu
        Config                 struct
    end

    methods (Access = private)
        function createWindow(app, title, content, position)
            % Helper to create new windows with content
            newWindow = uifigure('Name', title, 'Position', position);
            newWindow.Resize = 'off';

            % Create text area for content
            textArea = uitextarea(newWindow);
            textArea.Position = [10 10 410 200];
            textArea.Value = {content};
            textArea.Editable = false;

            % Close button
            closeButton = uibutton(newWindow, 'push');
            closeButton.Position = [180 20 80 30];
            closeButton.Text = 'Close';
            closeButton.ButtonPushedFcn = @(btn, event) close(newWindow);
        end

        function position = updatePosition(app, windowHeight, windowWidth)
            % Update new window position relative to main window
            mainWindowPos = app.UIFigure.Position;
            position = [mainWindowPos(1) + 10, mainWindowPos(2) + 40, windowWidth, windowHeight];
        end

        function showDataDescriptions(app)
            content = sprintf(['Filter: The filtering coefficients used in noise cancellation algorithms.\n', ...
                'Noise: The noise signal used for testing noise reduction methods.\n', ...
                'Recording: The captured audio recording for processing in the system.\n', ...
                'Speech: The speech data used in the active noise cancellation algorithms.']);
            position = app.updatePosition(230, 430);
            app.createWindow('Data', content, position);
        end

        function showAbout(app)
            content = sprintf(['Active Noise Cancellation\n\n' ...
                'Author:\nAria Forsing Ketirani\n\n' ...
                'Description:\nThis project explores the applications of ANC methodology through implementation in MatLab.\n\n' ...
                '© 2024']);
            position = app.updatePosition(230, 430);
            app.createWindow('About', content, position);
        end

        function showVisuals(app)
            content = sprintf(['Noisy Speech Comparisons\n', ...
                'Noisy Speech Convergence\n', ...
                'Noisy Speech Performance\n', ...
                'Optimal Parameters\n', ...
                'Simulation Convergence\n', ...
                'Simulation Performance']);
            position = app.updatePosition(230, 430);
            app.createWindow('Visuals', content, position);
        end

        function runApplication(app, ~)
            rec_mode = app.RecordModeCheckBox.Value;
            sim_mode = app.SimulateModeCheckBox.Value;
            optpara_mode = app.OptimizeModeCheckBox.Value;
            ns_mode = app.NoiseReductionCheckBox.Value;
            anc(rec_mode, sim_mode, optpara_mode, ns_mode);
        end

        function closeApplication(app, ~)
            delete(app);
        end
    end

    methods (Access = private)
        function createComponents(app)
            try
                % Read config from file (use flexible config)
                app.Config = loadconfig('config/config.txt');
                image_fullpath = fullfile(app.Config.image_path, app.Config.image1);

                % Create main figure window
                app.UIFigure = uifigure('Visible', 'off');
                app.UIFigure.Position = [100 100 450 480];
                app.UIFigure.Name = 'ANC GUI';
                app.UIFigure.Resize = 'off';

                padding = 10;
                figureWidth = app.UIFigure.Position(3);
                figureHeight = app.UIFigure.Position(4);

                % Image
                ax = uiaxes(app.UIFigure);
                ax.Position = [padding, figureHeight - padding*2 - 200, figureWidth, 200];
                try
                    img = imread(image_fullpath);
                    imshow(img, 'Parent', ax);
                catch
                    warning('Failed to load image: %s', image_fullpath);
                end

                % Info text area
                app.InfoTextArea = uitextarea(app.UIFigure);
                app.InfoTextArea.Position = [padding, ax.Position(2) - padding - 35, figureWidth - 2 * padding, 35];
                app.InfoTextArea.Value = {'This application implements various algorithms for active noise cancellation by', ...
                    'evaluating their performance through simulations and noisy speech processing'};
                app.InfoTextArea.Editable = false;

                % Checkboxes with generalized creation
                app.RecordModeCheckBox = app.createCheckBox('Record Mode', padding, app.InfoTextArea.Position(2) - padding - 20);
                app.SimulateModeCheckBox = app.createCheckBox('Simulate Mode', padding, app.RecordModeCheckBox.Position(2) - padding - 20);
                app.OptimizeModeCheckBox = app.createCheckBox('Optimize Parameters Mode', padding, app.SimulateModeCheckBox.Position(2) - padding - 20);
                app.NoiseReductionCheckBox = app.createCheckBox('Noise Reduction Mode', padding, app.OptimizeModeCheckBox.Position(2) - padding - 20);

                % Buttons
                app.RunAppButton = uibutton(app.UIFigure, 'push');
                app.RunAppButton.ButtonPushedFcn = createCallbackFcn(app, @runApplication, true);
                app.RunAppButton.Position = [padding, app.NoiseReductionCheckBox.Position(2) - padding - 30, figureWidth - 2 * padding, 30];
                app.RunAppButton.Text = 'Run Application';

                app.CloseAppButton = uibutton(app.UIFigure, 'push');
                app.CloseAppButton.ButtonPushedFcn = createCallbackFcn(app, @closeApplication, true);
                app.CloseAppButton.Position = [padding, app.RunAppButton.Position(2) - padding - 30, figureWidth - 2 * padding, 30];
                app.CloseAppButton.Text = 'Close Application';

                % Menu Bar
                app.MenuBar = uimenu(app.UIFigure, 'Text', 'Menu');
                uimenu(app.MenuBar, 'Text', 'Data', 'MenuSelectedFcn', @(src, event) app.showDataDescriptions());
                uimenu(app.MenuBar, 'Text', 'Visuals', 'MenuSelectedFcn', @(src, event) app.showVisuals());
                uimenu(app.MenuBar, 'Text', 'About', 'MenuSelectedFcn', @(src, event) app.showAbout());

                % Show the UI
                app.UIFigure.Visible = 'on';
            catch ME
                disp('Error creating UI components:');
                disp(ME.message);
            end
        end

        function checkbox = createCheckBox(app, text, x, y)
            checkbox = uicheckbox(app.UIFigure);
            checkbox.Text = text;
            checkbox.Position = [x, y, app.UIFigure.Position(3) - 2 * x, 20];
        end
    end

    methods (Access = public)
        function app = gui
            createComponents(app);
        end

        function delete(app)
            delete(app.UIFigure);
        end
    end
end
