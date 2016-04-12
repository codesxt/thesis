function data = real_data(sigma_x, n)
  alpha = 0.3;
  offset=0.001;
  data=sin(alpha.*[offset:offset:n]);
  noise=normrnd(0,sigma_x,1,n/offset);
  data=data.+noise;
endfunction
