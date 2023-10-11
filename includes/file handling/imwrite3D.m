function imwrite3D(f, filename_out, fmt, silent)
% IMWRITED3D writes a stack of images into a multipage
% Tiff file with a specified filename

if nargin < 3
    f=uint16(f); % sets the array to 16-bit
else
    if isempty(fmt)
        f=uint16(f);
    else
        switch fmt
            case 'uint8'
                f=uint8(f);
            case 'logical'
                f=logical(f);
        end
    end
end

if nargin < 4
    silent = 0;
end

if ~silent
    ticValue = displayTime;
    textprogressbar('      ');
end


z = size(f,3);
slice1=f(:,:,1);
% writes the first slice and creates a Tiff file
imwrite(slice1,filename_out,'Compression','lzw');

if ~silent
    textprogressbar(1);
end

% appends all other slice to the Tiff file
try

    for i = 2:z
        slice=f(:,:,i);

        imwrite(slice,filename_out,'WriteMode','append','Compression','lzw');

        if ~mod(i,10) && ~silent
            textprogressbar(i/z*100);
        end
    end

catch
    if ~silent
        textprogressbar(100);
        textprogressbar(' Failed. \n');
    end

    try
        fprintf('         -> error writing file, trying again');
        for i = 2:z
            slice=f(:,:,i);

            imwrite(slice,filename_out,'WriteMode','append','Compression','lzw');

            if ~mod(i,10)
                textprogressbar(i/z*100);
            end
        end

    catch
        textprogressbar(100);
        textprogressbar(' Failed. \n');

        warning('         -> file could not be written!');
    end

end


if ~silent
    textprogressbar(100);
    textprogressbar(' Done.');
    displayTime(ticValue);
end




