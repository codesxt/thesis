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
sensor_stddev = 0.5;
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
r = unifrnd(0.1,10);
fin = 0;
p = 0;
j = 0;
while(fin==0)
  j+=1;
  hs = [r-0.001 r r+0.001];
  for i=1:3
    xi = hs(i)*sensor_samples;
    sc(i)=mean(gaussian(xi, visual_samples, 3));
  endfor

  d = (sc(3)-sc(2))/(0.002);
  [m id]=max(sc);
  %r = hs(id)
  p = r;
  r = r + 10*d
  plt(j)=r;
  if(p-r <= 0.0001)
    fin=1;
    break;
  endif
endwhile
plot(plt)
#{
hs = 0.1:0.01:10;
nhs=size(hs)(2);
for i=1:1:nhs
  x_i = hs(i)*sensor_samples;
  gs(i)=mean(gaussian(x_i, visual_samples, 3));
  i;
endfor

figure(1)
hold on;
plot(hs, gs, '-r');
legend('scores');
hold off;



h1 = unifrnd(0.1,5)


% First E-Step
x_i = h1*visual_samples;
loglik = log(gaussian(x_i, sensor_samples, 3));
loglik = loglik + abs(min(loglik(:)));

% Likelihood filtering
aregood = (abs(visual_samples) > 0.5) | (abs(sensor_samples) > 0.5);
loglik = loglik.*aregood;

% First M-Step
loglik = normalize(loglik);
h = sum((visual_samples./sensor_samples).*loglik)

est_ind = 1;
estimates(est_ind) = h1;
est_ind = est_ind+1;
estimates(est_ind) = h;
est_ind = est_ind+1;

h_p = h1;
while(abs(h - h_p) > 0.00001)
  % E-Step
  h_p = h;
  x_i = h*visual_samples;
  loglik = log(gaussian(x_i, sensor_samples, 3));
  loglik = loglik + abs(min(loglik(:)));

  % Likelihood filtering
  aregood = (abs(visual_samples) > 0.5) | (abs(sensor_samples) > 0.5);
  loglik = loglik.*aregood;

  % M-Step
  loglik = normalize(loglik);
  h = sum((visual_samples./sensor_samples).*loglik)

  estimates(est_ind) = h;
  est_ind = est_ind+1;
endwhile

e = mse(h*visual_samples, sensor_samples);
file_id = fopen('results', 'a');
fdisp(file_id, strcat([num2str(h, 8), ' ', num2str(est_ind-1), ' ', num2str(e)]));
fclose(file_id);
%save_header_format_string('')
%save -text 'results' 'h'


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
#}
