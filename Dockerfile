FROM agenticlabs/lsproxy:0.1.1

# Combine all apt operations and user/directory setup in one layer
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    git \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -m -u 1000 appuser \
    && mkdir -p /mnt/workspace /usr/local/cargo \
    && chown -R appuser:appuser /mnt/workspace /usr/local/cargo

WORKDIR /app
COPY requirements.txt ./
RUN pip install --break-system-packages -r requirements.txt

# Combine git operations and file ownership changes in one layer
USER appuser
RUN git clone https://github.com/devflowinc/trieve /mnt/workspace && \
    cd /mnt/workspace && \
    git checkout e65889a13715e8833e7cccfe0168b57c1fc966cc

USER root
COPY start.sh /start.sh
RUN chown -R appuser:appuser /mnt/workspace /start.sh /app

COPY file_options.json tutorial.py ./

ENV CHECKOUT_LOCATION=/mnt/workspace
ENV BASE_URL=http://localhost:4444/v1

EXPOSE 7860

USER appuser
CMD ["/start.sh"]
