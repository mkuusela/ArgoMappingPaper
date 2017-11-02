function r = spaceTimeCovarianceExpGeom(lat1,long1,t1,lat2,long2,t2,thetas,thetaLat,thetaLong,thetat)

distLat = abs(lat1-lat2);
distLong = abs(long1-long2);
distt = abs(t1-t2);

distSpaceTime = sqrt((distLat/thetaLat)^2 + (distLong/thetaLong)^2 + (distt/thetat)^2);

r = thetas * exp(-distSpaceTime);