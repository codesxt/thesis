function prob = gaussian(x, mu, sigma)
  prob = (1/sqrt(2*pi*sigma^2)) * exp((-(x-mu).^2)/(2*sigma^2));
endfunction
