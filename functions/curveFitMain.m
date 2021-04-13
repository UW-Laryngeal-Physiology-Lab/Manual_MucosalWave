function result = curveFitMain(vocalFold, edgePoints, method, order,...
    nCycles, imageSize, units, frameRate, guesses)
% This function controls the curve fitting process.
% Algorithm:
%   1. load muc. wave image, thresholded image, & other data from handles
%   2. Allow user to manually select vocal fold edges in thresholded image
%   3. Compute the curve fit by calling the appropriate function
%   4. Save edge image and 
% Author: Ben Schoepke
% Last modified: 4/2/09

% Allow user to manually select vocal fold edges if desired
% manualMode = get(handles.manualMode, 'Value');

% close(setdiff(allchild(0),gcf)); % close all open figures

% m_wave = handles.m_wave; % the mucosal wave image
% bw = handles.bw; % the black and white image produced by thresholding
% if bw == 0 & ~manualMode
%     errormsg = sprintf('Click Edge Detection button first.\nIf you changed the threshold, click Edge Detection again.');
%     errordlg(errormsg)
%     return
% end

% harmonics = handles.harmonics; % the number of harmonics in the mucosal wave
% ncycles = handles.ncycles; % # of cycles in the mucosal wave
% order = handles.order; % the order of the fitted sin wave
% edgesName = 
% imageSize = size(handles.m_wave);

% % Determine which curve fitting method to use (from GUI controls)
% if (get(handles.LLS,'Value') == 1 )
%     model = {'LLS'};
% elseif (get(handles.Fourier,'Value') == 1)
%     model = {'Fourier'};
% end
% 
% if ~manualMode
% %     edgeImage = getEdges(bw, vocalFold, get(handles.overlap, 'Value'),...
% %         model{1}, harmonics, ncycles);
%     edgeImage = getEdges(bw, vocalFold, model{1}, harmonics, ncycles);
%     if edgeImage == 0, return; end  % Error case
%     [y,x] = find(edgeImage);
% else
%     [y,x] = getEdgePoints(m_wave);
%     if y == 0 | x == 0, return; end % Error case
% end
% 
y = edgePoints(:,1);
x = edgePoints(:,2);

% Do curve fitting
try
    if (strcmp(method, 'Fourier Series'))
        result = mucosalCurveFitFourier(vocalFold, x, y, imageSize, order,...
            nCycles, units, frameRate, guesses);
    elseif (strcmp(method, 'Linear Least Squares'))
        result = mucosalCurveFitLLS(vocalFold, x, y, imageSize, 1,...
            nCycles, units, frameRate);
    end
catch
    % Catch exceptions usually thrown by manually selected edge points
%     close(gcf)  % close the edge selection figure
    s = lasterror;
    errormessage = sprintf('Internal error. MATLAB error message:\n\n%s',s.message);
    errordlg(errormessage); % show error message in dialog box
    return
end

% plot results
% displayFitResults(result, m_wave)

% save results to handles
% resultName = [vocalFold 'result'];
% yxName = ['yx_' vocalFold];
% handles.(resultName) = result;
% handles.(yxName) = [y,x];
% guidata(hObject, handles)