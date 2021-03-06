echo Updating the image on `date`...
sudo yum update -y

echo Installing Docker on `date`...
sudo yum install docker -y 
sudo docker --version
sudo systemctl start docker

echo Installing git on `date`...
sudo yum install git -y 
git --version

git clone https://github.com/dushyant8858/AWSUtility-codebuild.git
cd AWSUtility-codebuild

echo Setting build environment variable on `date`...
REPOSITORY_URI=123456789102.dkr.ecr.us-east-1.amazonaws.com/custom-docker-imagetag
COMMIT_HASH=$(git rev-parse HEAD | cut -c 1-7)
IMAGE_TAG=${COMMIT_HASH:=latest}

echo Logging in to Amazon ECR...
sudo $(aws ecr get-login --no-include-email --region us-east-1)

echo Building the Docker image, started at `date`...          
sudo docker build -t $REPOSITORY_URI:$IMAGE_TAG .

echo Pushing the Docker image to ECR, started at `date`...
sudo docker push $REPOSITORY_URI:$IMAGE_TAG
echo Docker image build and push done completed on `date`

echo Updating the SSM imageTag parameter...
aws ssm put-parameter --name imageTag --value $IMAGE_TAG --type String --overwrite --region us-east-1
echo Updating SSM imageTag parameter done on `date`...

echo docker-build.sh execution done on `date`.

#aws ssm get-parameter --name imageTag --region us-east-1 --query Parameter.Value --output text > /command-output.txt
# wget -O - https://raw.githubusercontent.com/dushyant8858/AWSUtility-codebuild/master/docker-build.sh | bash
echo --END--
