close all;
clear;

month = 2;

%presLevel = 300;
%presLevel = 10;
presLevel = 1500;

CVStartYear = 2007;
CVEndYear = 2016;

figure;
hold on;

for iCase=1:5

    switch iCase
        case 1
            S = load(['./Results/pullLOFOSpaceRG_var_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(CVStartYear),'_',num2str(CVEndYear),'.mat']);
            pull = S.pull;
        case 2
            S = load(['./Results/pullLOFOSpaceExp_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(CVStartYear),'_',num2str(CVEndYear),'.mat']);
            pull = S.pull;
        case 3
            S = load(['./Results/pullLOFOSpaceTimeExp_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(CVStartYear),'_',num2str(CVEndYear),'.mat']);
            pull = S.pull;
        case 4
            S = load(['./Results/pullLOFOSpaceGPML_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(CVStartYear),'_',num2str(CVEndYear),'.mat']);
            pull = S.pullNormal;
        case 5
            S = load(['./Results/pullLOFOSpaceTimeGPML_',num2str(presLevel),'_',num2str(month,'%02d'),'_',num2str(CVStartYear),'_',num2str(CVEndYear),'.mat']);
            pull = S.pullNormal;
    end
    
    pull = -pull; % Mirror the plot for consistency with the paper
    
    % Remove NaNs
    disp(sum(isnan(pull)));
    idx = ~isnan(pull);
    pull = pull(idx);
    
    nRes = length(pull);
    disp(nRes);
    
    pullSorted = sort(pull);
    normQuantiles = norminv(((1:nRes)-0.5)/nRes,0,1);
    normQuantiles = normQuantiles';

    plot(normQuantiles,pullSorted-normQuantiles,'.');

end

hold off;
box on;
line([-4,4],[0,0],'Color','k');
axis([-2.8,2.8,-1.2,1.2]);
legend('Reference','Space, Gaussian nugget','Space-time, Gaussian nugget','Space, Student nugget','Space-time, Student nugget','Location','Southeast');
ylabel('              Sample quantile - theoretical quantile');
xlabel('      Theoretical quantile');
drawnow;
set(gcf,'units','centimeters')
set(gcf,'pos',[0 0 0.7*22.5 0.7*14])
set(gcf,'paperunits',get(gcf,'units')) 
set(gcf,'paperpos',get(gcf,'pos'))
print('-depsc2',['./Figures/qqPlotComparisonLOFO_',num2str(presLevel),'_',num2str(month,'%02d'),'.eps']);