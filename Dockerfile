# Build Stage
FROM node:alpine AS builder
WORKDIR /app
COPY . .

# Install build dependencies
RUN apk update && \
    apk add --no-cache p7zip

# Update bin-path for docker/linux
RUN echo 'ffmpeg: "./bin/ffmpeg/ffmpeg"\nmkvmerge: "./bin/mkvtoolnix/mkvmerge"' > /app/config/bin-path.yml

# Install and build AniDL
RUN npm install -g pnpm && \
    pnpm i && \
    pnpm run build-linux-gui

# Final Stage
FROM node:alpine
WORKDIR /app

# Copy built files from builder stage
COPY --from=builder /app/lib/_builds/multi-downloader-nx-linux-x64-gui .

# Install runtime dependencies
RUN apk update && \
    apk add --no-cache xdg-utils mkvtoolnix && \
    mv /usr/bin/mkvmerge /app/bin/mkvtoolnix/mkvmerge && \
    mv /usr/bin/ffmpeg /app/bin/ffmpeg/ffmpeg && \
    rm -rf /var/cache/apk/*

# Command to run the application
CMD [ "/app/aniDL" ]
