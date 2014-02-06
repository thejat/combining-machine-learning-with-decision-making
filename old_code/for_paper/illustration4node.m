%4 node
%clc;
close all;
clear all;

e12 = 1;
e13 = 0.8;
e23 = 1;
e34 = 1.2;
e24 = 1.4;
e14 = 2;

path(1,:) = [e12+e23+e34+e14   e12   e12+e23   e12+e23+e34];
path(2,:) = [e13+e23+e24+e14   e13   e13+e23   e13+e23+e24];
path(3,:) = [e12+e24+e34+e13   e12   e12+e24   e12+e24+e34];
path(4,:) = [e13+e34+e24+e12   e13   e13+e34   e13+e34+e24];
path(5,:) = [e14+e24+e23+e13   e14   e14+e24   e14+e24+e23];
path(6,:) = [e14+e34+e23+e12   e14   e14+e34   e14+e34+e23];


p2arr = [0.7*4 0.6*4]; % between 2 to 6
p3arr = [1.2*4 1.1*4]; %between 2 to 6

for i=1:length(p2arr)
    proba(:,1) = [1/8 p2arr(i)/8 p3arr(i)/8 1/8]';
    proba(:,2) = [1/8 p3arr(i)/8 p2arr(i)/8 1/8]';
    proba(:,3) = [1/8 p2arr(i)/8 1/8 p3arr(i)/8]';
    proba(:,4) = [1/8 p3arr(i)/8 1/8 p2arr(i)/8]';
    proba(:,5) = [1/8 1/8 p2arr(i)/8 p3arr(i)/8]';
    proba(:,6) = [1/8 1/8 p3arr(i)/8 p2arr(i)/8]';
    
    for k=1:6
        val(k,i) = path(k,:)*proba(:,i);
    end
end
%find(min(val(4,:))==val(4,:))


%mar 18 2011: works> check the val matix 2nd and 4th rows corresponding to
%the two paths in the 4 node example.