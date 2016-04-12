format long
%==================================================%
%=====Parameter optimization with EM-Algorithm=====%
%==================================================%
%=================Data Generation==================%
% t is time in seconds
% alpha is the sin factor
% h is the scale factor
disp('Setting up parameters')
t = 100;
alpha = 0.3;
offset = 0.001;
h = 2;
visual_stddev = 0.1;
rwalk_stddev = 0.001;
sensor_stddev = 0.05;

disp('Generating data')
real_data = sin(alpha.*[0:offset:t-offset]);
visual_data = h*normrnd(real_data, visual_stddev);
random_walk(1)=normrnd(0,rwalk_stddev);
for i=2:(t/offset)
  random_walk(i)=normrnd(random_walk(i-1), rwalk_stddev);
endfor
sensor_data = normrnd(real_data+random_walk, sensor_stddev);

%==================================================%
disp('Sampling data')
k = 30; % Size of window for samples in ms
ind=1;
for i=k:k:(t/offset)
  visual_samples(ind) = visual_data(i);
  sensor_samples(ind) = sum(sensor_data(i-k+2:2:i))/(k/2);
  real_samples(ind) = real_data(i);
  ind=ind+1;
endfor

disp('Starting estimation')
%==================================================%
%==========Application of EM-Algorithm=============%
n_obs = size(visual_samples)(2)
h = unifrnd(0.1,5)
frame_size = 100;

for k=frame_size:n_obs
  %disp([k-frame_size+1 k])
  visual_frame = visual_samples(k-frame_size+1:k);
  sensor_frame = sensor_samples(k-frame_size+1:k);

  % First E-Step
  x_i = h*visual_frame;
  loglik = log(gaussian(x_i, sensor_frame, 3));
  loglik = loglik + abs(min(loglik(:)));

  % Likelihood filtering
  aregood = (abs(visual_frame) > 0.5) | (abs(sensor_frame) > 0.5);
  loglik = loglik.*aregood;

  % First M-Step
  loglik = normalize(loglik);
  h = sum((visual_frame./sensor_frame).*loglik);

  h_p = h;
  while(abs(h - h_p) > 0.00001)
    % E-Step
    h_p = h;
    x_i = h*visual_frame;
    loglik = log(gaussian(x_i, sensor_frame, 3));
    loglik = loglik + abs(min(loglik(:)));

    % Likelihood filtering
    aregood = (abs(visual_frame) > 0.5) | (abs(sensor_frame) > 0.5);
    loglik = loglik.*aregood;

    % M-Step
    loglik = normalize(loglik);
    h = sum((visual_frame./sensor_frame).*loglik);
  endwhile

  estimates(k) = h;
endfor

e = mse(h*visual_samples, sensor_samples);
file_id = fopen('online-results.csv', 'a');
fdisp(file_id, strcat([num2str(h, 8), ',', num2str(e)]));
fclose(file_id);
%save_header_format_string('')
%save -text 'results' 'h'

disp('Displaying results')
figure(1)
hold on;
plot(visual_data, '-r');
plot(sensor_data, '-g');
plot(real_data, '-k', 'linewidth', 2);
legend('Datos de SLAM', 'Datos del Sensor', 'Altura Real');
hold off;

figure(2)
hold on;
plot(visual_samples, '-r');
plot(sensor_samples, '-b');
legend('Muestras de SLAM', 'Muestras del sensor')
hold off;

figure(3)
hold on;
plot(visual_samples/h, '-r');
plot(sensor_samples, '-b');
plot(real_samples, '-k', 'linewidth', 2);
legend('Datos de SLAM escalados', 'Datos del Sensor', 'Altura Real');
hold off;

figure(4)
hold on;
plot([1:n_obs], estimates, '-b')
legend('Scale estimates')
hold off;
