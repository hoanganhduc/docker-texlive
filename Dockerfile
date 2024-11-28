FROM archlinux:latest

LABEL org.opencontainers.image.title="Arch Linux Base TeXLive"
LABEL org.opencontainers.image.source="https://github.com/hoanganhduc/docker-texlive"
LABEL org.opencontainers.image.description="A custom TeXLive installation with packages I often use"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.authors="Duc A. Hoang <anhduc.hoang1990@gmail.com>"

ARG USERNAME=vscode
ARG USERHOME=/home/vscode
ARG USERID=1000

RUN useradd \
	--create-home \
	--home-dir "$USERHOME" \
	--password "" \
	--uid "$USERID" \
	--shell /bin/bash \
	"$USERNAME" && \
	echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set locale
RUN echo "LC_ALL=en_US.UTF-8" >> /etc/environment \
	&& echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
	&& echo "LANG=en_US.UTF-8" > /etc/locale.conf \
	&& locale-gen en_US.UTF-8

# Initialize pacman keyring and upgrade system
RUN pacman-key --init && \
    pacman-key --populate archlinux && \
    pacman -Sy --needed --noconfirm --disable-download-timeout archlinux-keyring && \
	pacman -Syy && \
    pacman -Su --noconfirm --disable-download-timeout

RUN	pacman -S --noconfirm --needed openssh git curl wget sudo make fontconfig tree jre11-openjdk moreutils rsync unzip libxcrypt-compat && \
	yes | pacman -Scc

COPY texlive*.profile /
RUN wget https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz && \
	tar xvf install-tl-unx.tar.gz && \
	rm -rf install-tl-unx.tar.gz && \
	cd $(basename install-tl-*) && \
	./install-tl --profile=/texlive.profile && \
	rm -rf /texlive.profile /install-tl-* && \
	echo "PATH=/usr/local/texlive/2024/bin/x86_64-linux:$PATH; export PATH" >> /etc/bash.bashrc && \
	echo "MANPATH=/usr/local/texlive/2024/texmf-dist/doc/man:$MANPATH; export MANPATH"  >> /etc/bash.bashrc && \
	echo "INFOPATH=/usr/local/texlive/2024/texmf-dist/doc/info:$INFOPATH; export INFOPATH"  >> /etc/bash.bashrc

RUN tlmgr update --self
	
COPY pax /usr/bin/

RUN wget https://cyfuture.dl.sourceforge.net/project/pdfbox/PDFBox/PDFBox-0.7.3/PDFBox-0.7.3.zip \
	&& unzip PDFBox-0.7.3.zip -d /usr/share/java \
	&& rm -rf PDFBox-0.7.3.zip

USER $USERNAME
