clear 
close all
clc

%% Generate some data
distance = [10:10:1000]; %Dsiatnce in meter every 10m
P0 = -40; %Need to estmate to start 
np = 2.5; 
var_rssi = 3; %dBm - Variance
rssi = P0 - 10*np*log10(distance) + sqrt(var_rssi)*randn(size(distance)); %Gaussian process with zero mean
figure()
plot(distance,rssi);
xlabel('Distance [m]')
ylabel('Rssi [dBm]')
grid on
%Need to Estimate to start np P0 fro path loss model
%% estimate model parameters using least squares
rho = rssi';
%create H matrix
H = [ones(length(rho),1) -10*log10(distance')]; 
%apply least squares solution
theta = inv(H'*H)*H'*rho;
hold on
plot(distance,theta(1)-theta(2)*10*log10(distance),'--r')

%% Put some anchors and the target around and plot them
% 3 or 4 reference stations 
anchors = [0 0; 500 0; 0 500; 500 500];
target = 150+300*rand(1,2);
%distances from target to each anchor note
d = sqrt((target(1)-anchors(:,1)).^2 + (target(2)-anchors(:,2)).^2);
figure()
plot(target(1),target(2),'xr');
hold on
plot(anchors(:,1),anchors(:,2),'ob')
grid on

%% simulate rss measurements at/from the anchors
rho = P0 - 10*np*log10(d) + sqrt(var_rssi)*randn(size(d));%last component is random noise
d_est = 10.^((theta(1)-rho)./(10*theta(2)));

%% LS Localization using grid search
for i=1:500
    for j=1:500
        % for each point in the 500x500 area evaluate the cost function
        d = sqrt((i-anchors(:,1)).^2 + (j-anchors(:,2)).^2);
        J(j,i) = sum((d-d_est).^2);
        
        %weighted LS
        w = 1./(d_est.^2);
        w = w./sum(w);
        
        Jw(j,i) = sum(w.*((d-d_est).^2));
    end
end
%retrieve coordinates from the cost function
idx = find(J==min(min(J)));
[a,b] = ind2sub(size(J),idx);
est_target_ls = [b a];
plot(b,a,'og')

idx = find(Jw==min(min(Jw)));
[aw,bw] = ind2sub(size(Jw),idx);
est_target_lsw = [bw aw];
plot(bw,aw,'om')


%% fingerprint: assume to sample the space every 25 meter (that's cumbersome!)
idx_f = 1;
for i=1:10:500
    for j=1:10:500
        
        d = sqrt((i-anchors(:,1)).^2 + (j-anchors(:,2)).^2);
        FINGERPRINT_DB(idx_f,:) = P0 - 10*np*log10(d) + sqrt(var_rssi)*randn(size(d));
        FINGERPRINT_POS(idx_f,:) = [i j];
        idx_f = idx_f + 1;
    end
end

%% apply neareast neighbor fingerprint 
%instead of computing the distance line by line, let's use a built in
%Nearest finger print localization 
%Algorithm indexing and clean search
%Distances calculations can be eucledian, cosine similarity, L-1 norm
%function
%optimise distance calculations and can choose different calculation methods 
fingerprint_distance = pdist2(rho',FINGERPRINT_DB,'euclidean');
[min_similarity, idx] = min(fingerprint_distance);
est_target_fingerprint = FINGERPRINT_POS(idx,:);

plot(est_target_fingerprint(1),est_target_fingerprint(2),'oc')
legend('Real position','Anchors','LS Estimated position','wLS Estimated position','Fingerprint estimated position');
xlabel('x')
ylabel('y')


figure()
mesh(J)
xlabel('x')
ylabel('y')
colormap('jet')
hold on
plot3(target(1),target(2),50000,'xr','markersize',8,'linewidth',2)
plot3(b,a,50000,'og','markersize',8,'linewidth',2)
%plot3(bw,aw,50000,'om','markersize',8,'linewidth',2)
%plot3(est_target_fingerprint(1),est_target_fingerprint(2),50000,'oc','markersize',8,'linewidth',2)
legend('Cost function','Real Position','Estimated position with LS','location','southeast');


figure()
mesh(Jw)
xlabel('x')
ylabel('y')
colormap('jet')
hold on
plot3(target(1),target(2),50000,'xr','markersize',8,'linewidth',2)
%plot3(b,a,50000,'og','markersize',8,'linewidth',2)
plot3(bw,aw,50000,'om','markersize',8,'linewidth',2)
%plot3(est_target_fingerprint(1),est_target_fingerprint(2),50000,'oc','markersize',8,'linewidth',2)
legend('Cost function','Real Position','Estimated position with wLS','location','southeast');

%Path loss is better for non-controlled environment
%fingerprinting 






