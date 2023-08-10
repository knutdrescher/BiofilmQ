function [free_bytes,total_bytes,usable_bytes] = disk_free( some_path )
%DISK_FREE return free disk space for specified folder in bytes (double)
% INPUT ARGUMENTS:
% * some_path - string, existing file or folder path. Should be global.
% 
% USAGE:
% * disk_free('C:\temp');       % regular usage 
% * disk_free('C:\temp\1.txt'); % path points to a file 
% * disk_free('\\?\C:\temp');   % UNCW path 
% * disk_free('\\\\C:\temp');   % UNCW path with with java-style prefix
% * disk_free('\\IMP\Ctemp');   % samba share folder
% * 
% 
% INVALID USAGE:
% * disk_free('\\IMP');         % samba share root. Results in error.
%
% * disk_free('C');             % Use 'C:' instead. Results in error.
%
% * disk_free('disk_free')      % Matlab function. Results in [0 0 0] 
%                               % or some other result, if corresponding 
%                               % local file was found.
%                               % i.e. don't use local paths! 
% 
% NOTE:
% Would result in an error for an empty DVD-rom drive (disk not inserted).
% And similar cases.
% 
%
% Written by Igor
% i3v@mail.ru
% 23 May 2013
%
% UPDATES:
%  27/02/12:
%    * fixed some terminology
%    * removed 'path' function shadowing
%    * added note about local paths

assert(...
          ischar(some_path) && ndims(some_path)<=2 && size(some_path,1)==1,...
          'disk_free:NotString',...
          '%s','Provided input is not a sting'....
       );

   
exist_code = exist(some_path,'file');
assert(...
          exist_code==2 || exist_code==7 ,...
          'disk_free:BadPath',...
          '%s',['Path "' some_path '" is invalid or does not exist']...
      );
  
% Still, 'some_path' might be a name of local file or matlab function,
% like 'disk_free', or 'disk_free.m' java.io.File won't handle this case.
% 'which' would return empty string for any full normal path.  
% But this doesn't look like perfect solution either....


if length(some_path)>=4 && strcmp(some_path(1:4),'\\?\')
    some_path(1:4)='\\\\';
end

% It's NOT OK to use strrep, since if UNC prefix is not in the beginning 
% of the 'some_path' string, the path is invalid, and it may become 'valid'.
% some_path = strrep(some_path,'\\?\','\\\\');

FileObj = java.io.File(some_path);
free_bytes = FileObj.getFreeSpace;
total_bytes = FileObj.getTotalSpace;
usable_bytes = FileObj.getUsableSpace;


end