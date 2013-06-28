%Run data_generate.m first.
%What this does: Calculating training loss surface and plotting it.

shouldwePlot=1;
last2paramsPlot=1; % a flag to turn on one of the plots.


%% **Works only for 1X1 B1 array (default)** Plot Original training data
%% for visual inspection in feature space
% if (shouldwePlot==1 && last2paramsPlot==1 && length(B1)==1)
%     figure;
%     pos = find(trainingdata(:,3)==1);
%     plot(trainingdata(pos,1),trainingdata(pos,2),'b.');
%     pos = find(trainingdata(:,3)==-1);
%     hold on; plot(trainingdata(pos, 1),trainingdata(pos, 2),'r.');     
%     axis([-3 3 -3 3]);
%     x = [-1:0.1:1];
%     epsilonval = 1e-6;
%     for j=1:length(B2)
%         for k=1:length(B3)
%             m = -(B2(k)/(B3(j)+epsilonval));
%             c = -B1(end)/(B3(j)+epsilonval);    %caution.
%             y = m*x +c;
%             plot(x,y);
%         end
%     end            
%     hold off;
% end

%% Plotting the traing loss surface over the 2D parameter grid
% if(shouldwePlot==1)
%     figure;
% end
for i=1:length(B1)
    for j=1:length(B2)
        for k=1:length(B3)
            
        %trainingloss computation for each of these values 
        FtrainExhausive=B1(i)+trainingdata(:,1)*B2(j) + trainingdata(:,2)*B3(k);
        lossTraining(i,j,k) = sum(log(1+exp(-trainingdata(:,3).*FtrainExhausive)));
        end
    end
    if(last2paramsPlot==1)
        if(length(B1)==1) %default
            
            h1 = figure;
            surf(B2,B3,squeeze(lossTraining(i,:,:)));            
            %set(h1,'LineWidth',2);     % set the linewidth and fontsize
            set(gca, 'Fontsize',30);
            width=2; % I think the next few lines change the default line widths
            set(0,'DefaultAxesLineWidth',width);
            set(0,'DefaultLineLineWidth',width);
            get(0,'Default');
            set(gca,'LineWidth', width);   % I think this line is the same as the one earlier, not sure why I have it twice
            h1 = get(gca,'children'); % this one seems to be really helpful in getting stuff inside the plot to inherit the linewidth, but I?Äôm not sure how it works.
            %xlabel('\lambda^1')
            %ylabel('\lambda^2')
            %zlabel('Cost')
            %title('Training Loss at fixed \lambda^3')
            %legend('Test NM','Train NM', 'Test AM', 'Train AM');
            
            
            
        else
            hold on;
            subplot(2,length(B1)/2,i); 
            %surf(B2,B3,squeeze(lossTraining(i,:,:)));axis tight; %axis([-1 2.8 -1 2.8])
            contour(B2,B3,squeeze(lossTraining(i,:,:)));
        end
    end
    min(min(squeeze(lossTraining(i,:,:))))
    hold off;
end

%Note: Loss should be convex wrt 2 params given y,x. Similarly, given
%params, x it is convex wrt y. The function f(x) is linear.
