require "itamae/plugin/recipe/codedeploy_agent/version"

execute 'install codedeploy agent' do
  region = node[:aws_region]

  command <<~INSTALLATION
    REGION="#{region}"
    if [ "$REGION" = "" ]
    then
      REGION=$(
        curl http://169.254.169.254/latest/meta-data/placement/availability-zone |
          sed -e 's/[a-z]$//' )
    fi

    sudo yum update
    sudo yum install ruby
    sudo yum install wget

    cd /home/ec2-user
    wget https://aws-codedeploy-"${REGION}".s3.amazonaws.com/latest/install
    chmod +x ./install
    sudo ./install auto
  INSTALLATION

  not_if <<~TEST_SHELL
    if ! sudo service codedeploy-agent status
    then
      sudo service codedeploy-agent start &&
        sudo service codedeploy-agent status
    fi
  TEST_SHELL
end
