FROM agenticlabs/lsproxy:0.1.1
RUN rustup update

# Install Python, pip, and git
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    git \
    && rm -rf /var/lib/apt/lists/*

# Set up uv
COPY --from=ghcr.io/astral-sh/uv:0.4.20 /uv /bin/uv

# Create user first
RUN useradd -m -u 1000 user

# Create directories with proper permissions
RUN mkdir -p /home/user/.marimo && \
    mkdir -p /home/user/.config && \
    mkdir -p /mnt/workspace && \
    chown -R user:user /home/user/.marimo && \
    chown -R user:user /home/user/.config && \
    chown -R user:user /mnt && \
    chown user:user /lsproxy

ENV PATH="/home/user/.local/bin:$PATH"
ENV UV_SYSTEM_PYTHON=1
ENV HOME=/home/user
ENV XDG_CONFIG_HOME=/home/user/.config
ENV MARIMO_CONFIG_DIR=/home/user/.marimo
ENV RUST_LOG=debug


# Set up marimo
WORKDIR /app
COPY --chown=user ./requirements.txt requirements.txt
RUN pip install --break-system-packages -r requirements.txt
COPY --chown=user . /app

# Copy and set up start script
COPY --chown=user ./start.sh /start.sh

EXPOSE 7860

# Clone trieve as user
USER user
RUN git clone https://github.com/devflowinc/trieve /mnt/workspace && \
    cd /mnt/workspace && \
    git checkout e65889a13715e8833e7cccfe0168b57c1fc966cc

# Start both processes using the script
CMD ["/start.sh"]
