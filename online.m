format long
%==================================================%
%=====Parameter optimization with EM-Algorithm=====%
%==================================================%
%=================Data Generation==================%
% t is time in seconds
% alpha is the sin factor
% h is the scale factor
t = 20;
alpha = 0.3;
offset = 0.001;
h = 2;
visual_stddev = 0.5;
rwalk_stddev = 0.001;
sensor_stddev = 1;
frame_size = 30;

real_data = sin(alpha.*[0:offset:t-offset]);
visual_data = h*normrnd(real_data, visual_stddev);
random_walk(1)=normrnd(0,rwalk_stddev);
for i=2:(t/offset)
  random_walk(i)=normrnd(random_walk(i-1), rwalk_stddev);
endfor
sensor_data = normrnd(real_data+random_walk, sensor_stddev);

%==================================================%
k = 30; % Size of window for samples in ms
ind=1;
for i=k:k:(t/offset)
  visual_samples(ind) = visual_data(i);
  sensor_samples(ind) = sum(sensor_data(i-k+2:2:i))/(k/2);
  real_samples(ind) = real_data(i);
  ind=ind+1;
endfor

%==================================================%
%==========Application of EM-Algorithm=============%
n_obs = size(visual_samples)(2)
h = unifrnd(0.1,10);

has_converged = 0;
conv_id = 0;
conv_val = 0;
for k=frame_size:n_obs
  visual_frame = visual_samples(k-frame_size+1:k);
  sensor_frame = sensor_samples(k-frame_size+1:k);

  hs = [h-0.001 h h+0.001];
  for i=1:3
    xi = hs(i)*sensor_samples;
    score(i)=mean(gaussian(xi, visual_samples, 3));
  endfor

  h_p = h;
  d = (score(3)-score(2))/(0.002);
  h = h + 10*d;

  if((abs(h_p-h) < 0.00001) && (has_converged == 0))
    conv_id = k-frame_size;
    conv_val = h;
    has_converged = 1;
  endif
  plt(k-frame_size+1)=h;
endfor

h
conv_id
e = mse(h*visual_samples, sensor_samples);
file_id = fopen('results', 'a');
fdisp(file_id, strcat([num2str(conv_val, 8), ' ', num2str(conv_id), ' ', num2str(e)]));
fclose(file_id);

figure(1)
hold on;
plot(frame_size:n_obs, plt, '-r');
plot([frame_size, n_obs], [2, 2], '-b');
legend('Scale estimation', 'Real scale');
xlabel('Iterations');
ylabel('lambda');
hold off;
