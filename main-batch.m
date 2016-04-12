%==================================================%
%=====Parameter optimization with EM-Algorithm=====%
%==================================================%
%=================Data Generation==================%
sigma_x = 0.01;       % Real data sigma
sigma_y_1 = 0.01;      % Metric data sigma
sigma_y_2 = 0.05;      % Visual data sigma
h_1 = 0.9;            % Metric data scale
h_2 = 2;              % Visual data scale
time=20;
data = real_data(sigma_x, time);
metric_data = scaled_data(data, h_1, sigma_y_1);
visual_data = scaled_data(data, h_2, sigma_y_2);

%===============Parameter Proposal=================%
% h1: Scale of the visual measurements. It is
%     assumed in the range of 0 to 5
% h2: Scale of metric measurements. It is assumed as
%     gaussian centered in 1 but with sigma=0.1 due
%     to drift.
% sigma_x: Standard deviation of the real height
%     distribution.
% sigma_y: Standard deviation of measured height (sum
%     of metric and visual standard deviations)
h1 = unifrnd(0,5);
h2 = normrnd(1,0.1);
h = [h1 h2];
sigma_x = abs(normrnd(0,0.2));
sigma_y = abs(normrnd(0,0.2));
theta = [h sigma_x sigma_y];

n_obs = size(data)(2)
h1 = theta(1)
h2 = theta(2)
sigma_y = theta(4)
H = [h1 0;
     0 h2]
for j=1:10
  %================Expectation Step==================%
  % Get log likelihood of observations given theta
  for i=1:n_obs
    x_i = h1*visual_data(i);
    loglik(i) = log(gaussian(x_i, metric_data(i), 0.3));
  endfor
  loglik=loglik+abs(min(loglik(:)));
  loglik=normalize(loglik);
  %================Maximization Step=================%
  % Calculate new parameters
  %loglik = normalize(loglik);
  %h1 = sum(loglik*h1)
  %[val id] = max(loglik);
  %h1 = loglik(id)*h1
  est=visual_data(:)./metric_data(:);
  h1=sum(est.*loglik')

  estimates(j) = h1;
endfor

%==================================================%
%==================Visualization===================%
%==================================================%
figure(1);
hold on;
plot(data, '-b')
plot(metric_data, '-r')
plot(visual_data, '-g')
legend('Real height data', 'Metric height data', 'Visual SLAM height data')
hold off;

figure(2)
plot(loglik)

figure(3)
plot(estimates)
legend('Scale estimates')

figure(4)
hold on;
plot(data, '-b')
plot(metric_data, 'r')
plot(visual_data./h1, 'g')
legend('Real height data', 'Metric height data', 'Scaled Visual SLAM height data')
hold off;
