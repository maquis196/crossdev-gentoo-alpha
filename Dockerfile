FROM local/gentoo-crossdev-base:stable

ADD target-files/crossdev.conf /etc/portage/repos.conf/

RUN mkdir -p /var/db/repos/crossdev/{profiles,metadata} && \
    echo 'crossdev' > /var/db/repos/crossdev/profiles/repo_name && \
    echo 'masters = gentoo'\n\
         'thin-manifests = true' > /var/db/repos/crossdev/metadata/layout.conf && \
    chown -R portage:portage /var/db/repos/crossdev

ARG BINUTIL_VER='~2.40'
ARG GCC_VER='~12.2.1_p20230121'
ARG HEADERS_VER='~6.2'
ARG LIBC_VER='~2.36'

ARG TARGET='alpha-unknown-linux-gnu'

RUN crossdev --b "${BINUTIL_VER}" --g "${GCC_VER}" --k "${HEADERS_VER}" --l "${LIBC_VER}" -t "${TARGET}"

#
#
#
#ARG TARGET=alpha-unknown-linux-gnu
#ARG ARCH=alpha
#
#ARG STAGE3_FILE="stage3-${ARCH}-${STAGE3_DATE}.tar.bz2"



# Define how to start distccd by default
# (see "man distccd" for more information)
ENTRYPOINT [\
  "distccd", \
  "--daemon", \
  "--no-detach", \
  "--user", "distcc", \
  "--port", "3632", \
  "--stats", \
  "--stats-port", "3633", \
  "--log-stderr", \
  "--listen", "0.0.0.0"\
]

# By default the distcc server will accept clients from everywhere.
# Feel free to run the docker image with different values for the
# following params.
CMD [\
  "--allow", "0.0.0.0/0", \
  "--nice", "5", \
  "--jobs", "5" \
]

# 3632 is the default distccd port
# 3633 is the default distccd port for getting statistics over HTTP
EXPOSE \
  3632/tcp \
  3633/tcp

# We check the health of the container by checking if the statistics
# are served. (See
# https://docs.docker.com/engine/reference/builder/#healthcheck)
HEALTHCHECK --interval=5m --timeout=3s \
  CMD curl -f http://0.0.0.0:3633/ || exit 1
