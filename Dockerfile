FROM rocker/shiny:4.6.0

RUN install2.r --error --skipinstalled remotes
COPY . /tmp/biovizshiny
RUN R -e "remotes::install_local('/tmp/biovizshiny', dependencies = NA, upgrade = 'never')" \
    && rm -rf /tmp/biovizshiny /srv/shiny-server/*

COPY app.R /srv/shiny-server/app.R
RUN chown -R shiny:shiny /srv/shiny-server

EXPOSE 3838
CMD ["/usr/bin/shiny-server"]

