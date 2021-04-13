function setPanelState(uipanel, enable)
% Sets the enable property for all children of a uipanel.
% Inputs:
%   uipanel: the parent uipanel object
%   enable: the enable property of the uipanel: on, off, or inactive
% Author: Ben Schoepke

if nargin < 2, return; end
if ~strcmp(enable, 'on') && ...
        ~strcmp(enable, 'off') && ...
        ~strcmp(enable, 'inactive')
    return;
else
    children = get(uipanel, 'Children'); % all children of uipanel
    set(children, 'Enable', enable);
end