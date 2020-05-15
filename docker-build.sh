echo Switching to Root user...
sudo su
echo Updating the image on `date`...
yum update -y

echo Updating the AWS CLI started on `date`...
yum install python3-pip -y
pip3 install awscli
python --version 
python3 --version 
pip3 --version
aws --version 

echo Installing Docker on `date`...
yum install docker -y 
docker --version
systemctl start docker

echo Installing git on `date`...
yum install git -y 
git --version

git clone https://github.com/dushyant8858/AWSUtility-codebuild.git
cd AWSUtility-codebuild

echo Setting build environment variable on `date`...
REPOSITORY_URI=821438830100.dkr.ecr.us-east-1.amazonaws.com/custom-docker-imagetag
COMMIT_HASH=$(git rev-parse HEAD | cut -c 1-7)
IMAGE_TAG=${COMMIT_HASH:=latest}

echo Logging in to Amazon ECR...
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 821438830100.dkr.ecr.us-east-1.amazonaws.com

echo Building the Docker image, started at `date`...          
# docker build -t $REPOSITORY_URI:latest .
# docker tag $REPOSITORY_URI:latest $REPOSITORY_URI:$IMAGE_TAG
docker build -t $REPOSITORY_URI:$IMAGE_TAG .

echo Pushing the Docker image to ECR, started at `date`...
# docker push $REPOSITORY_URI:latest
docker push $REPOSITORY_URI:$IMAGE_TAG
echo Docker image build and push done completed on `date`

echo Updating the SSM imageTag parameter...
aws ssm put-parameter --name imageTag --value $IMAGE_TAG --type String --overwrite --region us-east-1
echo Updating SSM imageTag parameter done on `date`...

echo docker-build.sh execution done on `date`.

aws ssm get-parameter --name imageTag --region us-east-1 --query Parameter.Value --output text > /command-output.txt
