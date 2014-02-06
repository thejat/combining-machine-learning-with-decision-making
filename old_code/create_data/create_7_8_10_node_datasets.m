%Choosing 10 nodes from a grid selected arbitrarily 2011-01-30




%Additional Information : Using G-Earth
% long
% lat
% 
% sw
% 73°55'33.60"W
%  40°49'32.02"N
% 
% 40.82556
% -73.92583
% 
%  73°54'35.87"W
%  40°49'32.02"N
% 
% 
% ne
%  73°54'35.87"W
%  40°50'6.37"N
% 
% 40.835
% -73.91
% 
% 
%  73°55'33.60"W
%  40°50'6.37"N
% 
% 
% Need all coordinates between these two points:
% step 1: all points betweenn -73.91 to -73.92583
% 
% step 2: among these, all points between 40.82556 and 40.835


clc;
clear all;
close all;

load ../data/input/bronx/StructureListFixedCablesRenamed.mat
load ../data/input/bronx/dat_0.mat;

format long

indexInRangeLat = find( (strLat <= 40.835) & (strLat >= 40.82556));

a_o = [strId(indexInRangeLat) strLat(indexInRangeLat) strLon(indexInRangeLat)]; 
trainingdata_o = [xTrain_o(indexInRangeLat,:) yTrain_o(indexInRangeLat)];
testdata_o = [xTest_o(indexInRangeLat,:) yTest_o(indexInRangeLat)];

indexInRangeLatLon = find( (a_o(:,end) <= -73.91) & (a_o(:,end) >= -73.92583));

a = a_o(indexInRangeLatLon,:);
trainingdata = trainingdata_o(indexInRangeLatLon,:);
testdata = testdata_o(indexInRangeLatLon,:);

posIndicesTrain = find(trainingdata(:,end) == 1);
%posIndicesTest = find(testdata(:,end) == 1);

indexHandpick = [posIndicesTrain' 20 610  660 675];

M = 10;
latM            = zeros(M,1)';
longM           = zeros(M,1)';
latM     = a(indexHandpick, 2); % the second colum has lat values
longM   =  a(indexHandpick,3); % the third column has long values


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
filename = ['coordinates10.js'];
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

dists_obtained_from_GMAPquery = [...
1058 135;
1027 159;
733 106;
1629 199;
595 114;
601 40;
1015 159;
745 106;
12 1;
614 41;
41 4;
185 55;
1072 164;
780 174;
1060 164;
1364 224;
283 57;
608 104;
470 88;
620 104;
1323 221;
1664 276;
731 177;
738 130;
484 91;
750 130;
1623 273;
734 167;
1330 213;
1268 218;
535 112;
1137 152;
523 112;
1289 210;
968 173;
579 109;
1464 248;
782 171;
488 90;
652 106;
500 90;
1423 245;
483 113;
475 86;
253 45];


numUnlabeled = 10;
unLabeled = testdata(indexHandpick,:);
%save TenNodeData_full.mat numUnlabeled unLabeled dists_obtained_from_GMAPquery;

%% Create 7,8, 10 node datasets from above


unLabeled_10node = unLabeled; clear unLabeled;

dists_obtained_from_GMAPquery = dists_obtained_from_GMAPquery/100;
% Casting the distances in a format amenable to Gurobi/ampl/Cplex.
iterate_k=1;
for iterate_i=1:numUnlabeled
    for iterate_j=1:iterate_i-1
        C_10node(iterate_i,iterate_j) = dists_obtained_from_GMAPquery(iterate_k,1);
        C_10node(iterate_j,iterate_i) = C_10node(iterate_i,iterate_j);
        iterate_k = iterate_k+1;
    end
end

%% 10 node data
C = C_10node;
numUnlabeled = 10;
unLabeled = unLabeled_10node;
save TenNodeData.mat C numUnlabeled unLabeled;
clear unLabeled C numUnlabeled;
%% 7 node data
numUnlabeled = 7;
unLabeled = [unLabeled_10node(1:6,:); unLabeled_10node(9,:)] ;
C = zeros(numUnlabeled,numUnlabeled);
C(1:6,1:6) = C_10node(1:6,1:6);
C(7,1:6) = C_10node(9,1:6);
C(1:6,7) = C(7,1:6)';

save SevenNodeData.mat C numUnlabeled unLabeled;
clear unLabeled C numUnlabeled;

%% 8 node data
numUnlabeled = 8;
unLabeled = [unLabeled_10node(1:6,:); unLabeled_10node(8:9,:)] ;
C = zeros(numUnlabeled,numUnlabeled);
C(1:6,1:6) = C_10node(1:6,1:6);
C(7,1:6) = C_10node(8,1:6);
C(1:6,7) = C(7,1:6)';
C(8,1:6) = C_10node(9,1:6);
C(8,7)   = C_10node(9,8);
C(1:6,8) = C(8,1:6)';
C(7,8) = C(8,7);

save EightNodeData.mat C numUnlabeled unLabeled;
clear unLabeled C numUnlabeled;

