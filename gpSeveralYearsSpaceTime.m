function [nll,dnll] = gpSeveralYears(hyp, inf, covfunc, likfunc, interpLatAggr, interpLongAggr, interpJulDayAggr, interpResAggr)

nYear = length(interpLatAggr);

nll = 0;
dnll.cov = zeros(4,1);
dnll.lik = zeros(2,1);
dnll.mean = zeros(0,1);

for iYear = 1:nYear
    [temp1,temp2] = gp(hyp, inf, [], covfunc, likfunc, [interpLatAggr{iYear} interpLongAggr{iYear} interpJulDayAggr{iYear}], interpResAggr{iYear});
    nll = nll + temp1;
    dnll.cov = dnll.cov + temp2.cov;
    dnll.lik = dnll.lik + temp2.lik;
end