FROM archlinux:latest
LABEL author="Duc A. Hoang"

ARG USERNAME=hoanganhduc
ARG USERHOME=/home/hoanganhduc
ARG USERID=1000
ARG USERGECOS='Duc A. Hoang'

RUN useradd \
	--create-home \
	--home-dir "$USERHOME" \
	--password "" \
	--uid "$USERID" \
	--comment "$USERGECOS" \
	--shell /bin/bash \
	"$USERNAME" && \
	echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set locale
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8 

RUN pacman -Syy

RUN	pacman -S --noconfirm --needed openssh git curl wget sudo make fontconfig tree && \
	yes | pacman -Scc

COPY texlive*.profile /
RUN wget http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz && \
	tar xvf install-tl-unx.tar.gz && \
	rm -rf install-tl-unx.tar.gz && \
	cd $(basename install-tl-*) && \
	./install-tl --profile=/texlive.profile && \
	rm -rf /texlive.profile /install-tl-* && \
	echo "PATH=/usr/local/texlive/2020/bin/x86_64-linux:$PATH; export PATH" >> /etc/bash.bashrc && \
	echo "MANPATH=/usr/local/texlive/2020/texmf-dist/doc/man:$MANPATH; export MANPATH"  >> /etc/bash.bashrc && \
	echo "INFOPATH=/usr/local/texlive/2020/texmf-dist/doc/info:$INFOPATH; export INFOPATH"  >> /etc/bash.bashrc
	
RUN tlmgr install \
		latexmk \
		memoir xcolor stmaryrd babel-greek greek-fontenc gfsartemisia babel-vietnamese vntex substitutefont mathdesign xkeyval inconsolata microtype titlesec soul soulutf8 todonotes bbding ccicons adjustbox collectbox standalone gincltex currfile filehook svn-prov filemod import arydshln chessfss skaknew imakeidx tkz-euclide tkz-base numprint pgf-blur upquote ifoddpage ucs ly1 charter easyreview \
		etoolbox lastpage hyperxmp ifmtarg totpages times \
		background everypage algorithms algorithmicx jknapltx rsfs float lipsum \
		multirow biblatex xpatch biber \
		beamer txfonts platex xelatex-dev textpos
	
USER $USERNAME
