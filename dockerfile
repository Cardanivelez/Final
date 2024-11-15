FROM ubuntu:22.04
WORKDIR /var/www/html/
RUN apt-get update && apt-get install apache2 git -y
RUN rm index.html
WORKDIR /app
RUN git clone https://github.com/Cardanivelez/Final
RUN mv ./Final/pagina*
CMD ["apachectl", "-D", "FOREGROUND"]