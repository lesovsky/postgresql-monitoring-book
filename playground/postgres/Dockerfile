FROM postgres:15-alpine

RUN wget https://github.com/lesovsky/pgcenter/releases/download/v0.9.2/pgcenter_0.9.2_linux_amd64.tar.gz -o /dev/null -O - | \
    tar xzf - -C /usr/bin pgcenter && \
    mkdir /var/log/postgresql && \
    chown postgres:postgres /var/log/postgresql
