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
COPY requirements.txt tutorial.py ./
RUN pip install --break-system-packages -r requirements.txt

EXPOSE 7860

# Combine git operations and file ownership changes in one layer
USER appuser
RUN git clone https://github.com/devflowinc/trieve /mnt/workspace && \
    cd /mnt/workspace && \
    git checkout e65889a13715e8833e7cccfe0168b57c1fc966cc

USER root
COPY start.sh /start.sh
RUN chmod +x /start.sh && chown -R appuser:appuser /mnt/workspace /start.sh /app

USER appuser
CMD ["/start.sh"]