FROM node:24

ARG TZ
ENV TZ="$TZ"

# =============================================================================
# ROOT: System packages and tools
# =============================================================================

# versions
ARG CLAUDE_CODE_VERSION=latest
ARG DOCKER_COMPOSE_VERSION=v2.32.4
ARG GIT_DELTA_VERSION=0.18.2
ARG RUBY_VERSION=3.2.2
ARG TERRAFORM_VERSION=1.14.1
ARG TERRAGRUNT_VERSION=0.93.13
ARG ZSH_IN_DOCKER_VERSION=1.2.0
ARG USERNAME=node

# locale and runtime flags
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV DEVCONTAINER=true
ENV RBENV_ROOT=/usr/local/share/rbenv
ENV PATH=$RBENV_ROOT/bin:$RBENV_ROOT/shims:$PATH

# apt packages — base tools, python build deps, ruby build deps
# Install official Docker CLI (not the outdated docker.io apt package)
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl && \
    install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc && \
    chmod a+r /etc/apt/keyrings/docker.asc && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian bookworm stable" \
      > /etc/apt/sources.list.d/docker.list

RUN apt-get update && apt-get install -y --no-install-recommends \
    docker-ce-cli \
    less \
    git \
    procps \
    sudo \
    fzf \
    zsh \
    man-db \
    unzip \
    gnupg2 \
    gh \
    iptables \
    ipset \
    iproute2 \
    dnsutils \
    aggregate \
    jq \
    nano \
    vim \
    make \
    build-essential \
    locales \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libxml2-dev \
    libxmlsec1-dev \
    libffi-dev \
    liblzma-dev \
    libpq-dev \
    && sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# directories and ownership
RUN mkdir -p /usr/local/share/npm-global && \
    chown -R node:node /usr/local/share && \
    mkdir /commandhistory && \
    touch /commandhistory/.bash_history && \
    chown -R $USERNAME /commandhistory && \
    mkdir -p /workspace /home/node/.claude && \
    chown -R node:node /workspace /home/node/.claude

WORKDIR /workspace

# docker compose
RUN ARCH=$(dpkg --print-architecture | sed 's/amd64/x86_64/;s/arm64/aarch64/') && \
    mkdir -p /usr/local/lib/docker/cli-plugins && \
    curl -fsSL "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-linux-${ARCH}" \
      -o /usr/local/lib/docker/cli-plugins/docker-compose && \
    chmod +x /usr/local/lib/docker/cli-plugins/docker-compose && \
    ln -s /usr/local/lib/docker/cli-plugins/docker-compose /usr/local/bin/docker-compose

# git-delta
RUN ARCH=$(dpkg --print-architecture) && \
    wget "https://github.com/dandavison/delta/releases/download/${GIT_DELTA_VERSION}/git-delta_${GIT_DELTA_VERSION}_${ARCH}.deb" && \
    dpkg -i "git-delta_${GIT_DELTA_VERSION}_${ARCH}.deb" && \
    rm "git-delta_${GIT_DELTA_VERSION}_${ARCH}.deb"

# rbenv + ruby
RUN git clone https://github.com/rbenv/rbenv.git $RBENV_ROOT && \
    git clone https://github.com/rbenv/ruby-build.git $RBENV_ROOT/plugins/ruby-build && \
    rbenv install $RUBY_VERSION && \
    rbenv global $RUBY_VERSION && \
    gem install bundler && \
    chown -R node:node $RBENV_ROOT

# terraform + terragrunt
RUN ARCH=$(dpkg --print-architecture) && \
    curl -fsSL "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${ARCH}.zip" \
      -o /tmp/terraform.zip && \
    unzip /tmp/terraform.zip -d /usr/local/bin && \
    rm /tmp/terraform.zip && \
    curl -fsSL "https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_${ARCH}" \
      -o /usr/local/bin/terragrunt && \
    chmod +x /usr/local/bin/terragrunt

# permissions and sudoers
COPY init-firewall.sh init-docker.sh dc /usr/local/bin/
RUN groupadd -f docker && \
    usermod -aG docker node && \
    chmod +x /usr/local/bin/init-firewall.sh /usr/local/bin/init-docker.sh /usr/local/bin/dc && \
    echo "node ALL=(root) NOPASSWD: /usr/local/bin/init-firewall.sh" > /etc/sudoers.d/node-firewall && \
    echo "node ALL=(root) NOPASSWD: /usr/local/bin/init-docker.sh" >> /etc/sudoers.d/node-firewall && \
    chmod 0440 /etc/sudoers.d/node-firewall

# =============================================================================
# NODE: User environment
# =============================================================================

USER node

# paths and editor
ENV NPM_CONFIG_PREFIX=/usr/local/share/npm-global
ENV PATH=$PATH:/usr/local/share/npm-global/bin
ENV SHELL=/bin/zsh
ENV EDITOR=nano
ENV VISUAL=nano
ENV PYENV_ROOT=/home/node/.pyenv
ENV PATH=$PYENV_ROOT/bin:$PYENV_ROOT/shims:$PATH
ENV POETRY_HOME=/usr/local/share/poetry
ENV PATH=$POETRY_HOME/bin:$PATH

# zsh + claude code
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v${ZSH_IN_DOCKER_VERSION}/zsh-in-docker.sh)" -- \
    -p git \
    -p fzf \
    -a "source /usr/share/doc/fzf/examples/key-bindings.zsh" \
    -a "source /usr/share/doc/fzf/examples/completion.zsh" \
    -a "export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
    -x

RUN npm install -g @anthropic-ai/claude-code@${CLAUDE_CODE_VERSION}

# pyenv + python + poetry
RUN curl https://pyenv.run | bash && \
    pyenv install 3.12 && \
    pyenv global 3.12

RUN curl -sSL https://install.python-poetry.org | POETRY_HOME=/usr/local/share/poetry python3 - && \
    poetry config virtualenvs.in-project true

# zshrc — runtime init hooks
RUN echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc && \
    echo 'export PATH="$PYENV_ROOT/bin:$PYENV_ROOT/shims:$PATH"' >> ~/.zshrc && \
    echo 'eval "$(pyenv init -)"' >> ~/.zshrc && \
    echo 'export RBENV_ROOT="/usr/local/share/rbenv"' >> ~/.zshrc && \
    echo 'export PATH="$RBENV_ROOT/bin:$RBENV_ROOT/shims:$PATH"' >> ~/.zshrc && \
    echo 'eval "$(rbenv init -)"' >> ~/.zshrc && \
    echo "alias dcr='dc run --rm'" >> ~/.zshrc
