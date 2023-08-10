classdef ProgressBar < handle
    %PROGRESSBAR Progress bar class for matlab loops which also works with parfor.
    %   PROGRESSBAR works by creating a file called progressbar_(random_number).txt in
    %   your working directory, and then keeping track of the loop's
    %   progress within that file. This workaround is necessary because parfor
    %   workers cannot communicate with one another so there is no simple way
    %   to know which iterations have finished and which haven't.
    %
    % METHODS:  ProgressBar(num); constructs an object and initializes the progress monitor 
    %                             for a set of N upcoming calculations.
    %           progress(); updates the progress inside your loop and
    %                       displays an updated progress bar.
    %           stop(); deletes progressbar_(random_number).txt and finalizes the 
    %                   progress bar.
    %
    % EXAMPLE: 
    %           N = 100;
    %           p = ProgressBar(N);
    %           parfor i=1:N
    %              pause(rand); % Replace with real code
    %              p.progress; % Also percent = p.progress;
    %           end
    %           p.stop; % Also percent = p.stop;
    %
    % To suppress output call constructor with optional parameter 'verbose':
    %       p = ProgressBar(N,'verbose',0);
    %
    % To get percentage numbers from progress and stop methods call them like:
    %       percent = p.progress;
    %       percent = p.stop;
    %
    % By: Stefan Doerr
    %
    % Based on: parfor_progress written by Jeremy Scheff    

    properties
        fname
        width
        verbose
    end
    
    methods
        function obj = ProgressBar(N, varargin)
            p = inputParser;
            p.addParamValue('verbose',1,@isscalar);
            p.parse(varargin{:});
            obj.verbose = p.Results.verbose;
    
            obj.width = 10; % Width of progress bar
            
            if ~exist(fullfile('.','includes', 'temp'), 'dir')
                mkdir(fullfile('.','includes', 'temp'));
            end

            obj.fname = fullfile('includes', 'temp', ['progressbar_' num2str(randi(10000)) '.txt']);
            while exist(obj.fname,'file')
                obj.fname = fullfile('includes', 'temp', ['progressbar_' num2str(randi(10000)) '.txt']);
            end
            
            f = fopen(obj.fname, 'w');
            if f<0
                error('Do you have write permissions for %s?', pwd);
            end
            fprintf(f, '%d\n', N); % Save N at the top of progress.txt
            fclose(f);

            if obj.verbose
                disp(['           0%    [', repmat(' ', 1, obj.width+1), ']'])
            end
        end
        
        function percent = progress(obj)
            if ~exist(obj.fname, 'file')
                error([obj.fname ' not found. It must have been deleted.']);
            end

            f = fopen(obj.fname, 'a');
            fprintf(f, '1\n');
            fclose(f);

            f = fopen(obj.fname, 'r');
            progress = fscanf(f, '%d');
            fclose(f);
            percent = (length(progress)-1)/progress(1)*100;

            if obj.verbose
                perc = sprintf('%3.0f%%', percent); % 4 characters wide, percentage
                disp([repmat(char(8), 1, (obj.width+18)), '      ',  perc, '    [', repmat('.', 1, round(percent*obj.width/100)), '.', repmat(' ', 1, obj.width - round(percent*obj.width/100)), ']']);
            end           
        end
        
        function percent = stop(obj)
            delete(obj.fname);     
            percent = 100;

            if obj.verbose
                disp([repmat(char(8), 1, (obj.width+18)), '      100%    [', repmat('.', 1, obj.width+1), '] Done.']);
            end
        end
    end
end
