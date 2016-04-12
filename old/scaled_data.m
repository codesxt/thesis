function data = scaled_data(original_data, scale, sigma)
  n=size(original_data)(2);
  noise = normrnd(0,sigma,1,n);
  data=original_data.*scale+noise;
endfunction
