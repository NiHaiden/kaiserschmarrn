FROM scratch AS ctx

COPY build.sh /build.sh

FROM quay.io/fedora/fedora-bootc:43

COPY repos/docker-ce.repo /etc/yum.repos.d/docker-ce.repo
COPY build_files/docker.conf /usr/lib/sysusers.d/docker.conf
COPY build_files/dhcpd.conf /usr/lib/sysusers.d/dhcpd.conf
COPY --from=ghcr.io/ublue-os/brew:latest /system_files /
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /usr/bin/systemctl preset brew-setup.service && \
    /usr/bin/systemctl preset brew-update.timer && \
    /usr/bin/systemctl preset brew-upgrade.timer

RUN --mount=type=tmpfs,dst=/var \
    --mount=type=tmpfs,dst=/tmp \
    --mount=type=tmpfs,dst=/boot \
    --mount=type=tmpfs,dst=/run \
    --mount=type=bind,from=ctx,source=/,dst=/tmp/build-scripts \
    /tmp/build-scripts/build.sh

RUN rm -rf /var/* && bootc container lint --fatal-warnings
