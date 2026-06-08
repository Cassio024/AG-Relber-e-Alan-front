FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter && \
    echo 'export PATH="$PATH:/usr/local/flutter/bin"' >> /etc/profile

ENV PATH="/usr/local/flutter/bin:${PATH}"

# Set working directory
WORKDIR /app

# Copy Flutter project
COPY . .

# Get Flutter dependencies and build web
RUN flutter pub get && \
    flutter build web --release && \
    npm install

# Expose port
EXPOSE 3000

# Start the server
CMD ["npm", "start"]
