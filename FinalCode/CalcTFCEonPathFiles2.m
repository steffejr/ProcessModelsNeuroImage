function CalcTFCEonPathFiles2(InPath)
cd(InPath)
% calculate TFCE permutation test
BaseDir = pwd;
load('../data/ModelInfo');
ModelInfo.data = [];
ModelInfo.BaseDir = pwd;
Vo = ModelInfo.DataHeader;
F = dir('Path_count*.mat');
NFiles = length(F);

load('PointEstimate')
load(F(1).name)

[M, N] = size(PermResults.t(:,:,1));
Nvoxels = ModelInfo.Nvoxels;
NPaths = size(PermResults.Paths,1);
MaxTmaps = zeros(M,N,NFiles);
MinTmaps = zeros(M,N,NFiles);
MaxTFCE = zeros(NFiles,NPaths);
MinTFCE = zeros(NFiles,NPaths);
% Check to see if the data has been loaded previously and only reload the
% new permutations.
if exist(fullfile(pwd,'CalcTFCEResults.mat'))
    PrevRes = load(fullfile(pwd,'CalcTFCEResults.mat'));
    % Only need to start where the previous load left off
    StartPoint = length(PrevRes.MinTFCE)+1;
    
    % Put these results into the respective matrices
    MaxTmaps(:,:,1:StartPoint - 1) = PrevRes.MaxTmaps;
    MinTmaps(:,:,1:StartPoint - 1) = PrevRes.MinTmaps;
    MaxTFCE(1:StartPoint - 1,:) = PrevRes.MaxTFCE;
    MinTFCE(1:StartPoint - 1,:) = PrevRes.MinTFCE;
else
    StartPoint = 1;
end





TFCEParams = ModelInfo.TFCEparams;
% Check to see if results have been processed yet



for i = StartPoint:NFiles
    fprintf(1,'File %d of %d\n',i,NFiles);
    load(F(i).name)
    % Extract the path data
    PathTNorm = zeros(Nvoxels,NPaths);
    for k = 1:NPaths
        for j = 1:Nvoxels
            PathTNorm(j,k) = PermResults.PathsTnorm{j}{k};
        end
        
        data = PathTNorm(:,k);
        [TFCEvalues] = subfnCalcTFCE((data), ModelInfo, TFCEParams);
        MaxTFCE(i,k) = max(TFCEvalues);
        MinTFCE(i,k) = min(TFCEvalues);
    end
    % Extract the direct effects
    for j = 1:M
        for k = 1:N
            if PermResults.t(j,k) ~= 0 
                % Extract just these values
                temp = squeeze(PermResults.t(j,k,:));
                % Run through the TFCE
                [TFCEvalues] = subfnCalcTFCE(temp, ModelInfo, TFCEParams);
                % Find the max and min values
                MaxTmaps(j,k,i) = max(TFCEvalues);
                MinTmaps(j,k,i) = min(TFCEvalues);
            end
        end
    end
end

save CalcTFCEResults MaxTmaps MinTmaps MaxTFCE MinTFCE


PathPE = zeros(length(Parameters),NPaths);
for k = 1:NPaths
    for i = 1:length(Parameters)
        PathPE(i,k) = Parameters{i}.PathsTnorm{k};
    end
    
    
    PathPETFCE = subfnCalcTFCE((PathPE(:,k)), ModelInfo, TFCEParams);
    PathTFCEpVal = zeros(length(Parameters),1);
    %PathPERMpVal = zeros(length(Parameters),1);
    for i = 1:length(Parameters)
        if PathPETFCE(i) > 0
            PathTFCEpVal(i) = (length(find(PathPETFCE(i) > MaxTFCE(:,k))))/(NFiles);
            %PathPERMpVal(i) = (length(find(PathPE(i) > MaxPerm(:,k))))/(NFiles);
        else
            PathTFCEpVal(i) = length(find(PathPETFCE(i) < MinTFCE(:,k)))/(NFiles);
            %PathPERMpVal(i) = (length(find(PathPE(i) > MinPerm(:,k))))/(NFiles);
        end
    end
    Tag = sprintf('TFCEPval_%dperm',NFiles);
    Vo.fname = fullfile(fileparts(BaseDir),sprintf('Path%02d_%s.nii',k,Tag));
    I = zeros(Vo.dim);
    I(ModelInfo.Indices) = PathTFCEpVal;
    spm_write_vol(Vo,I)
    Vo.fname = fullfile(fileparts(BaseDir),sprintf('Path%02d_TFCEpe.nii',k));
    I = zeros(Vo.dim);
    I(ModelInfo.Indices) = PathPETFCE;
    spm_write_vol(Vo,I)
end

% Cycle over all of the direct effects

for j = 2:M
    for k = 1:N
        if Parameters{1}.t(j,k) ~= 0
            % Extract the point estimate for this direct effect
            tempDirect = zeros(Nvoxels,1);
            pValDirect = zeros(Nvoxels,1);
            for i = 1:Nvoxels
                tempDirect(i) = Parameters{i}.t(j,k);
            end
            tfceDirect = subfnCalcTFCE(tempDirect, ModelInfo, TFCEParams);
            for i = 1:Nvoxels
                if tfceDirect(i) >= 0
                    pValDirect(i) = (length(find(tfceDirect(i) > squeeze(MaxTmaps(j,k,:)))))/(NFiles);
                else
                    pValDirect(i) = (length(find(tfceDirect(i) < squeeze(MinTmaps(j,k,:)))))/(NFiles);
                end
            end
            % Write images to files
            Tag = sprintf('TtfcePval_%dperm',NFiles);
            FileName = sprintf('Model%d_DEP%s_IND%s_%s.nii',k,ModelInfo.Names{k},ModelInfo.Names{j-1},Tag);
            Vo.fname = fullfile(fileparts(BaseDir),FileName);
            I = zeros(Vo.dim);
            I(ModelInfo.Indices) = pValDirect;
            spm_write_vol(Vo,I)
            % Write images to files
            Tag = 't';
            FileName = sprintf('Model%d_DEP%s_IND%s_%s.nii',k,ModelInfo.Names{k},ModelInfo.Names{j-1},Tag);
            Vo.fname = fullfile(fileparts(BaseDir),FileName);
            I = zeros(Vo.dim);
            I(ModelInfo.Indices) = tempDirect;
            spm_write_vol(Vo,I)
            
            % Write out the beta maps also
            tempDirect = zeros(Nvoxels,1);
            for i = 1:Nvoxels
                tempDirect(i) = Parameters{i}.beta(j,k);
            end
            % Write images to files
            Tag = 'beta';
            FileName = sprintf('Model%d_DEP%s_IND%s_%s.nii',k,ModelInfo.Names{k},ModelInfo.Names{j-1},Tag);
            Vo.fname = fullfile(fileparts(BaseDir),FileName);
            I = zeros(Vo.dim);
            I(ModelInfo.Indices) = tempDirect;
            spm_write_vol(Vo,I)

            
        end
    end
end