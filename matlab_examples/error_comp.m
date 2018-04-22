clear
close all
clc

%% Generate some data
distance = [10:10:1000];
P0 = -40;
np = 2.5;
var_rssi = 3;
rssi = P0 - 10*np*log10(distance) + sqrt(var_rssi)*randn(size(distance));

%% estimate model parameters using least squares
rho = rssi';
%create H matrix
H = [ones(length(rho),1) -10*log10(distance')];
%apply least squares solution
theta = inv(H'*H)*H'*rho;

%% Put some anchors and the target around and plot them
anchors = [0 0; 500 0; 0 500; 500 500];

for it = 1:100
    target = 150+300*rand(1,2);
    d = sqrt((target(1)-anchors(:,1)).^2 + (target(2)-anchors(:,2)).^2);
 
    %% simulate rss measurements at/from the anchors
    rho = P0 - 10*np*log10(d) + sqrt(var_rssi)*randn(size(d));
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
    
    idx = find(Jw==min(min(Jw)));
    [aw,bw] = ind2sub(size(Jw),idx);
    est_target_lsw = [bw aw];    
    
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
    %function
    fingerprint_distance = pdist2(rho',FINGERPRINT_DB,'euclidean');
    [min_similarity, idx] = min(fingerprint_distance);
    est_target_fingerprint = FINGERPRINT_POS(idx,:);
    
    err_ls(it) = norm(target-est_target_ls,2);
    err_wls(it) = norm(target-est_target_lsw,2);
    err_fp(it) = norm(target-est_target_fingerprint,2);
    
    %it = it+1;
end
%PMF and CDF to show the distribution
cdfplot(err_ls)
hold on
cdfplot(err_wls)
cdfplot(err_fp)
xlabel('error [m]');
xlabel('Probability');
legend('LS','WLS','FP');






