packer {
  required_plugins {
    amazon = {
      version = ">= 1.3.3"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "aws_region" {
  default = "us-east-1"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "ami_id" {
  default = "ami-0866a3c8686eaeeba"
}

source "amazon-ebs" "node_nginx_image" {
  region                      = var.aws_region
  instance_type               = var.instance_type
  source_ami                  = var.ami_id
  ssh_username                = "ubuntu"
  ami_name                    = "packer-node-nginx-{{timestamp}}"
  associate_public_ip_address = true
}

build {
  name    = "node-nginx-image"
  sources = ["source.amazon-ebs.node_nginx_image"]

  provisioner "shell" {
    inline = [
      "export DEBIAN_FRONTEND=noninteractive",
      "sudo apt update -y",
      "sudo apt upgrade -y",
      "sudo apt install -y curl gnupg software-properties-common",
      "curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -",
      "sudo apt install -y nodejs nginx",
      "sudo npm install -g pm2",
      "echo 'const http = require(\"http\"); const hostname = \"localhost\";const port = 3000; const server = http.createServer((req, res) => { res.statusCode = 200; res.setHeader(\"Content-Type\", \"text/plain\"); res.end(\"Hello World!\"); }); server.listen(port, hostname, () => { console.log(`Server running at http://$$hostname:$$port/`); });' > /home/ubuntu/hello.js",
      "sudo -u ubuntu pm2 start /home/ubuntu/hello.js",
      "sudo -u ubuntu pm2 save",
      # Configurar el script de inicio automáticamente
      "sudo env PATH=$PATH:/usr/bin pm2 startup systemd -u ubuntu --hp /home/ubuntu",
      "sudo systemctl enable pm2-ubuntu || true",
      "sudo systemctl restart pm2-ubuntu || true",
      "echo 'server { listen 80; server_name _; location / { proxy_pass http://localhost:3000; proxy_http_version 1.1; proxy_set_header Upgrade $http_upgrade; proxy_set_header Connection \"upgrade\"; proxy_set_header Host $host; proxy_cache_bypass $http_upgrade; } }' | sudo tee /etc/nginx/sites-available/default",
      "sudo ln -sf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default",
      "sudo nginx -t || true",
      "sudo systemctl restart nginx || true"
    ]
  }

  provisioner "shell" {
    inline = [
      "sudo ufw allow 'Nginx Full'",
      "sudo systemctl enable nginx"
    ]
  }
}
