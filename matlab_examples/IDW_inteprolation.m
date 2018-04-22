clear 
close 
clc

load train_data.mat

[X,Y] = meshgrid(-3000:100:3000,-3000:100:3000);
x = X(:);
y = Y(:);
interp_coord = [x y];
GATEWAY_ID = 1;
%Usually 3 to 5 neighbours is enough or can even add a treshold for
%distances

for i = 1:length(interp_coord)
    
    %current point in the grid
    current_point = interp_coord(i,:);
    
    %find nearest observation point in train coord
    distances = sqrt( (current_point(1)-train_coord(:,1)).^2 +  (current_point(2)-train_coord(:,2)).^2);
    
    %sort the distances
    [v idx] = sort(distances,'ascend');
    
    %take the k closest observations
    k = 5;
    p = 2;
    w = v(1:k).^(-p) ./ sum(v(1:k).^(-p));
    interpolated_rssi(i) = w'*train_rssi(idx(1:k),GATEWAY_ID); %consider only first gateway (column)
    
end

%plot the interpolated radio map
figure()
interpolated_map = reshape(interpolated_rssi,61,61);
surf(X,Y,interpolated_map)
hold on
plot(gw_coord(GATEWAY_ID,1),gw_coord(GATEWAY_ID,2),'xk')
xlabel('x')
ylabel('y')

%plot(train_coord(:,1),train_coord(:,2),'or')