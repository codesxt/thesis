function e = mse(a, b)
  e = sum((a-b).^2)/(size(a)(2));
endfunction
