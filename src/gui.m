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

    % properties that correspond to app components
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
    end

    % callback methods
    methods (Access = private)
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

        % callback to show descriptions of all data in a new pop-up window
        function showDataDescriptions(app)
            % create the description content
            descriptions = sprintf(['Filter: The filtering coefficients used in noise cancellation algorithms.\n', ...
                'Noise: The noise signal used for testing noise reduction methods.\n', ...
                'Recording: The captured audio recording for processing in the system.\n', ...
                'Speech: The speech data used in the active noise cancellation algorithms.']);

            % create a new window to display the descriptions
            descriptionWindow = uifigure('Name', 'Data', 'Position', [10 40 430 230]);
            descriptionWindow.Resize = 'off';

            % add a TextArea in the new window to display descriptions
            descriptionTextArea = uitextarea(descriptionWindow);
            descriptionTextArea.Position = [10 10 410 200];
            descriptionTextArea.Value = {descriptions};
            descriptionTextArea.Editable = false;

            % add a close button
            closeButton = uibutton(descriptionWindow, 'push');
            closeButton.Position = [180 20 80 30];
            closeButton.Text = 'Close';
            closeButton.ButtonPushedFcn = @(btn, event) close(descriptionWindow);
        end

        % callback to show the about message
        function showAbout(app)
            % create the about content
            aboutContent = sprintf(['Active Noise Cancellation\n\n' ...
                'Author:\nAria Forsing Ketirani\n\n' ...
                'Description:\nThis project focuses on exploring the potential applications of the ANC methodology through the implementation of ANC systems in MatLab.\n\n' ...
                '© 2024']);

            % create a new window to display the about information
            aboutWindow = uifigure('Name', 'About', 'Position', [10 40 430 230]);
            aboutWindow.Resize = 'off';

            % add a TextArea in the new window to display the about content
            aboutTextArea = uitextarea(aboutWindow);
            aboutTextArea.Position = [10 10 410 200];
            aboutTextArea.Value = {aboutContent};
            aboutTextArea.Editable = false;

            % add a close button
            closeButton = uibutton(aboutWindow, 'push');
            closeButton.Position = [180 20 80 30];
            closeButton.Text = 'Close';
            closeButton.ButtonPushedFcn = @(btn, event) close(aboutWindow);
        end

        % callback to show all available visuals in a new pop-up window
        function showVisuals(app)
            % create the visuals content
            visualsList = sprintf(['Noisy Speech Comparisons\n', ...
                'Noisy Speech Convergence\n', ...
                'Noisy Speech Performance\n', ...
                'Optimal Parameters\n', ...
                'Simulation Convergence\n', ...
                'Simulation Performance']);

            % create a new window to display the visuals list
            visualsWindow = uifigure('Name', 'Visuals', 'Position', [10 40 430 230]);
            visualsWindow.Resize = 'off';

            % add a TextArea in the new window to display visuals list
            visualsTextArea = uitextarea(visualsWindow);
            visualsTextArea.Position = [10 10 410 200];
            visualsTextArea.Value = {visualsList};
            visualsTextArea.Editable = false;

            % add a close button
            closeButton = uibutton(visualsWindow, 'push');
            closeButton.Position = [180 20 80 30];
            closeButton.Text = 'Close';
            closeButton.ButtonPushedFcn = @(btn, event) close(visualsWindow);
        end
    end

    % method to create GUI components
    methods (Access = private)
        function createComponents(app)
            try
                % read config
                c = loadconfig('config/config.txt');

                % construct image path
                image_fullpath = fullfile(c.image_path, c.image1);

                % create figure
                app.UIFigure = uifigure('Visible', 'off');
                app.UIFigure.Position = [100 100 450 480];
                app.UIFigure.Name = 'ANC GUI';
                app.UIFigure.Resize = 'off';

                % padding
                padding = 10;

                % calculate dynamic positions
                figureWidth = app.UIFigure.Position(3);
                figureHeight = app.UIFigure.Position(4);

                % image
                imageHeight = 200;
                ax = uiaxes(app.UIFigure);
                ax.Position = [padding, figureHeight - padding*2 - imageHeight, ...
                    figureWidth, imageHeight];
                try
                    img = imread(image_fullpath);
                    imshow(img, 'Parent', ax);
                catch
                    warning('Failed to load image: %s', image_fullpath);
                end

                % text area
                textHeight = 35;
                app.InfoTextArea = uitextarea(app.UIFigure);
                app.InfoTextArea.Position = [padding, ax.Position(2) - padding - textHeight, ...
                    figureWidth - 2 * padding, textHeight];
                app.InfoTextArea.Value = {'This application implements various algorithms for active noise cancellation by', ...
                    'evaluating their performance through simulations and noisy speech processing'};
                app.InfoTextArea.Editable = false;

                % checkboxes
                checkboxHeight = 20;
                app.RecordModeCheckBox = uicheckbox(app.UIFigure);
                app.RecordModeCheckBox.Text = 'Record Mode';
                app.RecordModeCheckBox.Position = [padding, app.InfoTextArea.Position(2) - padding - checkboxHeight, ...
                    figureWidth - 2 * padding, checkboxHeight];

                app.SimulateModeCheckBox = uicheckbox(app.UIFigure);
                app.SimulateModeCheckBox.Text = 'Simulate Mode';
                app.SimulateModeCheckBox.Position = [padding, app.RecordModeCheckBox.Position(2) - padding - checkboxHeight, ...
                    figureWidth - 2 * padding, checkboxHeight];

                app.OptimizeModeCheckBox = uicheckbox(app.UIFigure);
                app.OptimizeModeCheckBox.Text = 'Optimize Parameters Mode';
                app.OptimizeModeCheckBox.Position = [padding, app.SimulateModeCheckBox.Position(2) - padding - checkboxHeight, ...
                    figureWidth - 2 * padding, checkboxHeight];

                app.NoiseReductionCheckBox = uicheckbox(app.UIFigure);
                app.NoiseReductionCheckBox.Text = 'Noise Reduction Mode';
                app.NoiseReductionCheckBox.Position = [padding, app.OptimizeModeCheckBox.Position(2) - padding - checkboxHeight, ...
                    figureWidth - 2 * padding, checkboxHeight];

                % run button
                buttonHeight = 30;
                app.RunAppButton = uibutton(app.UIFigure, 'push');
                app.RunAppButton.ButtonPushedFcn = createCallbackFcn(app, @runApplication, true);
                app.RunAppButton.Position = [padding, app.NoiseReductionCheckBox.Position(2) - padding - buttonHeight, ...
                    figureWidth - 2 * padding, buttonHeight];
                app.RunAppButton.Text = 'Run Application';

                % close button
                app.CloseAppButton = uibutton(app.UIFigure, 'push');
                app.CloseAppButton.ButtonPushedFcn = createCallbackFcn(app, @closeApplication, true);
                app.CloseAppButton.Position = [padding, app.RunAppButton.Position(2) - padding - buttonHeight, ...
                    figureWidth - 2 * padding, buttonHeight];
                app.CloseAppButton.Text = 'Close Application';

                % create menu bars
                app.MenuBar = uimenu(app.UIFigure, 'Text', 'Menu');
                uimenu(app.MenuBar, 'Text', 'Data', 'MenuSelectedFcn', @(src, event) app.showDataDescriptions());
                uimenu(app.MenuBar, 'Text', 'Visuals', 'MenuSelectedFcn', @(src, event) app.showVisuals());
                uimenu(app.MenuBar, 'Text', 'About', 'MenuSelectedFcn', @(src, event) app.showAbout());

                % show figure
                app.UIFigure.Visible = 'on';
            catch ME
                disp('Error creating UI components:');
                disp(ME.message);
            end
        end
    end

    % constructor and destructor
    methods (Access = public)
        function app = gui
            createComponents(app);
        end

        function delete(app)
            delete(app.UIFigure);
        end
    end
end
