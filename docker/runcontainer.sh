# Grab latest versions from parent directory 
cp ../delta.sh .
cp ../deltav2.sh .
cp ../profile.sh .
cp ../rudataall.sh .
cp ../rudatadelta.sh .
sudo docker build -t profile .
# Don't keep these files around
rm delta.sh deltav2.sh profile.sh rudataall.sh rudatadelta.sh 
sudo docker run -it --rm profile

