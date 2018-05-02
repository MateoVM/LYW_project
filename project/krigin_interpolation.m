% Learn Your Way: Machine Learning for Navigation
% Project 
%
% Author: Mateo Vanoy Marin & Silvia 
% Date: 26/04/2018 
% Project: 
% Implements Ordinary Krigin interpolation to create an offline database
% for a fingerprint map (radio map). Using known RSS points from the data.
% The interpolation will be made using observation points 4529 (90% of the
% data). The remaining 500 (10% of data) points will be used for testing
% purposes.
%
% Log:
% 26/04/2018 - Creation of script 

% Clean-up work environment
clear 
close 
clc

% load training data
load train_data.mat

% Try to recreate the kriging model using one gw first
% In this case use GW 1
gateWayID = 1; %first Router
gateWayCoord = gw_coord(gateWayID,:);

% Select the data for training purposes using one GW
% In this case we leave the last 500 points for testing
trainRSSI = train_rssi(1:4529,1);
trainCoord = train_coord(1:4529,:);

%Plot gateway and observation points
% plot(trainCoord(:,1), trainCoord(:,2),'ro')
% hold on
% plot(gateWayCoord(1), gateWayCoord(2),'b*');
% hold off

% create pair points among all observation points
% and measure the semivariance  

% Calculate distances
distances = zeros(length(trainRSSI),length(trainRSSI));
% 
for i = 1:length(trainRSSI)
        distances(:,i) = sqrt((trainCoord(:,1)-trainCoord(i,1)).^2 +  (trainCoord(:,2)-trainCoord(i,2)).^2);
        %cumulativeDistances(i) = mean(distances(:,i));
end
% Calculate distances
%distances = sqrt((trainCoord(:,1)-gateWayCoord(1)).^2 +  (trainCoord(:,2)-gateWayCoord(2)).^2);
% Sort the distances
%[v idx] = sort(distances,'ascend');

%Rearrange RSS according to distances 
%for i = 1:length(v)
%    rssiOrder(i,1) = train_rssi(idx(i), gateWayID);
%end

%d = round(length(trainCoord)/420);
%num = round(length(trainCoord)/d);
% semiVariance = zeros(length(trainRSSI));
% temp = zeros(length(trainRSSI));
% for i = 1:length(trainRSSI)%num-1
%     for j = 1:length(trainRSSI)
%     % Calculate semivariance
%     %semiVariance(i) = (0.5)*(1/length(trainCoord))*(v(i+1)+v(i))^2;
%     %semiVariance(i) = (0.5)*(1/2)*((v(i+d)+v(i))^2)^2;
%     %semiVariance(i) = (0.5)*(1/length(trainCoord))*((distances(i+d)+distances(i))^2)^2;
%     %semiVariance(i) = (0.5)*(1/length(trainCoord))*((v(i+d)+v(i))^2)^2;
%     temp(:,j) = ((distances(:,i))-(distances(:,j))).^2;
%     %temp(i,j) = t';
%     %semiVariance(i) = (0.5)*(1/length(trainCoord))*(((rssiOrder(i+d))-(rssiOrder(i)))^2);
%     %di(i)=d;
%     %d=d+10;
%     end 
%     semiVariance(:,i) = (0.5)*(1/length(trainCoord))*sum(temp);
% end
semiVariance = zeros(length(trainRSSI),1);
temp = zeros(length(trainRSSI),1);
for i = 1:length(trainRSSI)%num-1
    for j = 1:length(trainRSSI)
    % Calculate semivariance
        temp(j) = (0.5)*(1/length(trainCoord))*sum((distances(:,i)-distances(:,j)).^2);
    end 
    semiVariance(i) = (0.5)*(1/length(trainCoord))*sum(temp);
end





%plot(distances(1:length(distances)-1), semiVariance', 'b*'),
plot(di, (semiVariance), '*--');
axis([0 4500 0 max(semiVariance)*1.1]);
xlabel('Distances');
ylabel('Semivariances');



