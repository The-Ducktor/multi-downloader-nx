# Use a lightweight Node.js base image with Alpine Linux
FROM node:alpine AS builder

# Set the working directory
WORKDIR /app

# Copy the application source code
COPY . .

# Install required tools and dependencies
RUN apk update && \
    apk add --no-cache p7zip xdg-utils mkvtoolnix

# Update bin-path for docker/linux
RUN echo 'ffmpeg: "./bin/ffmpeg/ffmpeg"\nmkvmerge: "./bin/mkvtoolnix/mkvmerge"' > /app/config/bin-path.yml

# Install pnpm and build the application
RUN npm install -g pnpm && \
    pnpm i && \
    pnpm run build-linux-gui

# Build final image using Alpine Linux
FROM node:alpine

# Set the working directory
WORKDIR /app

# Copy the built application from the previous stage
COPY --from=builder /app/lib/_builds/multi-downloader-nx-linux-x64-gui .

# Install additional tools if required (e.g., xdg-utils)
RUN apk update && \
    apk add --no-cache xdg-utils

# Copy mkvmerge and ffmpeg binaries
RUN mkdir -p /app/bin/mkvtoolnix /app/bin/ffmpeg && \
    cp /usr/bin/mkvmerge /app/bin/mkvtoolnix/mkvmerge && \
    cp /usr/bin/ffmpeg /app/bin/ffmpeg/ffmpeg

# Set the default command to run the application
CMD [ "/app/aniDL" ]
