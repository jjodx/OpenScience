function LowPower

%% color for plots
skyblue = [86/255 180/255 233/255];
orange = [230/255 159/255 0];
TOTAL = 10000;

%% choice of simulations
% Sample size for each simulated researcher
Nhigh = 50;%high power
Nlow = 20;% low power

%% uncomment below to obtain simulatins with the same total ressource for both researchers
% %Same resource = same total number of participants
% SimHigh = TOTAL/Nhigh; % Number of experiments with high power
% SimLow = TOTAL/Nlow;% Number of experiments with low power
% ylim_val=25;

%% uncomment below to obtain simulatins with the same number of experiments for both researchers
%Same number of experiments
% Number of simulations
SimHigh = TOTAL;
SimLow = TOTAL;
ylim_val=450;

%% choose the simulated effect size
% Effect size: No effect = 0
EffectSize = 0;

% x-axis limit
LimitX = 1.5;


%% choose whether you want to simulate p-hacking or not
phack =0;% set to 1 to simulate p-hacking where the researcher add some participants and stop when the result is significant or when he has added up to "MaxAdd" participants
MaxAdd = 3;%% number of potentially added participants

%% simulations for high power researcher
for k=1:round(SimHigh)
    tmpHIGH(k).data=randn(Nhigh,2);
    tmpHIGH(k).data(:,2)=tmpHIGH(k).data(:,2)+EffectSize;
%% t-test between the two simulated samples
    [h,p,ci,stats] = ttest2(tmpHIGH(k).data(:,1),tmpHIGH(k).data(:,2));
    A(k)= (mean(tmpHIGH(k).data(:,2))-mean(tmpHIGH(k).data(:,1)))/stats.sd;
    Ap(k)=p;
    %% p-hacking
    if phack==1 && p>0.05
        %% adding data points
        addN=0;
        %% testing until p significant or added participants >5
        while p>0.05 && addN<=MaxAdd
        tmpHIGH(k).data=[tmpHIGH(k).data;randn(1,2)];
        [h,p,ci,stats] = ttest2(tmpHIGH(k).data(:,1),tmpHIGH(k).data(:,2));
        addN=addN+1;
        end
        if p<0.05
        A(k)= (mean(tmpHIGH(k).data(:,2))-mean(tmpHIGH(k).data(:,1)))/stats.sd;
        Ap(k)=p;
        end
    end
end
% plotting the results
figure;
step = 0.02;
%% distribution of effect size
subplot(2,4,1)
histogram(A,[-LimitX:step:LimitX],'FaceColor',skyblue,'EdgeColor','none')
set(gca,'xlim',[-LimitX,LimitX],'fontsize',12)
set(gca,'ylim',[0,ylim_val])
hold on
histogram(A(Ap<0.05),[-LimitX:step:LimitX],'FaceColor',orange,'EdgeColor','none')
if EffectSize ~=0
    line([EffectSize EffectSize],[0 ylim_val],'Color','black','LineStyle','--')
end
legend({'effect size','significant effect size'},'fontsize',12)
title('Researcher A','fontsize',12)
xlabel('Observed effect size','fontsize',12)
ylabel('Number of observations','fontsize',12)
%% visualization of max effect size
subplot(2,4,2)
[~,ImaxA] = max(A);
a1=tmpHIGH(ImaxA).data(:,1); a2=tmpHIGH(ImaxA).data(:,2);
BarGraphIndiv(a1,a2)

%% simulations for low power researcher
for k=1:round(SimLow)
    tmpLOW(k).data=randn(Nlow,2);
    tmpLOW(k).data(:,2)=tmpLOW(k).data(:,2)+EffectSize;
%% t-tests
    [h,p,ci,stats] = ttest2(tmpLOW(k).data(:,1),tmpLOW(k).data(:,2));
    B(k)= (mean(tmpLOW(k).data(:,2))-mean(tmpLOW(k).data(:,1)))/stats.sd;
    Bp(k)=p;
        %% p-hacking
    if phack==1 && p>0.05
        %% adding data points
        addN=0;
        while p>0.05 && addN<=MaxAdd
        tmpLOW(k).data=[tmpLOW(k).data;randn(1,2)];
        [h,p,ci,stats] = ttest2(tmpLOW(k).data(:,1),tmpLOW(k).data(:,2));
        addN=addN+1;
        end
        if p<0.05
            B(k)= (mean(tmpLOW(k).data(:,2))-mean(tmpLOW(k).data(:,1)))/stats.sd;
            Bp(k)=p;
        end
    end
end
%% distribution of effect size
subplot(2,4,5)
histogram(B,[-LimitX:step:LimitX],'FaceColor',skyblue,'EdgeColor','none')
set(gca,'xlim',[-LimitX,LimitX],'fontsize',12)
hold on
histogram(B(Bp<0.05),[-LimitX:step:LimitX],'FaceColor',orange,'EdgeColor','none')
if EffectSize ~=0
    line([EffectSize EffectSize],[0 ylim_val],'Color','black','LineStyle','--')
end
set(gca,'ylim',[0,ylim_val])
title('Researcher B','fontsize',12)
legend({'effect size','significant effect size'},'fontsize',12)
xlabel('Observed effect size','fontsize',12)
ylabel('Number of observations','fontsize',12)
%% visualization of max effect size
subplot(2,4,6)
[~,ImaxB] = max(B);
b1=tmpLOW(ImaxB).data(:,1); b2=tmpLOW(ImaxB).data(:,2);
BarGraphIndiv(b1,b2)
end

function BarGraphIndiv(a1,a2)

skyblue = [86/255 180/255 233/255];
orange = [230/255 159/255 0];
bar1=1;
bar2=2;
barshift=0.1;

hold on
bar(bar1,nanmean(a1),'w','Linewidth', 2,'BarWidth',0.75)
bar(bar2,nanmean(a2),'w','Linewidth', 2,'BarWidth',0.75) 

errorbar(bar1+barshift,nanmean(a1),nanstd(a1)/sqrt(length(a1)),'k','linestyle','None','MarkerEdgeColor',skyblue,'Linewidth', 2)
errorbar(bar2+barshift,nanmean(a2),nanstd(a2)/sqrt(length(a2)),'k','linestyle','None','MarkerEdgeColor',orange,'Linewidth', 2)
for f1=1:length(a1)
   c1= plot(bar1-0.01*f1,a1(f1,1),'o','MarkerFaceColor',skyblue,'MarkerEdgeColor',skyblue,'LineWidth',1);
end
 
for f2=1:length(a2)
    c2=plot(bar2-0.01*f2,a2(f2,1),'o','MarkerFaceColor',orange,'MarkerEdgeColor',orange,'LineWidth',1);
end
%   legend([c1 c2],'young','old');
xticks([1 2]);
set(gca,'XTickLabels',{'HCL','Placebo'},'FontSize',16);
set(gca,'LineWidth',2,'ylim',[-2.5 2.5]);
end