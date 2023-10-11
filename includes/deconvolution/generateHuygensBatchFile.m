function fileName = generateHuygensBatchFile(files, output_dir, params)

objectiveTemplate = params.huygens_objTemplate;
% microscopeTemplate = params.huygens_micrTemplate;
deconvolutionTemplate = params.huygens_deconTemplate;
wavelengths = params.huygens_wavelengths;
qualityThreshold = params.huygens_qualityThreshold;
Niterations = params.huygens_Niterations;
SNR = params.huygens_SNR;

switch objectiveTemplate
    case 1
        objNA = '1.35';
        immersMedNA = '1.406';
        microscopeTemplate = 'drescher_100x_SiOil_2xlens';
    case 2
        objNA = '1.45';
        immersMedNA = '1.51';
        microscopeTemplate = 'drescher_100x_Oil_2xlens';
end

%Batchfile
batchFile = [];
batchFile{1} = '# Huygens Batch processing template file';
batchFile{2} = '# Format: nested Tcl-style list';
batchFile{3} = ['# Saved: ' datestr(clock, 'ddd mmm dd HH:MM:SS +0200 yyyy')];
batchFile{4} = ['info {title {Batch processing template} version 2.5 templateName batch_',datestr(clock, 'yyyy-mm-dd_HH-MM-SS'),' date {',datestr(clock, 'ddd mmm dd HH:MM:SS +0200 yyyy'),'}}'];
batchFile{5} = 'taskList {setEnv ';

fileCounter = 0;
for i=0:numel(files)-1
    if exist(fullfile(output_dir, [files(i+1).name(1:end-4), '_cmle.tif']), 'file')
        continue;
    end
    batchFile{5} = [batchFile{5}, 'taskID:' num2str(fileCounter), ' '];
    fileCounter = fileCounter + 1;
end

batchFile{5} = [batchFile{5},' }'];
batchFile{6} = ['setEnv {resultDir {',strrep(output_dir, '\', '/'),'} perJobThreadCnt auto concurrentJobCnt 2 exportFormat {type tiff16 multidir 1 cmode clip} inputConversion int timeOut 10000}'];

pause(1)
fileCounter = 0;

for i=0:numel(files)-1
    if exist(fullfile(output_dir, [files(i+1).name(1:end-4), '_cmle.tif']), 'file')
        fprintf('    - file "%s" is already deconvolved\n', fullfile(output_dir, files(i+1).name));
        continue;
    end
    
    % Retrieve fluorescence channel
    if ~isempty(strfind(files(i+1).name, 'ch1'))
        ch = 1;
        
    elseif ~isempty(strfind(files(i+1).name, 'ch2'))
        ch = 2;
        
    elseif ~isempty(strfind(files(i+1).name, 'ch3'))
        ch = 3;
        
    else %ypet
        ch = 1;
    end
    
    ex = num2str(wavelengths{ch,1});
    em = num2str(wavelengths{ch,2});
        
    % Get metadata
    metadata = load(fullfile(files(i+1).folder, ['..', filesep], [files(i+1).name(1:end-4), '_metadata.mat']));
    
    batchFile{7+i} = ['taskID:',num2str(fileCounter),' {info {state readyToRun tag {setp ',microscopeTemplate,' decon ',deconvolutionTemplate,'} timeStartAbs 1537191124 timeOut 320000} taskList {imgOpen setp hotPix cmle:0 imgSave} imgOpen {path {',[strrep(files(i+1).folder, '\', '/'),'/',files(i+1).name], '} series auto index 0} imgSave {rootName {',files(i+1).name,'}} setp {s { ',num2str(metadata.data.scaling.dxy),' ',num2str(metadata.data.scaling.dxy),' ',num2str(metadata.data.scaling.dz),' 1.0000} parState,s verified dx ',num2str(metadata.data.scaling.dxy*1000),' parState,dx verified dy ',num2str(metadata.data.scaling.dxy*1000),' parState,dy verified dz ',num2str(metadata.data.scaling.dz*1000),' parState,dz verified dt 1.0000 parState,dt verified iFacePrim 0.0 parState,iFacePrim verified iFaceScnd 0.0 parState,iFaceScnd verified micr {nipkow} parState,micr {verified} na {',objNA,'} parState,na {verified} objQuality {perfect} parState,objQuality verified ri {1.338} parState,ri verified ril {',immersMedNA,'} parState,ril verified ps {5} parState,ps verified pr {250} parState,pr verified ex {',ex,'} parState,ex verified em {',em,'} parState,em verified pcnt {1} parState,pcnt verified ppu {1.0} parState,ppu verified baseline {0.0} parState,baseline verified lineAvgCnt {1} parState,lineAvgCnt verified exBeamFill {2.0} parState,exBeamFill verified imagingDir {upward} parState,imagingDir verified stedMode {vortexPulsed} parState,stedMode verified stedSatFact {40} parState,stedSatFact verified stedLambda {676} parState,stedLambda verified stedImmunity {10} parState,stedImmunity verified stedCoeff {{2.1 8.0 0.01 2.1 8.0 0.01}} parState,stedCoeff verified sted3D {0} parState,sted3D verified spimExc {gauss} parState,spimExc verified spimNA {0.03} parState,spimNA verified spimFill {0.5} parState,spimFill verified spimGaussWidth {4.0} parState,spimGaussWidth verified spimCenterOff {0} parState,spimCenterOff verified spimFocusOff {0} parState,spimFocusOff verified spimDir {0} parState,spimDir verified scatterModel {exp} parState,scatterModel verified scatterFreePath {100.0} parState,scatterFreePath verified scatterRelContrib {50} parState,scatterRelContrib verified scatterBlurring {0.0} parState,scatterBlurring verified allVerified 1 userDefConfidence noMetaData} hotPix {hotPath {}} stabilize {enabled 1} cmle:0 {psfMode auto psfPath {} psfChan {} mode fast it ',num2str(Niterations),' q ',num2str(qualityThreshold),' pad auto bgMode auto bgRadius 0.7 blMode auto brMode auto varPsf auto varPsfCnt 1 sn ',num2str(SNR),' bg 0.0 timeOut 10000}}'];
    fileCounter = fileCounter + 1;
    
end
batchFile = cellfun(@(x) [x, newline], batchFile, 'UniformOutput', false);
fileName = ['batch_deconvolution_',datestr(clock, 'yyyy-mm-dd_HH-MM'), '_(',num2str(numel(files)),' files).hgsb'];
fileID = fopen(fullfile(output_dir, fileName), 'w');
fprintf(fileID, '%s', batchFile{:});
fclose(fileID);

fprintf('      - batch-file for Huygens Essential created [%s], containing %d images', fullfile(output_dir, fileName), numel(files));