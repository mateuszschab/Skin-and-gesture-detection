clear all;
close all;
detected_fingers = [];
time_circle = [];
time_counting_finger = [];
time_mask = [];
time_centroid = [];

ID = ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"];

for num = 1:length(ID)
img_rgb = imread("original_images\1_P_hgr1_id"+ID(num)+"_1.jpg");
img_hsv = rgb2hsv(img_rgb);
img_hsv_logical = img_hsv;
res = size(img_hsv);

tic
for i = 1:res(1)
    for j = 1:res(2)
        if (img_hsv(i,j,1) >= 0.9 || img_hsv(i,j,1) <= 0.1) && (img_hsv(i,j,2) >= 0.2 && img_hsv(i,j,2) <= 0.6) && img_hsv(i,j,3) >= 0.4
            img_hsv(i,j,:) = 1;
        else
            img_hsv(i,j,:) = 0;
        end
    end
end
timer_1 = toc;

fprintf("Czas obliczeń przy użyciu pętli: %.5f\n",timer_1)

tic
idx = (img_hsv_logical(:,:,1) >= 0.9 | img_hsv_logical(:,:,1) <= 0.1) & (img_hsv_logical(:,:,2) >= 0.2 & img_hsv_logical(:,:,2) <= 0.6) & img_hsv_logical(:,:,3) >= 0.4;
hsv_logical = cat(3,idx,idx,idx);
hsv_logical = double(hsv_logical);
timer_2 = toc;
time_mask(end+1) = timer_2;
fprintf("Czas obliczeń przy użyciu macierzy logicznej: %.5f\n",timer_2)

imshow(hsv_logical)

% ZADANIE NR 3
axis on
hold on
number_of_ones = sum(idx(:) == 1);
x_coords = zeros(1,number_of_ones);
y_coords = zeros(1,number_of_ones);
it = 1;
tic
for i = 1:res(1)
    for j = 1:res(2)
        if idx(i,j) == 1
            x_coords(it) = i;
            y_coords(it) = j;
            it=it+1;
        end
    end
end
time_centroid(end+1) = toc;
sum_x = sum(x_coords(:));
sum_y = sum(y_coords(:));
x_centroid = int32(sum_x / number_of_ones);
y_centroid = int32(sum_y / number_of_ones);

plot(y_centroid,x_centroid, 'r+', 'MarkerSize', 30, 'LineWidth', 2);
hold on;


% Lab gesty


radius = width(idx)/8.75;

value = [];

x_line = [];
y_line = [];

th = 0:pi/1000:2*pi;

tic
for i =1:length(th)

x = radius * cos(th(i)) + x_centroid;
y = radius * sin(th(i)) + y_centroid;

        value(1,end+1) = idx(x,y);
        x_line(1,end+1) = x;
        y_line(1,end+1) = y;
end

time_circle(end+1) = toc;

plot(x_line,y_line);
hold on;
plot(x_line(1),y_line(1),'b.', 'MarkerSize', 40, 'LineWidth', 2);
hold on;
legend("Centroid","Circle","Start point");


counter_1 = 0;
counter_0 = 0;
finger = 0;

% Base version

% for i = 1:length(value)
%     if value(i) == 1
%         counter_1 = counter_1 + 1;
%     elseif value(i) == 0
%         if counter_1 ~= 0
%             finger = finger +1;
%             counter_1 = 0;
%         else
%             continue
%         end
%     end
%     detected_fingers(1) = finger - 1;
% end

% % Ominięcie wybranej ilości zer zer
counter_0 + 1;

tic
for i = 1:length(value)
    if value(i) == 1
        counter_1 = counter_1 + 1;
        counter_0 = 0;
        
        
    elseif value(i) == 0
        
        counter_0 = counter_0 + 1;
        
        if (counter_1 ~= 0) && (counter_0 == 20)
            finger = finger +1;
            counter_1 = 0;
        else
            continue
        end
    end
    detected_fingers(num) = finger - 1;
end

time_counting_finger(end+1) = toc;



plot_x = [1:1:width(value)];
figure()
plot(plot_x,value);
ylim([0 2]);
end
