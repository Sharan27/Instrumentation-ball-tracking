%% Housekeeping
 
addpath('ximu_matlab_library');	% include x-IMU MATLAB library
addpath('quaternion_library');	% include quatenrion library
close all;                     	% close all figures
clear;                         	% clear all variables
clc;                          	% clear the command terminal
 
%% Import data

xIMUdata = xIMUdataClass('LoggedData/LoggedData');

samplePeriod = 1/200;

gyr = [xIMUdata.CalInertialAndMagneticData.Gyroscope.X...
       xIMUdata.CalInertialAndMagneticData.Gyroscope.Y...
       xIMUdata.CalInertialAndMagneticData.Gyroscope.Z];        % gyroscope
acc = [xIMUdata.CalInertialAndMagneticData.Accelerometer.X...
       xIMUdata.CalInertialAndMagneticData.Accelerometer.Y...
       xIMUdata.CalInertialAndMagneticData.Accelerometer.Z];	% accelerometer
  
% Plot
% figure('NumberTitle', 'off', 'Name', 'Gyroscope');
% hold on;
% plot(gyr(:,1), 'r');
% plot(gyr(:,2), 'g');
% plot(gyr(:,3), 'b');
% xlabel('sample');
% ylabel('dps');
% title('Gyroscope');
% legend('X', 'Y', 'Z');
% saveas(gcf,'Gyroscope.png');

% figure('NumberTitle', 'off', 'Name', 'Accelerometer');
% hold on;
% plot(acc(:,1), 'r');
% plot(acc(:,2), 'g');
% plot(acc(:,3), 'b');
% xlabel('sample');
% ylabel('g');
% title('Accelerometer');
% legend('X', 'Y', 'Z');
% saveas(gcf,'Accelerometer.png');

%% Process data through AHRS algorithm (calcualte orientation)
% See: http://www.x-io.co.uk/open-source-imu-and-ahrs-algorithms/

R = zeros(3,3,length(gyr));     % rotation matrix describing sensor relative to Earth

ahrs = MahonyAHRS('SamplePeriod', samplePeriod, 'Kp', 1);

for i = 1:length(gyr)
    ahrs.UpdateIMU(gyr(i,:), acc(i,:));	% gyroscope units must be radians
    R(:,:,i) = quatern2rotMat(ahrs.Quaternion)';    % transpose because ahrs provides Earth relative to sensor
end

%% Calculate 'tilt-compensated' accelerometer

tcAcc = zeros(size(acc));  % accelerometer in Earth frame

for i = 1:length(acc)
    tcAcc(i,:) = R(:,:,i) * acc(i,:)';
end

% % Plot
% figure('NumberTitle', 'off', 'Name', '''Tilt-Compensated'' accelerometer');
% hold on;
% plot(tcAcc(:,1), 'r');
% plot(tcAcc(:,2), 'g');
% plot(tcAcc(:,3), 'b');
% xlabel('sample');
% ylabel('g');
% title('''Tilt-compensated'' accelerometer');
% legend('X', 'Y', 'Z');
% saveas(gcf,'Tilt-compensated_accelerometer.png');

%% Calculate linear acceleration in Earth frame (subtracting gravity)

linAcc = tcAcc - [zeros(length(tcAcc), 1), zeros(length(tcAcc), 1), ones(length(tcAcc), 1)];
% linAcc = linAcc * 9.81;     % convert from 'g' to m/s/s

% % Plot
% figure('NumberTitle', 'off', 'Name', 'Linear Acceleration');
% hold on;
% plot(linAcc(:,1), 'r');
% plot(linAcc(:,2), 'g');
% plot(linAcc(:,3), 'b');
% xlabel('sample');
% ylabel('g');
% title('Linear acceleration');
% legend('X', 'Y', 'Z');
% saveas(gcf,'Linear_acceleration.png');

%% Calculate linear velocity (integrate acceleartion)

linVel = zeros(size(linAcc));

for i = 2:length(linAcc)
    linVel(i,:) = linVel(i-1,:) + linAcc(i,:) * samplePeriod;
end
% 
% % Plot
% figure('NumberTitle', 'off', 'Name', 'Linear Velocity');
% hold on;
% plot(linVel(:,1), 'r');
% plot(linVel(:,2), 'g');
% plot(linVel(:,3), 'b');
% xlabel('sample');
% ylabel('g');
% title('Linear velocity');
% legend('X', 'Y', 'Z');
% saveas(gcf,'Linear_Velocity.png');

%% (FILTER CHANGED) High-pass filter linear velocity to remove drift 

order = 1;
filtCutOff = 0.1;
[b, a] = butter(order, (2*filtCutOff)/(1/samplePeriod), 'high');
linVelHP = filtfilt(b, a, linVel);

% % Plot
% figure('NumberTitle', 'off', 'Name', 'High-pass filtered Linear Velocity');
% hold on;
% plot(linVelHP(:,1), 'r');
% plot(linVelHP(:,2), 'g');
% plot(linVelHP(:,3), 'b');
% xlabel('sample');
% ylabel('g');
% title('High-pass filtered linear velocity');
% legend('X', 'Y', 'Z');
% saveas(gcf,'High-pass_filtered_Linear_Velocity.png');

%% Calculate linear position (integrate velocity)

linPos = zeros(size(linVelHP));

for i = 2:length(linVelHP)
    linPos(i,:) = linPos(i-1,:) + linVelHP(i,:) * samplePeriod;
end
% 
% % Plot
% figure('NumberTitle', 'off', 'Name', 'Linear Position');
% hold on;
% plot(linPos(:,1), 'r');
% plot(linPos(:,2), 'g');
% plot(linPos(:,3), 'b');
% xlabel('sample');
% ylabel('g');
% title('Linear position');
% legend('X', 'Y', 'Z');
% saveas(gcf,'Linear_position.png');

%% High-pass filter linear position to remove drift

order = 1;
filtCutOff = 0.1;
[b, a] = butter(order, (2*filtCutOff)/(1/samplePeriod), 'high');
linPosHP = filtfilt(b, a, linPos);


% 
% % Plot
% figure('NumberTitle', 'off', 'Name', 'High-pass filtered Linear Position');
% hold on;
% plot(linPosHP(:,1), 'r');
% plot(linPosHP(:,2), 'g');
% plot(linPosHP(:,3), 'b');
% xlabel('sample');
% ylabel('g');
% title('High-pass filtered linear position');
% legend('X', 'Y', 'Z');
% saveas(gcf,'High-pass_filtered_linear_position.png');

%Finding pitch
% M = max(tcAcc, [], 1)
% I = find(tcAcc == M)
[m,index]=max(tcAcc)

%Samplpes run
[pks,locs] = findpeaks(tcAcc(:,3));
format long g;
C = horzcat(locs,pks);
indices = find(C(:,2)<10 & C(:,2)>9.6);
C(indices) = NaN


%Total time calc

index_of_first = C(find_ndim(~isnan(C(:,1)),1,'first'),1)
index_of_last = C(find_ndim(~isnan(C(:,1)),1,'last'),1)
release_sample = C(find(C(:,2)>11, 1, 'first'),1)
% index_of_last  = C(find(isnan(C(:,1)), 1, 'last') -1,1)
total_time = (index_of_last - release_sample)/273;

%Flight time calc
flight_time = (index(3)-release_sample)/273
hold on;
plot(locs,pks,"o");
xlabel("Samples");
ylabel("Peak");
axis tight;
legend(["Data" "peaks"]);

%Average speed
avspeed = 22/flight_time;

%Pitch distance av
flight_avs = 0;
for k = release_sample:index(3)
    flight_avs = flight_avs + linVelHP(k,:);
end
flight_avs = flight_avs/(index(3)-release_sample);
pd_all = flight_avs * flight_time;


%Release speed
avrs = 0;
count = 0;
for j = 0:100
    if(j+release_sample <= length(linVelHP))
        avrs = avrs + linVelHP(release_sample+j,:);
        count = count + 1;
    else
        break
    end 
end
avrs = avrs/count;
x = avrs(1,1);
y=avrs(1,2);
z = avrs(1,3);
resrs = sqrt(x.^2+y.^2+z.^2)
ax = atan2(sqrt(y^2+z^2),x);
ay = atan2(sqrt(z^2+x^2),y);
az = atan2(sqrt(x^2+y^2),z);
tetrs = [ax,ay,az]*(180/pi)



%Speed after pitch
avap = 0;
count = 0;
for j = 0:100
    if(j+index(3) < length(linVelHP))
       avap = avap + linVelHP(index(3)+j,:);
       count = count + 1;
    else
        break
    end 
    
end
avap = avap/count;
x = avap(1,1);
y=avap(1,2);
z = avap(1,3)
resap = sqrt(x.^2+y.^2+z.^2)
ax = atan2(sqrt(y^2+z^2),x);
ay = atan2(sqrt(z^2+x^2),y);
az = atan2(sqrt(x^2+y^2),z);
tetap = [ax,ay,az]*(180/pi)
% xy = (av(1,3))/(sqrt(av(1,1).^2+av(1,2).^2));
% xz = (av(1,2))/(sqrt(av(1,1).^2+av(1,3).^2));
% yz = (av(1,1))/(sqrt(av(1,2).^2+av(1,3).^2));
% tet = [(atan(xy)*180)/pi,(atan(xz)*180)/pi,(atan(yz)*180)/pi]


%Spin calc
S = zeros(3,1);
for i = 1:3
    A = gyr(:,i);
    t = (1:length(gyr(:,i)))' ;
    count1 = sum(gyr(:,i) > 0.2);
    count2 = sum(gyr(:,i) < -0.2);
    % Positive Area
    
    Ap = A ;
    Ap(A<=0) = 0 ; 
    B=trapz(t,Ap)/count1;
    
    % Negative Area
    An=A;
    An(A>=0) = 0 ; 
    C=trapz(t,An)/count2;
    % subplot(2,1,1);
    % plot(Ap);
    % subplot(2,1,2);
    % plot(An);
    S(i) = [B+C];
end   
S

filename = 'variables.xlsx'; 
filename2 = 'params.txt';
column_names = {'Flight time(s)', 'Avergae speed(m\s)','Spin X(rps)', 'Spin Y(rps)', 'Spin Z(rps)', 'Release speed(Rs)', 'Release angle(Alpha)','Release angle(Beta)','Release angle(Gamma)', 'Speed after Pitch(Rp)', 'Pitch Angle(Alpha)','Pitch Angle(Beta)','Pitch Angle(Gamma)', 'Pitch Distance(m)', 'Pitch Width(m)', 'Total Time(s)'};
data = {flight_time, avspeed,S,resrs,tetrs,resap,tetap,pd_all(1,1), pd_all(1,2), total_time};
writecell(column_names, filename, 'Sheet', 1, 'Range', 'A1');
writecell(data, filename, 'Sheet', 1, 'WriteMode','append');
newStr = strcat(string(avspeed),",",string(flight_time),",",string(resrs),",",string(resap))
writelines(newStr,filename2);




 
% Play animation

  SamplePlotFreq = 8;

  SixDOFanimation(linPosHP, R, ...
               'SamplePlotFreq', SamplePlotFreq, 'Trail', 'Off', ...
               'Position', [9 39 1280 720], ...
               'AxisLength', 0.1, 'ShowArrowHead', false, ...
               'Xlabel', 'X (m)', 'Ylabel', 'Y (m)', 'Zlabel', 'Z (m)', 'ShowLegend', false, 'Title', 'Unfiltered',...
                'CreateAVI', true, 'AVIfileNameEnum', false, 'AVIfps', ((1/samplePeriod) / SamplePlotFreq));            
%% End of script