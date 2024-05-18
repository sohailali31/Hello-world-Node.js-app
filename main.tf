provider "aws" {
  region = "ap-south-1" # Specify your desired region
}

resource "aws_instance" "hello_world" {
  ami           = "ami-0e4fd655fb4e26c30" # Amazon Linux 2 AMI (Replace with your desired AMI)
  instance_type = "t2.micro"

  user_data = <<-EOF
    #!/bin/bash
    curl -sL https://rpm.nodesource.com/setup_14.x | bash -
    yum install -y nodejs
    echo 'const http = require("http");
    const hostname = "0.0.0.0";
    const port = 3000;
    const server = http.createServer((req, res) => {
      res.statusCode = 200;
      res.setHeader("Content-Type", "text/plain");
      res.end("Hello World\\n");
    });
    server.listen(port, hostname, () => {
      console.log("Server running at http://"+hostname+":"+port+"/");
    });' > /home/ec2-user/app.js
    node /home/ec2-user/app.js &
  EOF

  tags = {
    Name = "HelloWorldInstance"
  }

  vpc_security_group_ids = [aws_security_group.hello_world_sg.id]
}

resource "aws_security_group" "hello_world_sg" {
  name        = "hello_world_sg"
  description = "Allow HTTP inbound traffic"

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "instance_public_ip" {
  value = aws_instance.hello_world.public_ip
}

