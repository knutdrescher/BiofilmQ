function showErrorMessage(msg, showPopup)

if nargin == 1
    showPopup = true;
end

if showPopup
    uiwait(msgbox(msg, 'Error', 'error', 'modal'));
else
    warning('backtrace', 'off');
    warning(msg);
    warning('backtrace', 'on');
end

return