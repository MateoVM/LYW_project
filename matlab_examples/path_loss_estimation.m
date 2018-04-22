clear
close all
clc

load train_data.mat
for GW_ID = 1:10

%compute gw-sensor distances
distances = sqrt((gw_coord(GW_ID,1)-train_coord(:,1)).^2 + (gw_coord(GW_ID,2)-train_coord(:,2)).^2);

%plot distance vs rssi
figure()
plot(distances,train_rssi(:,GW_ID),'ob')
hold on

%estimate path loss model
rho = train_rssi(:,GW_ID);
H = [ones(length(rho),1) -10*log10(distances)];
theta = inv(H'*H)*H'*rho;

%plot estimation... not very nice
plot(distances,theta(1)-theta(2)*10*log10(distances),'or')

%second estimation, removing floor samples at - 130
distances(rho<-120) = [];
rho(rho<-120) = [];
H = [ones(length(rho),1) -10*log10(distances)];
theta = inv(H'*H)*H'*rho

plot(distances,theta(1)-theta(2)*10*log10(distances),'og')
xlabel('distance [m]')
ylabel('RSSI [dBm]')
legend('All observations','only > -120')
end
