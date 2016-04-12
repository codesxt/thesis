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
visual_stddev = 0.1;
rwalk_stddev = 0.001;
sensor_stddev = 0.01;
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
n_obs = size(visual_samples)(2);
h = unifrnd(0.1,10);
j=0;
fin=0;
while(fin==0)
  j++;
  hs = [h-0.001 h h+0.001];

  for i=1:3
    xi = hs(i)*sensor_samples;
    score(i)=mean(gaussian(xi, visual_samples, 3));
  endfor

  d = (score(3)-score(2))/(0.002);

  prev_est = h;
  h = h + 1*d;
  plt(j)=h;
  if(prev_est - h <= 0.00001)
    fin=1;
    break;
  endif
endwhile

h
e = mse(h*visual_samples, sensor_samples);
file_id = fopen('results', 'a');
fdisp(file_id, strcat([num2str(h, 8), ' ', num2str(j), ' ', num2str(e)]));
fclose(file_id);

figure(1)
hold on;
plot(1:j, plt, '-r');
plot([1, j], [2, 2], '-b');
legend('Scale estimation', 'Real scale');
xlabel('Iterations');
ylabel('lambda');
hold off;
