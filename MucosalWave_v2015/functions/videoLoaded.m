%--- Checks to see if video has been loaded, returns true/false
function bool = videoLoaded(handles)
if (handles.fname == 0)
    errordlg('Load a video first.')
    bool = false;
    return
else
    bool = true;
    return
end