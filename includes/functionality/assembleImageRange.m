function range = assembleImageRange(array)
if isempty(array)
    range = '';
    return;
end

array = double(array);

if numel(array) == 1
    range = num2str(array);
else
    range = num2str(array(1));
    for i = 2:numel(array)
        if numel(array) > i
            if array(i+1) > array(i)+1 && array(i) == array(i-1)+1
                range = [range, ':', num2str(array(i))];
            end 
            
            if array(i-1)+1 < array(i) && array(i)+1 == array(i+1)
                range = [range, ' ', num2str(array(i))];
            end
            
            if array(i+1) > array(i)+1 && array(i) > array(i-1)+1
                range = [range, ' ', num2str(array(i))];
            end
            
        else
            if array(i) > array(i-1)+1
                range = [range, ' ', num2str(array(i))];
            end
            
            if i == numel(array) && array(i-1)+1 == array(i)
                range = [range, ':', num2str(array(i))];
            end
        end
    end
end