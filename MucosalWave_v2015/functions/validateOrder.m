function order = validateOrder(orderEditHandle, MAX_ORDER)

order = floor(str2double(get(orderEditHandle, 'String')));
DEFAULT_ORDER = 1;

% Check for invalid values
if order > MAX_ORDER
    order = MAX_ORDER;
    set(orderEditHandle, 'String', MAX_ORDER);
elseif order < 0
    order = DEFAULT_ORDER;
    set(orderEditHandle, 'String', DEFAULT_ORDER);
elseif isnan(order) % case where edit box has non-numeric characters
    order = DEFAULT_ORDER;
    set(orderEditHandle, 'String', DEFAULT_ORDER);
end