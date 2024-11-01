FROM agenticlabs/lsproxy:0.1.1

# Install Python, pip, and git
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    git \
    && rm -rf /var/lib/apt/lists/*


# Set up marimo
WORKDIR /app
COPY requirements.txt requirements.txt
COPY tutorial.py tutorial.py
RUN pip install --break-system-packages -r requirements.txt


EXPOSE 7860

RUN git clone https://github.com/devflowinc/trieve /mnt/workspace && \
    cd /mnt/workspace && \
    git checkout e65889a13715e8833e7cccfe0168b57c1fc966cc

COPY start.sh /start.sh

# Start both processes using the script
CMD ["/start.sh"]
