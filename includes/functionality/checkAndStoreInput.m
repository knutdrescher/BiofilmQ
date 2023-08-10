function handles = checkAndStoreInput(handles, hObject, varargin)

%% Handle inputs
p = inputParser;

addRequired(p,'handles');
addRequired(p,'hObject');
addParameter(p,'inputType', 'numeric');
addParameter(p,'condition', []);
addParameter(p,'range', [-1e99 1e99]);
addParameter(p,'file', []);

parse(p, handles, hObject, varargin{:});

inputType = p.Results.inputType;
condition = p.Results.condition;
range = p.Results.range;
file = p.Results.file;

switch inputType
    
    case 'numeric'
        currentValue = str2num(get(hObject, 'String'));
        if numel(currentValue) > 1
            uiwait(msgbox(sprintf('Input of "%s" has to be a scalar value.', hObject.Tag), 'Please note', 'help', 'modal'));
            currentValue = currentValue(1);
        end
        set(hObject, 'String', num2str(currentValue));
        if isempty(currentValue)
            uiwait(msgbox(sprintf('Input of "%s" has to be numerical.', hObject.Tag), 'Please note', 'help', 'modal'));
            set(hObject, 'String', '');
        end
        
        if ~isempty(condition)
            switch condition
                case 'odd'
                    if ~mod(currentValue, 2)
                        uiwait(msgbox(sprintf('Input of "%s" has to be an odd number.', hObject.Tag), 'Please note', 'help', 'modal'));
                        currentValue = currentValue + 1;
                        set(hObject, 'String', num2str(currentValue));
                    end
                    
                case 'integer'
                    currentValue = round(currentValue);
                    set(hObject, 'String', num2str(currentValue));
                    
                otherwise
                    
            end
        end
        
        if ~isempty(range)
            if currentValue < range(1)
                uiwait(msgbox(sprintf('Input of "%s" has to be larger than %g.', hObject.Tag, range(1)), 'Please note', 'help', 'modal'));
                set(hObject, 'String', num2str(range(1)));
            end
            
            if currentValue > range(2)
                uiwait(msgbox(sprintf('Input of "%s" has to be smaller than %g.', hObject.Tag, range(2)), 'Please note', 'help', 'modal'));
                set(hObject, 'String', num2str(range(2)));
            end
        end
        
    case 'array'
        switch condition
            case 'cropping'
                currentValue = str2num(get(hObject, 'String'));
                if numel(currentValue) ~= 4 && ~isempty(get(hObject, 'String'))
                    uiwait(msgbox(sprintf('Input of "%s" has to contain 4 entries [x_start, y_start, height, width].', hObject.Tag), 'Please note', 'help', 'modal'));
                    currentValue = [];
                end
                set(hObject, 'String', num2str(currentValue));
                
            case 'odd'
                currentValue = str2num(get(hObject, 'String'));
                if numel(currentValue) ~= 2 || mod(sum(currentValue), 2)
                    uiwait(msgbox(sprintf('Input of "%s" has to contain 2 odd numbers.', hObject.Tag), 'Please note', 'help', 'modal'));
                    currentValue = [5 3];
                end
                if ~isempty(range)
                    if currentValue(1) < range(1) || currentValue(2) < range(1)
                        uiwait(msgbox(sprintf('Input of "%s" has to be larger than %g.', hObject.Tag, range(1)), 'Please note', 'help', 'modal'));
                        currentValue = [5 3];
                    end
                    
                    if currentValue(1) > range(2) || currentValue(2) > range(2)
                        uiwait(msgbox(sprintf('Input of "%s" has to be smaller than %g.', hObject.Tag, range(2)), 'Please note', 'help', 'modal'));
                        currentValue = [5 3];
                    end
                end
                set(hObject, 'String', num2str(currentValue));
            otherwise
        end
    otherwise
        
end

if ~isempty(file)
    handles = storeValues(hObject, [], handles, file);
else
    handles = storeValues(hObject, [], handles);
end
