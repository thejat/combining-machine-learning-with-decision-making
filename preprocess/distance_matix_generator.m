%Creating 6 node dataset

clc;
clear all;
close all;

%sample six indices
format long;
load ../data/dat_0.mat;

M = 6; % Number of test points coresponding tothe physical space.

%%Method 1 to find a collection of 3 pos, 3 neg nodes to tinker with.
% indexPostr      = find(yTrain_o == 1);
% indexPos        = find(yTest_o==1);
% indexNeg        = find(yTest_o==-1);
% latM            = zeros(M,1)';
% longM           = zeros(M,1)';
% latM(1:M/2)     = strLat(indexPos(1:M/2)); % naively choosing the first M/2
% latM(M/2+1:M)   = strLat(indexNeg(1:M/2)); % naively choosing the first M/2
% longM(1:M/2)    = strLon(indexPos(1:M/2)); % naively choosing the first M/2
% longM(M/2+1:M)  = strLon(indexNeg(1:M/2)); % naively choosing the first M/2



% % method 2: handpick
indexHandpick = [15509;15510; 15517; 15502; 15505;15507]; % Should be length M!!! Check[]
latM            = zeros(M,1)';
longM           = zeros(M,1)';
latM     = strLat(indexHandpick);
longM   = strLon(indexHandpick);




%%Creating the lat and long arrays for distance computation. We want to
%%create M*(M-1)/2 length (lat1,long1) and (lat2,long2).
k=1;
for i=1:length(latM)
    for j=1:i-1
        lat1(k)     = latM(i);
        long1(k)    = longM(i);        
        lat2(k)     = latM(j);
        long2(k)    = longM(j);
        k = k+1;
    end
end
lat1 = lat1'; long1 = long1';
lat2 = lat2'; long2 = long2';

%Distance computation: Bird's flying distances. Not useful.
%distances = DistGPS(lat1,long1,lat2,long2); 

%Distance computation: Querying google for the M*(M-1)/2 distance values
%for the complete graph. Steps to do :
%1. create the coordinates.js file
%run dist.html from server on athena for example to get the road lengths.
% var lat1 = new Array(40.800098,40.801098,40.841398,40.841398);
% var long1 = new Array(-73.913499,-73.914499,-73.914599,-73.913499);
% var lat2 = new Array(40.818573,40.819573,40.819573,40.841398);
% var long2 = new Array(-73.909854,-73.908854,-73.908854,-73.908854);
% var NumberofTestpoints = 4;
filename = ['coordinates.js'];
fid = fopen(filename, 'w'); 
fprintf(fid, '//js file generated through matlab script\n');
fclose(fid);
fid = fopen(filename, 'a');
fprintf(fid, 'var lat1 = new Array(');
dlmwrite(filename ,lat1','-append','delimiter',',','precision','%2.6f');
fprintf(fid, ');\n var long1 = new Array(');
dlmwrite(filename ,long1','-append','delimiter',',','precision','%2.6f');
fprintf(fid, ');\n var lat2 = new Array(');
dlmwrite(filename ,lat2','-append','delimiter',',','precision','%2.6f');
fprintf(fid, ');\n var long2 = new Array(');
dlmwrite(filename ,long2','-append','delimiter',',','precision','%2.6f');
fprintf(fid,');\n var NumberofTestpoints = %s ;\n',int2str(M*(M-1)/2));
fclose(fid);


%Look at the distance matrix to see if it conforms with what you want(?)
%2546 267;
%3911 457;
%982 243;
%1911 259;
%1567 244;
%1984 292;
%4265 542;
%5841 678;
%6884 753;
%4914 574;
%306 49;
%2588 290;
%3526 407;
%1429 209;
%4118 515;
%refetched on 2011-01-29 for the same set of handpicked nodes.



% % % Added on 2nd Jan.

% dists_obtained_from_GMAPquery = [ ...
%         2547         266
%         3911         456
%          982         243
%         1912         257
%         1569         245
%         1984         292
%         4265         541
%         5839         679
%         6884         753
%         4914         574
%          308          49
%         2588         291
%         3529         408
%         1429         209
%         4118         516];
% 
% 
% indexHandpick = [...
%            15509
%        15510
%        15517
%        15502
%        15505
%        15507];
%    
% unLabeled =    [...
%         4     4     2    17     1;
%      0     0     0    25     1;
%      0     0     0     9     1;
%      1     1     1    10    -1;
%      0     0     0    12    -1;
%      0     0     0    13    -1];
%  
% numUnlabeled = 6;
% 
% % Casting the distances in a format amenable to Gurobi/ampl/Cplex.
% iterate_k=1;
% for iterate_i=1:numUnlabeled
%     for iterate_j=1:iterate_i-1
%         C(iterate_i,iterate_j) = dists_obtained_from_GMAPquery(iterate_k,1);
%         C(iterate_j,iterate_i) = C(iterate_i,iterate_j);
%         iterate_k = iterate_k+1;
%     end
% end
% 
% C = C/100;
% save SixNodeData.mat C numUnlabeled unLabeled;
