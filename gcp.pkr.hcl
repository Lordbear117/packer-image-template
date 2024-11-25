source "googlecompute" "node_nginx_image_gcp" {
  project_id      = "leafy-tuner-382618"  # Cambia por tu ID de proyecto en GCP
  zone            = "us-central1-a"
  machine_type    = "e2-micro"
  source_image    = "ubuntu-2404-noble-amd64-v20241115"  # Imagen base en Google Cloud
  image_name      = "packer-node-nginx-gcp-{{timestamp}}"
  ssh_username    = "ubuntu"
  metadata        = {
    "startup-script" = "#!/bin/bash
      sudo apt-get update -y
      sudo apt-get upgrade -y
      sudo apt-get install -y curl gnupg software-properties-common
      # Instalación de Node.js, Nginx y PM2
      curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
      sudo apt-get install -y nodejs nginx
      sudo npm install -g pm2
      # Creación de la aplicación hello.js
      echo 'const http = require(\\\"http\\\"); const hostname = \\\\\"localhost\\\\\"; const port = 3000; const server = http.createServer((req, res) => { res.statusCode = 200; res.setHeader(\\\"Content-Type\\\", \\\"text/plain\\\"); res.end(\\\"Hello World!\\\"); }); server.listen(port, hostname, () => { console.log(\\`Server running at http://$$hostname:$$port/\\`); });' > /home/ubuntu/hello.js
      sudo -u ubuntu pm2 start /home/ubuntu/hello.js
      sudo -u ubuntu pm2 save
      sudo env PATH=$PATH:/usr/bin pm2 startup systemd -u ubuntu --hp /home/ubuntu
      sudo systemctl enable pm2-ubuntu || true
      sudo systemctl restart pm2-ubuntu || true
      # Configurar el archivo de configuración de Nginx
      echo 'server { listen 80; server_name _; location / { proxy_pass http://localhost:3000; proxy_http_version 1.1; proxy_set_header Upgrade $http_upgrade; proxy_set_header Connection \\\"upgrade\\\"; proxy_set_header Host $host; proxy_cache_bypass $http_upgrade; } }' | sudo tee /etc/nginx/sites-available/default
      sudo ln -sf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default
      sudo nginx -t || true
      sudo systemctl restart nginx || true
      # Abrir el puerto 80 en el firewall
      sudo ufw allow 'Nginx Full'
      # Habilitar Nginx para que se inicie automáticamente
      sudo systemctl enable nginx"
  }
