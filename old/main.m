%==================================================%
%=====Parameter optimization with EM-Algorithm=====%
%==================================================%
%=================Data Generation==================%
sigma_x = 0.01;       % Real data sigma
sigma_y_1 = 0.01;      % Metric data sigma
sigma_y_2 = 0.05;      % Visual data sigma
h_1 = 1;            % Metric data scale
h_2 = 2;              % Visual data scale
time=20;
data = real_data(sigma_x, time);
metric_data = scaled_data(data, h_1, sigma_y_1);
visual_data = scaled_data(data, h_2, sigma_y_2);

%============Data sampling as proposed=============%
range = [1:40:time*1000];
data=data(range);
metric_data=metric_data(range);
visual_data=visual_data(range);

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

scale_estimate = h1;
frame_size = 10;
p_scale_estimate = scale_estimate;
epsilon = 0.001;
est_index = 1;
for k=frame_size:n_obs
  %=================Get Data Frames===================%
  real_data_frame = data(k-frame_size+1:k);
  metric_data_frame = metric_data(k-frame_size+1:k);
  visual_data_frame = visual_data(k-frame_size+1:k);
  %================Apply E-M on frame=================%
  do
    p_scale_estimate = scale_estimate;
    %Expectation Step%
    x = scale_estimate*visual_data_frame;
    loglik = log(gaussian(x, metric_data_frame, 0.3));
    if(min(loglik)<0)
      loglik=loglik+abs(min(loglik));
    endif
    loglik=normalize(loglik);
    %Maximization Step%
    est_update=visual_data_frame./metric_data_frame;
    est_update=sum(est_update.*loglik);
    scale_estimate=est_update
  until(abs(p_scale_estimate-scale_estimate)<epsilon)
  estimates(est_index)=scale_estimate;
  est_index++;
  (k/n_obs)*100
endfor

%==================================================%
%==================Visualization===================%
%==================================================%
figure(1)
plot(estimates)
legend('Scale estimates')

figure(2)
hold on;
plot(data, '-b')
plot(metric_data, 'r')
plot(visual_data./scale_estimate, 'g')
legend('Real height data', 'Metric height data', 'Scaled Visual SLAM height data')
hold off;
