%1. This scripts explores the adding the two losses by changing the parameter C/gamma
%2. Should have all the required cost function values over the grid.
%Only assuming grids varying over 2 params with one fixed.

clear gamma0 gamma1 total iB1 tempa tempb 
gamma0 = 1; %coefficient of the first term, keep it 1 by default.
gamma1 = 0.001;
%gamma1 = 0.005707; %coefficient of the second term, change it over a range to see what fits.

total = gamma0*lossTraining + gamma1*opt_cost;

%finding optimal paths for different B values.
for iB1=1:length(B1)

%     subplot(2,length(B1),iB1); %2 row plots by default. first row plots the cost surface.
     squeezedtotal = squeeze(total(iB1,:,:));
%     surf(squeezedtotal);    

    [tempa,tempb]=find(squeezedtotal==min(squeezedtotal(:))); %finding optimal B2,B3 param indices.
    indexB2opt(iB1) = tempa(end);
    indexB3opt(iB1) = tempb(end);
    path(iB1,:,:) = round(reshape(xmeta(iB1,indexB2opt(iB1),indexB3opt(iB1),37:72),6,6)); %finding the path at these indices.

    figure;
    %Plotting the decision boundary and test points for each B(1) value
%     subplot(2,length(B1),length(B1)+iB1);% 2nd row plots the decision boundary.
%    hold on;     
    xt = [-3:0.1:3];                                        epsilonval = 1e-6;
    m = -(B2(indexB2opt(iB1))/(B3(indexB3opt(iB1)) + epsilonval));
    c = -B1/(B3(indexB3opt(iB1))+epsilonval);                    yt = m*xt +c;
    mo = -(B(2)/(B(3) + epsilonval));
    co = -B(1)/(B(3)+epsilonval);                               yto = mo*xt +co;
    h31 = plot(xt,yt,'r'); hold on;
    h32 = plot(xt,yto,'k');
    pos = find(trainingdata(:,3)==1);hold on;
    plot(trainingdata(pos,1),trainingdata(pos,2),'g+','MarkerSize',20);
    pos = find(trainingdata(:,3)==-1);  hold on; 
    plot(trainingdata(pos, 1),trainingdata(pos, 2),'co','MarkerSize',20);
    plot(testdata(pos_l1,1),testdata(pos_l1,2),'b^','MarkerSize',20); 
    plot(testdata(pos_l0,1),testdata(pos_l0,2),'b^','MarkerSize',20);
    plot(testdata(pos_t6,1),testdata(pos_t6,2),'b^','MarkerSize',20); 
    axis([-3 3 -3 3]);
%     
    set(gca, 'Fontsize',30);
    width=3; % I think the next few lines change the default line widths
    set(0,'DefaultAxesLineWidth',width);
    set(0,'DefaultLineLineWidth',width);
    get(0,'Default');
    set(gca,'LineWidth', width);   % I think this line is the same as the one earlier, not sure why I have it twice
    h2 = get(gca,'children'); % this one seems to be really helpful in getting stuff inside the plot to inherit the linewidth, but I?Äôm not sure how it works.
    %xlabel('x^1')
    %ylabel('x^2')
    %title('Shift in the level set')
    %legend([h31,h32],'new level set','original level set');
    
%     set(gcf,'Units','normalized');
%     xa = [1.6 2]*pi; % X-Coordinates in data space 
%     ya = [0 0]; % Y-Coordinates in data space 
%     [xaf,yaf] = axescoord2figurecoord(xa,ya); % Convert to normalized figure units
%     annotation('textarrow', xaf,yaf, 'String' , '');
%    [testdata([pos_l1 pos_l0 pos_t6],1) testdata([pos_l1 pos_l0 pos_t6],2)]
    
    
    hold off;
end
%If checking change of path with changing gamma in the variable editor:
path2 = permute(path,[2 3 1]) %postprocessing for better display when see in variable editor.

%TODO:
%1. 3d plot of parameter evolution during the search.

F6node=B1(1)+testdata(pos_test,1)*B2(tempa(end))+testdata(pos_test,2)*B3(tempb(end));
q = ones(length(pos_test),1)./(ones(length(pos_test),1)+exp(-F6node))

