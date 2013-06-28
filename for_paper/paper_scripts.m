%{
2013-06-25 This script file contains for parts:
The first two check how the approximation by linearization works for Cost 1
and Cost 2 of the paper.
The next cell produces a tighter approximation for 2D ball using quadprog.
The last cell looks at the volume of the spherical cap as a function of
dimension and distance from the center.


Paper: http://arxiv.org/abs/1104.5061

%}
%% Cost 1 Linearization 2013-06-25
clear all
close all
M1M2 = 10;
zr = -M1M2:0.1:M1M2;
e = exp(1);
figure;
plot(zr, 1./(1+e.^(-zr)));
hold on;
m1 = (e^(M1M2))/(1+e^(M1M2))^2;
m0 = 1/(1+e^(M1M2)) + m1*M1M2;
plot(zr,m1*zr+m0);
hold off;

%% Cost2 Linearization 2013-6-25
clear all
close all
M1M2 = 10;
zr = -M1M2:0.1:M1M2;
e = exp(1);
figure;
plot(zr, log(1+e.^(zr)));
hold on;
m1 = (e^(-M1M2))/(1+e^(-M1M2));
m0 = log(1+e^(-M1M2)) + m1*M1M2;
plot(zr,m1*zr+m0);
hold off;

%% APPROXIMATION BY OPTIMIZATION vs LINEARIZATIOn
%2011-05-14 Finds two approximations to the set F_1 (see paper http://arxiv.org/abs/1104.5061 )
%2011-01-31 Supplies d_i's used for plotting the curve.
%2010-11-16 Geometric intution of \sum d_i\frac{1}{1+e^{-w.x_i}} \leq C_g
% Fly by assumptions. uniformly distributed nodes on 2D plane.
% Assume 1d feature and 2d parameter lambda.

clc;
clear all;
close all;


contourLevel= 0.8;
N           = 6; % number of points including the starting node.
dimLambda   = 2;

%Step 1 : Generate points on plane by uniformly sampling x and y coord
%Compute distance from node1 to all other nodes = d_i 

Box = 1000; %the 2D box in which I want to get random points.
xCoord = randi([0,Box],[N,1]);
yCoord = randi([0,Box],[N,1]);


for i=2:N
    dist(i) = sqrt((xCoord(i) - xCoord(1))^2 + (yCoord(i) - yCoord(1))^2);
end
dist(1) = 2*min(dist(2:end));
%dist = ones(1,N);


%Step 2: Create non-linear constraint
x = 2*rand(N,1)-1;
%x = [-10 -5 0 5 10 15]';
discretParam = 0.05;
w1arr = [-1:discretParam:1];
w0arr = [-1:discretParam:1];

for i=1:length(w1arr)
    for j=1:length(w0arr)
        proba = 1./(1+exp(-(w1arr(i)*x + w0arr(j))));
        constrval(i,j) = dist*proba;
    end
end
bigM = max(max(constrval));
constrval = constrval/bigM;


%Step 3: Plot the curve to get the discrete values of lambda

h = figure;
[C,h] = contour(w0arr,w1arr,constrval,[contourLevel contourLevel]); hold on;
close;


% we have variables related to the hyperplane: c'\lambda - 1 \leq 0
%let c(1)..c(dimLambda) be the normal vecot of the hyperplane.
%discretized values of lambda are obtained from contour plot (previously)


%Step 4: Solve for the hyperplane using quadprog.

%4a: Getting the discretized lambda values on the curve from contour's output.
startIndC = 1; %starting index of contour plot (previously)
k = 1;
for i=1:C(2,startIndC)
    
    if(sqrt(C(1,startIndC+i)^2 + C(2,startIndC+i)^2) <= 1)
        A(k,1) = C(1,startIndC+i);
        A(k,2) = C(2,startIndC+i);
        A(k,3) = -1;
        k = k + 1;
    end
end
%4b: Forming constraints for the quadratic program.    
Afull = [A(:,1:2)] ;
el=length(Afull(:,1));
bfull = ones(el,1);
[temp1,temp2] = max(A(:,1).^2 + A(:,2).^2);
[temp3,temp4] = min(A(:,1).^2 + A(:,2).^2);
Afull(el+1,:) = -A(temp2,1:dimLambda);
bfull(el+1) = -sqrt(A(temp4,1).^2 + A(temp4,1).^2);
%4c: calling quadprog.
[c,fval] = quadprog(-2*eye(dimLambda,dimLambda),zeros(1,dimLambda),Afull,bfull);



%Step 5a: Plot the l2 ball.

plotL2ball = 1;
h4 = figure;
if(plotL2ball ==1)
    temp = linspace(0, 2*pi, 500); %Randomly set to 500 number of points.
    plot(1*cos(temp),1*sin(temp));
end
hold on;


%Step5b: Plotting the linear approximation along with the curve on the l2-ball.
h4 = plot(A(:,1),A(:,2),'m'), axis([-1 1 -1 1]);hold on;
set(h4,'LineWidth',2);     % set the linewidth and fontsize
[a,b] = meshgrid(-1:discretParam:1);
zDisc = c(1)*a + c(2)*b -1;
[Ctemp,h4] = contour(a,b,zDisc,[0 0],'r'); hold on;
set(h4,'LineWidth',2);     % set the linewidth and fontsize

%Step 6: Finding the crude approximation based on linear approx of p(.)
shifthatCg = contourLevel - ((1/(1+exp(1)) + 1*exp(1)/(1+exp(1))^2))*sum(dist)/bigM;
slope_linApprox(1) = (exp(1)/(1+exp(1))^2)*sum(dist*x)/bigM;
slope_linApprox(2) = (exp(1)/(1+exp(1))^2)*sum(dist*1)/bigM;
zApprox = slope_linApprox(1)*a' + slope_linApprox(2)*b' - shifthatCg;
%close all;
%figure;
[Ctemp,h4] = contour(a,b,zApprox,[0 0]);
colormap cool
set(h4,'LineWidth',2);     % set the linewidth and fontsize
set(gca, 'Fontsize',30);
width=2; % I think the next few lines change the default line widths
set(0,'DefaultAxesLineWidth',width);
set(0,'DefaultLineLineWidth',width);
get(0,'Default');
set(gca,'LineWidth', width);   % I think this line is the same as the one earlier, not sure why I have it twice
h4 = get(gca,'children'); % this one seems to be really helpful in getting stuff inside the plot to inherit the linewidth, but I?Äôm not sure how it works.
%xlabel('\lambda_1')
%ylabel('\lambda_2')
%title('Approximating the level set')
legend('unit ball','original level set', 'approx. by optimization', 'approx. by linearization');




%figure; surf(constrval); figure; surf(zApprox); figure; surf(zDisc);



%% SPHERICAL CAP VOLUME FOR PAPER

%This scripts shows the normalized volume of a spherical cap as its
%distance from the center of the sphere is varied from -R (0 vol) to R
%(full vol) 


%2011-01-25 Making a plot of the volume as a function of dimension and z.
%removed hypergeometric: %vBminusC(ind,d) = 0.5 + (z(ind)/r)*(gamma(d/2+1)/sqrt(pi)/gamma(d/2+0.5))*hypergeom([0.5,0.5-d/2],1.5,(z(ind)/r)^2);

%2011-01-07 checking the relative volume of the spherical cap (smaller portion)

clc;
clear all;
close all;

r = 1; % max radius
z = 0:0.1:r; %height from the center varying from 0 to full.
dMax = 9; % upto this dimension

for d=1:dMax % outer loop: for each dimension value
    for ind=1:length(z) % inner loop: for each height value
        vBminusCnormalized(ind,d) = 1 - 0.5*betainc(1 - z(ind)^2/r^2, 0.5+d/2,0.5);
        vCnormalized(ind,d) = 1 - vBminusCnormalized(ind,d);
    end
end

h4=figure;
for d=1:dMax
    temp = [ flipdim(vCnormalized(:,d),1); vBminusCnormalized(:,d)];
    plot([z z+1]',temp,'.-','color',[rand,rand,rand],'LineWidth',2); hold on;
    M(d,:) = strcat(['d = ' int2str(d)]);
    set(gca,'xticklabel',{'1','0.5','0','0.5','1'});
    %text(z(7),temp(7),['\leftarrow -------------- d =' int2str(d)], 'HorizontalAlignment','left')
end

set(gca, 'Fontsize',30);
width=2;
set(0,'DefaultAxesLineWidth',width);
set(0,'DefaultLineLineWidth',width);
get(0,'Default');
set(gca,'LineWidth', width);   
h4 = get(gca,'children'); 
title('Normalized Vol(B_{1}\cap H_{z})');
xlabel('\leftarrow   z: Distance of H_{z} from origin \rightarrow');
ylabel('Volume');
legend(M,'Location','SouthEast');