function thresholdedImage = applyThreshold(handles)

m_wave = handles.m_wave;

if m_wave == 0
    errordlg('Generate a mucosal wave image before setting threshold.')
    set(hObject, 'Value', 0); % Undo the change the user made
    return
end

thresh = floor(get(handles.threshslider, 'Value'));
set(handles.threshlabel, 'String', thresh);
handles.thresh = thresh;

% newpic will be a binary image created by thresholding
newpic = zeros(size(m_wave));

% Sets the values below the threshhold to be white
newpic(m_wave < thresh) = 1;

if (get(handles.smoothedges,'Value') == 1)
    bw = edge(newpic,'canny',[]);
else
    bw = extractEdgesLQ(newpic);
end

m_wave(find(bw)) = 255;

% Display image using full dynamic range of grayscale values
handles.newpic = newpic;
handles.bw = bw; % initialize edge image
thresholdedImage = m_wave;
guidata(handles.threshslider, handles);