FROM 078742956215.dkr.ecr.us-east-1.amazonaws.com/sms249/apache22-official:latest

# This container allows us to control the release of OS patches to our web server
RUN \
  apt-get update && apt-get install --no-install-recommends -y \
    less

# Define default command.
CMD ["bash"]
