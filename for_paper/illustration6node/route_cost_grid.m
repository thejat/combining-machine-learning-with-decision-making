% Before executing this m file
% Run data_generate.m to get the test, training data and B parameters.
% Run training_loss_grid.m to get the logistic cost surface.
% What this does: finding exhausively cost values for different optimal paths for different Bvectors.
% Note1. syntax for gurobi is listed in the twostep_controlmethod.m


%Options for the external solver: gurobi.
clear opts
opts.IterationLimit = 4000;
opts.FeasibilityTol = 1e-6;
opts.IntFeasTol = 1e-5;
opts.OptimalityTol = 1e-6;
opts.LPMethod = 1;         % 0 - primal, 1 - dual
opts.Presolve = -1;        % -1 - auto, 0 - no, 1 - conserv, 2 - aggressive
opts.DisplayInterval = 0;
opts.Display = 0;
number_of_infeasible = 0;

for iouter=1:length(B1)
    for jouter=1:length(B2)
        for kouter=1:length(B3)

            %Start solving the IP
            N = 6;                  % It is extensively used below.
            
            %Assigning probabilities to the 6 test nodes based on theta evaluated
            F6node=B1(iouter)+testdata(pos_test,1)*B2(jouter)+testdata(pos_test,2)*B3(kouter); % hardcoded 2d
            q = ones(length(pos_test),1)./(ones(length(pos_test),1)+exp(-F6node));
            q = q';
            q = round(q*100); %TODO: STUDY THIS EFFECT
            
            
            C = [0  7  7 10 10 12;  %Hardcoded N
             7  0  7 10 10 12;
             7  7  0 10 10 12; 
            10 10 10  0  7 12;
            10 10 10  7  0 12;
            12 12 12 12 12  0];
            %TODO: change 1,2,3 to N(10,2) , 4,5 to N(10,2) and so on.
            
            sanitycheck = 0; % If ON, gurobi solves the fischetti problem.
            if(sanitycheck==1)
                M = 100000;
                q = [1 1 1 1 1 1]';
                C = [0 12  M  M  9 16; %Hardcoded N here
                    12  0 19 12  M 15;
                     M 19  0 21  M 17; 
                     M 12 21  0 10 16;
                     9  M  M 10  0 10;
                    16 15 17 16 10  0];
            end


            c = [reshape(C,N^2,1);zeros(N^2,1)]; % gurobi input: vectorize the distance matrix.
            objtype = 1;                         % 1 for minimize, -1 for maximize

            % Number of variables: integers N^2 for xij and N^2 binary for
            % yij (can be reduced to N^2-N each)
            % Creating the R matrix required for one of the constraints

            R = (sum(q)-q(1))*ones(N,N);
            for i=1:N
                for j=1:N
                    if(j==1)
                        R(i,j) = q(1);
                    end
                    if(i==1)
                        R(i,j) = sum(q);
                    end
                end
            end



            A00 = [diag([1 zeros(1,N-1)]) zeros(N)];
            A01 = [zeros(N) diag([1 zeros(1,N-1)])];
            for i=1:N
             A0(i,:) = reshape(circshift(A00,[i-1,i-1]),2*N^2,1)'; 
             A0(i+N,:) = reshape(circshift(A01,[i-1,i-1]),2*N^2,1)';
            end

            A2(1,:) = [zeros(1,N^2) ones(1,N) zeros(1,N^2-N)];                      %colsum of yij
            A1(1,:) = [zeros(1,N^2) reshape([ones(N,1) zeros(N,N-1)]',1,N^2)];      %rowsum of yij
            for i=2:N
                A2(i,:) = circshift(A2(1,:)',N*(i-1))';
                A1(i,:) = circshift(A1(1,:)',i-1)';
            end

            A3 = [ones(N,1); zeros(N^2-N,1); zeros(N^2,1)]'; % the Nth leg flow value is 1 back to the first node. column sum


            A42(1,:) = [ones(1,N) zeros(1,N^2-N) zeros(1,N^2)];                     %colsum of xij
            A41(1,:) = [reshape([ones(N,1) zeros(N,N-1)]',1,N^2) zeros(1,N^2)];     %rowsum of xij
            A4(1,:) = A42(1,:) - A41(1,:);
            for i=2:N
                A42(i,:) = circshift(A42(1,:)',N*(i-1))';
                A41(i,:) = circshift(A41(1,:)',i-1)';
                A4(i,:) = A42(i,:)-A41(i,:);
            end
            bA4 = q';
            bA4(1) = bA4(1) - sum(q);

            A5 = zeros(N^2,2*N^2);
            for i=1:N
                for j=1:N
                    A50 = [zeros(N) zeros(N)];
                    A50(i,j) = 1;           % for xij
                    A50(i,j+N) = -R(i,j);   % for yij
                    A5(N*(i-1)+j,:) = reshape(A50,2*N^2,1)';
                end
            end

            randomA6 = [reshape([ones(1,N); zeros(N-1,N)],1,N^2) zeros(1,N^2)]; % the 1st leg flow value is N exiting from first node. row sum

            A =  sparse([A0; A1; A2; A3; A4; A5]);
            b = [zeros(2*N,1); ones(N,1);ones(N,1); q(1); bA4; zeros(N^2,1)];
            contypes = '===============================<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<';
            lb = zeros(2*N^2,1);    % scalar means a uniform lower bound equal to scalar (which is zero here)
            ub = [sum(q)*ones(N^2,1);ones(N^2,1)]; % using loosely somewhat. Shoudl Rij figure here?
            vtypes = 'CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB';

            [x,val,exitflag,output] = gurobi_mex(c,objtype,A,b,contypes,lb,ub,vtypes,opts);
            
            if(exitflag ~=2)
                if(jouter > 1)
                    opt_cost(iouter,jouter,kouter) = opt_cost(iouter,jouter-1,kouter);
                elseif (kouter > 1)
                    opt_cost(iouter,jouter,kouter) = opt_cost(iouter,jouter,kouter-1);
                else
                    opt_cost(iouter,jouter,kouter) = 20000; %HACK TO GET RID OF INFES.
                end
                xmeta(iouter,jouter,kouter,:) = zeros(1,72);
                number_of_infeasible = number_of_infeasible+1;
            else
                opt_cost(iouter,jouter,kouter) = val;
                xmeta(iouter,jouter,kouter,:) = x(1:72);
            end
            
            % Solving the IP Ends.
        end
    end
end
display(number_of_infeasible);


%plotting the cost surfaces
figure;
for iB1=1:length(B1)
    %subplot(2,length(B1)/2,iB1); %2 row plots by default. first row plots the cost surface.
    squeezedroutecost = squeeze(opt_cost(iB1,:,:));
    surf(B2,B3,squeezedroutecost/100);
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
    %zlabel('Graph Cost')
    %title('Graph traversal cost at fixed \lambda^3')
    %legend('Test NM','Train NM', 'Test AM', 'Train AM');
    
    
end


% 
% figure;
% for iB1=1:length(B1)
%     subplot(2,length(B1)/2,iB1); %2 row plots by default. first row plots the cost surface.
%     squeezedroutecost = squeeze(opt_cost(iB1,:,:));
%     contour(squeezedroutecost/100);
% end


