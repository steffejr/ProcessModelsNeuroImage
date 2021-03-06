function OutData = subfnCreateOutputStructures(AllParameters,AnalysisParameters,OutputPath,OutThresholds)
if nargin == 3
    OutThresholds = -9999;
end
% The aim is to break this up into pieces so that it can be modular and
% work with voxel-based analyses or Freesurfer based analyses
% 1) create a structure with the thre model results
% 2) add structures for the conditional effects for the different models
% 3) Fill in the structure with the actual data
% 4) write out images
%   I think there shoudl be a flag in the AnalysisParameters saying what
%   sort of analysis this is: 1) voxel-wise, freesurfer, PCA
%   4a) this may be voxel-wise or
%   4b) freesurfer images
%
% All models will have some things in common
fprintf(1,'Creating output data structures to hold the data...\n');
V = AnalysisParameters.V;
V.fname = OutputPath;
ModelNum = AnalysisParameters.ModelNum;
Tag = AnalysisParameters.Tag;
OutName = [Tag '_Model' ModelNum '_'];
count = 1;
while isempty(AllParameters{count})
    count = count + 1;
end
Nvoxels = AnalysisParameters.Nvoxels;
Nmed = AnalysisParameters.Nmed;

Thresholds = AnalysisParameters.Thresholds;
if OutThresholds > 0
    if ~isempty(find(Thresholds == OutThresholds))
        Thresholds = OutThresholds;
    else
        error('Entered threshold was not tested.\n');
    end
end
Nthr = length(Thresholds);
VoxelIndices = zeros(Nvoxels,1);
ImageVoxelIndices = AnalysisParameters.Indices;%zeros(Nvoxels,1);
% This creates the structure for the base models that are common to all
% models
[OutData index] = subfnCreateOutDataStructureForModels(AllParameters,AnalysisParameters);
%fprintf(1,'Creating the model specific structures...\n');
% write out Model 2 R-squared
if isfield(AllParameters{1},'Model1')
    if iscell(AllParameters{1}.Model1)
        for j = 1:length(AllParameters{1}.Model1)
            OutData{index}.name = sprintf('Model1_Med%d_Rsq',j);
            OutData{index}.data = zeros(Nvoxels,1);
            OutData{index}.field = [sprintf('Model1{%d}.Model.rsquare',j)];
            OutData{index}.dataType = 16;
            index = index + 1;
        end
    else
        OutData{index}.name = 'Model1_Rsq';
        OutData{index}.data = zeros(Nvoxels,1);
        OutData{index}.field = [sprintf('Model1.Model.rsquare')];
        OutData{index}.dataType = 16;
        index = index + 1;
    end
end
% write out Model 2 R-squared
if isfield(AllParameters{1},'Model2')
    OutData{index}.name = 'Model2_Rsq';
    OutData{index}.data = zeros(Nvoxels,1);
    OutData{index}.field = ['Model2.Model.rsquare'];
    OutData{index}.dataType = 16;
    index = index + 1;
end
% write out Model 3 R-squared
if isfield(AllParameters{1},'Model3')
    OutData{index}.name = 'Model3_Rsq';
    OutData{index}.data = zeros(Nvoxels,1);
    OutData{index}.field = ['Model3.Model.rsquare'];
    OutData{index}.dataType = 16;
    index = index + 1;
end
% write out Model 4 R-squared
if isfield(AllParameters{1},'Model4')
    OutData{index}.name = 'Model4_Rsq';
    OutData{index}.data = zeros(Nvoxels,1);
    OutData{index}.field = ['Model4.Model.rsquare'];
    OutData{index}.dataType = 16;
    index = index + 1;
end
switch ModelNum
    case '1'
        % Conditional Effects
        NProbe = [];
        count = 1;
        while isempty(AllParameters{count})
            count = count + 1;
        end
        NProbe = length(AllParameters{count}.CondMod);
        for j = 1:Nmed
            for k = 1:NProbe
                probeValue = AllParameters{count}.CondMod{k}.probeValue;
                for i = 1:Nthr
                    thrStr = num2str(Thresholds(i));
                    OutData{index}.name = sprintf('CondMod%d_pV%0.2f_sign%0.4f',j,probeValue,Thresholds(i));
                    OutData{index}.data = zeros(Nvoxels,1);
                    OutData{index}.field = ['CondMod{' num2str(k) '}.BCaci.alpha' thrStr(3:end)];
                    OutData{index}.dataType = 2;
                    index = index + 1;
                    
                end
            end
        end
        
    case '4'
        % Conditional Effects
        for j = 1:Nmed
            for i = 1:Nthr
                thrStr = num2str(Thresholds(i));
                OutData{index}.name = ['ABMed' num2str(j) 'sign_' num2str(Thresholds(i))];
                OutData{index}.data = zeros(Nvoxels,1);
                OutData{index}.field = ['AB' num2str(j) '{1}.BCaci.alpha' thrStr(3:end)];
                OutData{index}.dataType = 2;
                index = index + 1;
            end
            OutData{index}.name = sprintf('M%dpointEst',j);
            OutData{index}.data = zeros(Nvoxels,1);
            OutData{index}.field = sprintf('AB%d{1}.pointEst',j);
            OutData{index}.dataType = 16;
            index = index + 1;
            OutData{index}.name = sprintf('M%dp',j);
            OutData{index}.data = zeros(Nvoxels,1);
            OutData{index}.field = sprintf('AB%d{1}.p',j);
            OutData{index}.dataType = 16;
            index = index + 1;
            OutData{index}.name = sprintf('M%dZ',j);
            OutData{index}.data = zeros(Nvoxels,1);
            OutData{index}.field = sprintf('AB%d{1}.Z',j);
            OutData{index}.dataType = 16;
            index = index + 1;            
          
        end
        if isfield(AllParameters{1},'k2')
            OutData{index}.name = 'k2';
            OutData{index}.data = zeros(Nvoxels,1);
            OutData{index}.field = ['k2.pointEst'];
            OutData{index}.dataType = 16;
            index = index + 1;
        end
    case '6'
        % Conditional Effects
        OutData{index}.name = 'M1M2pointEst';
        OutData{index}.data = zeros(Nvoxels,1);
        OutData{index}.field = 'M1M2{1}.pointEst';
        OutData{index}.dataType = 16;
        index = index + 1;
        OutData{index}.name = 'M1M2p';
        OutData{index}.data = zeros(Nvoxels,1);
        OutData{index}.field = 'M1M2{1}.p';
        OutData{index}.dataType = 16;
        index = index + 1;
        OutData{index}.name = 'M1M2Z';
        OutData{index}.data = zeros(Nvoxels,1);
        OutData{index}.field = 'M1M2{1}.Z';
        OutData{index}.dataType = 16;
        index = index + 1;
        for i = 1:Nthr
            thrStr = num2str(Thresholds(i));
            OutData{index}.name = ['M1M2' 'sign_' num2str(Thresholds(i))];
            OutData{index}.data = zeros(Nvoxels,1);
            OutData{index}.field = ['M1M2{1}.BCaci.alpha' thrStr(3:end)];
            OutData{index}.dataType = 2;
            index = index + 1;
        end
        
    case '7'
        for j = 1:Nmed
            for i = 1:Nthr
                thrStr = num2str(Thresholds(i));
                OutData{index}.name = sprintf('CondABMed%d_pV000_sign%0.4f',j,Thresholds(i));
                OutData{index}.data = zeros(Nvoxels,1);
                OutData{index}.field = ['CondAB' num2str(j) '{1}.BCaci.alpha' thrStr(3:end)];
                OutData{index}.dataType = 2;
                index = index + 1;
            end
            OutData{index}.name = sprintf('CondABMed%d_pV000_pointEst',j);
            OutData{index}.data = zeros(Nvoxels,1);
            OutData{index}.field = ['CondAB' num2str(j) '{1}.pointEst'];
            OutData{index}.dataType = 16;
            index = index + 1;
        end
        
    case '14'
        j=1;
        OutData{index}.name = ['CondAB' num2str(j)];
        OutData{index}.data = zeros(Nvoxels,1);
        OutData{index}.field = ['CondAB' num2str(j) '{' num2str(j) '}.pointEst'];
        index = index + 1;
        %OutData{index}.name = ['ConABpValue' num2str(j)];
        %OutData{index}.data = zeros(Nvoxels,1);
        %OutData{index}.field = ['CondAB' num2str(j) '{' num2str(j) '}.pValue'];
        % index = index + 1;
        for i = 1:Nthr
            thrStr = num2str(Thresholds(i));
            OutData{index}.name = sprintf('CondABMed%d_pV000_sign%0.4f', j, Thresholds(i));
            OutData{index}.data = zeros(Nvoxels,1);
            OutData{index}.field = ['CondAB' num2str(j) '{1}.BCaci.alpha' thrStr(3:end)];
            index = index + 1;
        end
        
    case '58'
        for j = 1:Nmed
            for i = 1:Nthr
                thrStr = num2str(Thresholds(i));
                OutData{index}.name = sprintf('CondABMed%d_pV000_sign%0.4f',j,Thresholds(i));
                OutData{index}.data = zeros(Nvoxels,1);
                OutData{index}.field = ['CondAB' num2str(j) '{1}.BCaci.alpha' thrStr(3:end)];
                OutData{index}.dataType = 2;
                index = index + 1;
            end
            OutData{index}.name = sprintf('CondABMed%d_pV000_pointEst',j);
            OutData{index}.data = zeros(Nvoxels,1);
            OutData{index}.field = ['CondAB' num2str(j) '{1}.pointEst'];
            OutData{index}.dataType = 16;
            index = index + 1;
        end
        
    case '74'
        % Conditional Effects
        NProbe = [];
        count = 1;
        while isempty(AllParameters{count})
            count = count + 1;
        end
        NProbe = length(AllParameters{count}.CondAB1);
        for j = 1:Nmed
            for k = 1:NProbe
                probeValue = AllParameters{count}.CondAB1{k}.probeValue;
                for i = 1:Nthr
                    thrStr = num2str(Thresholds(i));
                    OutData{index}.name = sprintf('CondABMed%d_pV%0.2f_sign%0.4f',j,probeValue,Thresholds(i));
                    OutData{index}.data = zeros(Nvoxels,1);
                    OutData{index}.field = ['CondAB' num2str(j) '{' num2str(k) '}.BCaci.alpha' thrStr(3:end)];
                    OutData{index}.dataType = 2;
                    index = index + 1;
                    
                end
            end
        end
    case '75'
        % Conditional Effects
        NProbe = length(AllParameters{1}.M1M2);
        
        for k = 1:NProbe
            probeValue = AllParameters{1}.M1M2{k}.probeValue;
            
            OutData{index}.name = sprintf('CondM1M2_pV%0.2f_pointEst',probeValue);
            OutData{index}.data = zeros(Nvoxels,1);
            OutData{index}.field = ['M1M2{' num2str(k) '}.pointEst'];
            OutData{index}.dataType = 16;
            index = index + 1;
            OutData{index}.name = sprintf('CondM1M2_pV%0.2f_p',probeValue);
            OutData{index}.data = zeros(Nvoxels,1);
            OutData{index}.field = ['M1M2{' num2str(k) '}.p'];
            OutData{index}.dataType = 16;
            index = index + 1;
            OutData{index}.name = sprintf('CondM1M2_pV%0.2f_Z',probeValue);
            OutData{index}.data = zeros(Nvoxels,1);
            OutData{index}.field = ['M1M2{' num2str(k) '}.Z'];
            OutData{index}.dataType = 16;
            index = index + 1;            
            
            OutData{index}.name = sprintf('CondM1M2_pV%0.2f_bootSE',probeValue);
            OutData{index}.data = zeros(Nvoxels,1);
            OutData{index}.field = ['M1M2{' num2str(k) '}.bootSE'];
            OutData{index}.dataType = 16;
            index = index + 1;
            
            for i = 1:Nthr
                thrStr = num2str(Thresholds(i));
                OutData{index}.name = sprintf('CondM1M2_pV%0.2f_sign%0.4f',probeValue,Thresholds(i));
                OutData{index}.data = zeros(Nvoxels,1);
                OutData{index}.field = ['M1M2{' num2str(k) '}.BCaci.alpha' thrStr(3:end)];
                OutData{index}.dataType = 2;
                index = index + 1;
                
            end
        end
end
fprintf(1,'Done creating the output structures.\n');
