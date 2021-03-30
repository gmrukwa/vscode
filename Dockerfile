FROM codercom/code-server:3.9.2

SHELL ["/bin/bash", "-c"]

USER root

RUN apt-get update --fix-missing && \
    apt-get install -y \
      # miniconda
      wget \
      bzip2 \
      ca-certificates \
      curl \
      git \
      # polyaxon
      gcc \
      python3-dev \
      # other
      make \
      htop \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
    
# Patch for Safari to work
# See more: https://github.com/cdr/code-server/issues/2975#issuecomment-808070195
RUN sed -i "s/req.headers\[\"sec-websocket-extensions\"\]/false/g" /usr/lib/code-server/out/node/routes/vscode.js && \
    sed -i "s/responseHeaders.push(\"Sec-WebSocket-Extensions/\/\/responseHeaders.push(\"Sec-WebSocket-Extensions/g" /usr/lib/code-server/out/node/routes/vscode.js

USER coder

RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-py38_4.9.2-Linux-x86_64.sh -O ~/miniconda.sh && \
    sudo /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    sudo chmod -R 775 /opt/conda && \
    sudo chgrp -R coder /opt/conda && \
    rm ~/miniconda.sh && \
    /opt/conda/bin/conda clean -tipsy && \
    sudo ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc

RUN code-server --install-extension shan.code-settings-sync && \
    code-server --install-extension ms-python.python@2020.10.332292344
    
SHELL ["/bin/bash", "-c"]
