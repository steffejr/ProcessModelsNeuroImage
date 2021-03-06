clear
N = 100;
Nmed = 1;
NVox = 10000;
data = {};
data.X = round(rand(N,1));
AgeEffectsOnM = rand(Nmed,1);



data.M = zeros(N,Nmed,NVox);
for i = 1:Nmed
    for j = 1:NVox
        data.M(:,i,j) = data.X*AgeEffectsOnM(i) + 0.1.*randn(N,1);
    end
end

MeffectOnY = [0.8];% 1 1.5]';
cPIn = 1.2;
Vin = 1;
InterIn = 0.03;
ConstIn = 10;
% model 7
%Win = [MeffectOnY; Vin; InterIn; ConstIn; cPIn];
% model 4
Win = [MeffectOnY; ConstIn; cPIn];
data.Y = data.M(:,1,1)*MeffectOnY + data.X*cPIn + ones(N,1)*ConstIn;
data.Y = data.Y + 0.000002.*randn(N,1);

data.V = randn(N,5);

data.STRAT = [];
data.COV = [];
data.Thresholds = [0.05];

NPCs = 5;

remove_row_means=1;
[lambdas, eigenimages_noZeroes, w] = pca_f(squeeze(data.M)', remove_row_means);




data.ModelNum = '14';
tempdata = data;
tempdata.M = scores1(:,1:NPCs);

beta = subfnCallRegressPCs(tempdata,data.ModelNum);

%corr([data.X data.M data.V data.Y])

% get data sizes
N = length(data.Y);
NMed = size(data.M,2);
NMod = size(data.V,2);
% initialized parameter vector
W = zeros(size(Win));
options = optimset('TolX',1e-8);
options = optimset(options,'MaxIter',15000);
options = optimset(options,'MaxFunEvals',15000);
options = optimset(options,'Algorithm','levenberg-marquardt');
options = optimset(options,'TolFun',1e-10);
options = optimset(options,'GradObj','on');
