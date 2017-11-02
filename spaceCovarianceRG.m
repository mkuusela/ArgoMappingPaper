function r = spaceCovarianceRG(lat1,long1,lat2,long2)

rEarth = 6371;

deltaLat = abs(lat1-lat2);
deltaLong = min(abs(long1-long2),360-abs(long1-long2));

midLat = (lat1+lat2)/2;

distLat = deltaLat/360*2*pi*rEarth;
distLong = deltaLong/360*2*pi*rEarth*cos(midLat/360*2*pi);

if abs(midLat) >= 20 
    a = 1;
else
    a = 7/160*abs(midLat) + 1/8;
end

dist = sqrt(distLat^2 + (a*distLong)^2);

r = 0.77*exp(-(dist/140)^2) + 0.23*exp(-dist/1111);