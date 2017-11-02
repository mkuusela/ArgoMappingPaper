function r = exponentialCovarianceAnisotropy(lat1,long1,lat2,long2,theta1,theta2,a)

distLat = abs(lat1-lat2);
distLong = abs(long1-long2);

dist = sqrt(distLat^2 + (distLong/a)^2);

r = theta1*exp(-dist/theta2);