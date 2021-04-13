function getEdgesMain(hObject, eventdata, handles, vocalFold)

if ~any(handles.m_wave)
    errordlg('Generate a mucosal wave image first.')
    return;
end

usethreshold = get(handles.usethreshold, 'Value');
if usethreshold & ~any(handles.bw)
    errordlg('Set a suitable threshold first.')
    return;
end

[y,x] = getEdges(handles.m_wave,...
                 handles.bw,...
                 usethreshold,...
                 vocalFold,...
                 handles.mwaveOrder,...
                 handles.ncycles);

if any(y) || any(x)
    edgeNameStr = sprintf('%sEdges',vocalFold);
    handles.(edgeNameStr) = [y,x];
    guidata(hObject, handles);
    edges = getSelectedEdges(handles);
    displayEdges(edges, handles.m_wave, false);
end