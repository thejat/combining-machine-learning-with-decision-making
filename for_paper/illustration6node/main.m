%2011-05-14 Works on 6 node data to understand the joint optimization.
%Note that because the probabilities are very high, the example is very
%sensitive.
%Ref paper http://arxiv.org/abs/1104.5061

clc;
clear all;
close all;

%% Some options
shouldwePlot = 1;

%% Generating Data
Ntrain = 50; % training will contain Ntrain examples.
%generate two traingular data clusters to illustrate the point
%get a square
xrandgen1 = rand(Ntrain,1);
xrandgen2 = rand(Ntrain,1);
xrandgen = [xrandgen1 xrandgen2 ones(Ntrain,1)];
poslowerTri = find(xrandgen(:,1)<xrandgen(:,2));
posupperTri = find(xrandgen(:,1)>=xrandgen(:,2));
%translate the points appropriately
T = [0.9 0.1 0.99;
     -0.1 0.9 -0.99;
     0 0 1];
xpositionedpart = xrandgen(poslowerTri,:)*T';
xpositionfull = [xpositionedpart;xrandgen(posupperTri,:)];
xpositionfull = 3*xpositionfull*[cos(90*pi/180) -sin(90*pi/180) 0; sin(90*pi/180) cos(90*pi/180) 0; 0 0 1 ]';
d = xpositionfull*[1 0 0; 0 1 -1; 0 0 1 ]';
d = d(:,1:2);
l  = [ones(length(xpositionedpart),1); -ones(Ntrain-length(xpositionedpart),1)];
flipprob = rand(Ntrain,1);
for i=1:length(flipprob)
    if(flipprob(i)>0.9) 
        l(i) = l(i)*-1;
    end
end
trainingdata = [d(1:Ntrain,:) l(1:Ntrain)];             % appended #Ntrain

B = glmfit(trainingdata(:,1:2), [0.5*trainingdata(:,3)+0.5 ones(length(trainingdata(:,3)),1)], 'binomial', 'link', 'logit');

%first 5 test points
lt = [1; 1; 1; -1; -1];
dt = [lt/2 + randn(5,1)/3  lt/2 + randn(5,1)/3];
pos_test = [1 2 3 4 5 6];
pos_l1 = [1 2 3];
pos_l0 = [4 5];
pos_t6 = 6;
testdata = [dt lt];
%the 6th point
xt = [-1:0.1:1];                          epsilonval = 1e-6;
m = -(B(2)/(B(3) + epsilonval));    c = -B(1)/(B(3)+epsilonval);                     
yt = m*xt +c;
testdata(6,:) = [xt(end) yt(end) -1];



%% Plot of the training and the 5 points.
if(shouldwePlot==1)
    h2 = figure;
    pos = find(trainingdata(:,3)==1);hold on;
    plot(trainingdata(pos,1),trainingdata(pos,2),'g+','MarkerSize',20);
    pos = find(trainingdata(:,3)==-1);  hold on; 
    plot(trainingdata(pos, 1),trainingdata(pos, 2),'co','MarkerSize',20);
    pos = find(testdata(:,3)==1); hold on;
    h21 = plot(testdata(pos,1),testdata(pos,2),'b^','MarkerSize',20);
    pos = find(testdata(:,3)==-1);  hold on; 
    h22 = plot(testdata(pos(1:2), 1),testdata(pos(1:2), 2),'b^','MarkerSize',20);
    h22l = plot(testdata(pos(end), 1),testdata(pos(end), 2),'b^','MarkerSize',20);
    h23 = plot(xt,yt,'k');
    %axis([-3 3 -3 3]);                  
    hold off;
    
    %set(h2,'LineWidth',2);     % set the linewidth and fontsize
    set(gca, 'Fontsize',30);
    width=3; % I think the next few lines change the default line widths
    set(0,'DefaultAxesLineWidth',width);
    set(0,'DefaultLineLineWidth',width);
    get(0,'Default');
    set(gca,'LineWidth', width);   % I think this line is the same as the one earlier, not sure why I have it twice
    h2 = get(gca,'children'); % this one seems to be really helpful in getting stuff inside the plot to inherit the linewidth, but I?Äôm not sure how it works.
    %xlabel('x^1')
    %ylabel('x^2')
    %title('Features and Labels')
    %legend([h21,h22,h23],'unlabeled positive','unlabeled negative', 'level set'); 
end


%% Find probabilities q on test data (of size 6)
Ftest=testdata(:,1:2)*B(2:end) + B(1);   %%%% This is the model
q=ones(length(testdata(:,3)),1)./(ones(length(testdata(:,3)),1)+exp(-Ftest));

%checking probabilties of test nodes
%Assigning probabilities to the 6 test nodes based on theta evaluated
F6node=B(1)+testdata(pos_test,1)*B(2)+testdata(pos_test,2)*B(3); % hardcoded 2d
q = ones(length(pos_test),1)./(ones(length(pos_test),1)+exp(-F6node))

interval = 0.25;
tau = 0.5;
%B1 = [B(1)-tau*.9:tau*0.3:B(1)+tau*.6];
B1 = [B(1)];
B2 = [B(2)-2:interval:B(2)+1.5];
B3 = [B(3)-2:interval:B(3)+1.5];


%% Exhausive execution to plot cost surfaces
training_loss_grid;
route_cost_grid;
adding_the_two_costs;
