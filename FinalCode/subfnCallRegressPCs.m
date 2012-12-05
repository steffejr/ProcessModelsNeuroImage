function beta = subfnCallRegressPCs(data,ModelNum)
% This function makes the decision, based on the model, on how to estimate
% the parameters. The simple models can use linear regression but the
% models with interactions need to use an iterative process. 
% M: contains the SSFs of interest.
%
% define the options when using the fminsearch procedures 
options = optimset('TolX',1e-8);
options = optimset(options,'MaxIter',15000);
options = optimset(options,'MaxFunEvals',15000);
options = optimset(options,'Algorithm','levenberg-marquardt');
options = optimset(options,'TolFun',1e-10);
options = optimset(options,'GradObj','on');
NSub = size(data.Y,1);
switch ModelNum
    case '4'
        % standard linear regression
        % Expected: 
        % M: [NSub x one or more SSFs]
        % X: [NSub x 1]
        % Y: [NSub x 1]
        % COV: [NSub x 0 or more]
        beta = subfnregress(data.Y,[data.M data.X data.COV]);
        fit = [data.M data.X data.COV]*beta;
    case '14'
        NSSF = size(data.M,2);
        NMod = size(data.V,2);
        NCov = size(data.COV,2);
        beta0 = zeros(1+NSSF+NMod+1+1+NCov,1);
        beta0 = 1:1+NSSF+NMod+1+1+NCov
        [beta ,FVAL,EXITFLAG,OUTPUT] = fminsearch('subfnRegressPCs',beta0,options,data);

        
        %fit = ones(Nsub,1)*const + data.M*b + data.X*cP + data.V*v + ((data.M*b).*(data.V*v))*w + data.COV;
end
