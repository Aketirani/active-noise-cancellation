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
    end

    % callbacks that handle component events
    methods (Access = private)
        function runApplication(app, ~)
            % read the state of the checkboxes
            rec_mode = app.RecordModeCheckBox.Value;
            sim_mode = app.SimulateModeCheckBox.Value;
            optpara_mode = app.OptimizeModeCheckBox.Value;
            ns_mode = app.NoiseReductionCheckBox.Value;

            % call the anc function with the mode variables
            anc(rec_mode, sim_mode, optpara_mode, ns_mode);
        end
        function closeApplication(app, ~)
            delete(app);
        end
    end

    % app initialization and construction
    methods (Access = private)
        function createComponents(app)
            % create figure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 450 270];
            app.UIFigure.Name = 'ANC GUI';
            app.UIFigure.Resize = 'off';

            % create text area for displaying information
            app.InfoTextArea = uitextarea(app.UIFigure);
            app.InfoTextArea.Position = [5 220 440 40];
            app.InfoTextArea.Value = {'This application implements various ANC algorithms for active noise cancellation', ...
                'It evaluates their performance through simulations and noisy speech processing'};
            app.InfoTextArea.Editable = false;

            % create checkboxes for modes
            app.RecordModeCheckBox = uicheckbox(app.UIFigure);
            app.RecordModeCheckBox.Text = 'Record Mode';
            app.RecordModeCheckBox.Position = [30 190 100 20];
            app.SimulateModeCheckBox = uicheckbox(app.UIFigure);
            app.SimulateModeCheckBox.Text = 'Simulate Mode';
            app.SimulateModeCheckBox.Position = [30 160 100 20];
            app.OptimizeModeCheckBox = uicheckbox(app.UIFigure);
            app.OptimizeModeCheckBox.Text = 'Optimize Parameters Mode';
            app.OptimizeModeCheckBox.Position = [30 130 200 20];
            app.NoiseReductionCheckBox = uicheckbox(app.UIFigure);
            app.NoiseReductionCheckBox.Text = 'Noise Reduction Mode';
            app.NoiseReductionCheckBox.Position = [30 100 150 20];

            % create run button
            app.RunAppButton = uibutton(app.UIFigure, 'push');
            app.RunAppButton.ButtonPushedFcn = createCallbackFcn(app, @runApplication, true);
            app.RunAppButton.Position = [150 50 150 30];
            app.RunAppButton.Text = 'Run Application';

            % create close button
            app.CloseAppButton = uibutton(app.UIFigure, 'push');
            app.CloseAppButton.ButtonPushedFcn = createCallbackFcn(app, @closeApplication, true);
            app.CloseAppButton.Position = [150 10 150 30];
            app.CloseAppButton.Text = 'Close Application';

            % show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % app creation and deletion
    methods (Access = public)
        function app = gui
            createComponents(app);
        end
        function delete(app)
            delete(app.UIFigure);
        end
    end
end
