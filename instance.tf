resource "aws_instance" "my_server" {
  ami                    = "ami-0fc5d935ebf8bc3bc"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.my_kp.key_name
  subnet_id              = aws_subnet.my_public_subnet.id
  vpc_security_group_ids = [aws_security_group.my_wp_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt upgrade -y
              sudo apt install nginx -y
              sudo systemctl start nginx
              sudo systemctl enable nginx
              sudo apt install mariadb-server -y
              sudo systemctl start mariadb
              sudo systemctl enable mariadb
              sudo mysql_secure_installation <<EOFSECURE
              Y
              Y
              Y
              Y
              Y
              EOFSECURE
              sudo add-apt-repository -y ppa:ondrej/php
              sudo apt update
              sudo apt install -y php7.4 php7.4-cli php7.4-fpm php7.4-mysql php7.4-gd php7.4-xml php7.4-curl
              sudo systemctl restart nginx
              wget https://wordpress.org/latest.zip
              sudo apt install unzip -y
              unzip latest.zip
              sudo mv wordpress/* /var/www/html
              cd /var/www/html
              rm -rf index.html index.nginx-debian.html
              cd /etc/nginx/sites-enabled
              sudo tee wordpress.conf > /dev/null <<'EOF_NGINX'
              server {
                  listen 80 default_server;
                  listen [::]:80 default_server;

                  root /var/www/html;

                  # Add index.php to the list if you are using PHP
                  index index.php;

                  location / {
                      # First attempt to serve request as file, then
                      # as directory, then fall back to displaying a 404.
                      try_files $uri $uri/ /index.php?$args;
                  }

                  # pass PHP scripts to FastCGI server
                  location ~ \.php$ {
                      include snippets/fastcgi-php.conf;
                      fastcgi_pass unix:/run/php/php7.4-fpm.sock;
                  }

                  # deny access to .htaccess files
                  location ~ /\.ht {
                      deny all;
                  }
              }
              EOF_NGINX

              sudo rm -rf default
              sudo rm -rf /etc/nginx/sites-available/default
              sudo systemctl restart nginx
              sudo mysql -u root -p -e "CREATE DATABASE wordpress;"
              sudo mysql -u root -p -e "CREATE USER 'wordpress_dbuser'@'localhost' IDENTIFIED BY 'password';"
              sudo mysql -u root -p -e "GRANT ALL PRIVILEGES on wordpress.* to 'wordpress_dbuser'@'localhost';"
              sudo mysql -u root -p -e "FLUSH PRIVILEGES;"
              sudo chown -R www-data:www-data /var/www/html/
              EOF

  tags = {
    Name = "my-server"
  }
}

output "public_ip" {
  value = aws_instance.my_server.public_ip
}
