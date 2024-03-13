# syntax=docker/dockerfile:1

# This Dockerfile uses a multi-stage build.
# The first stage is used to build the application.
# The second stage is used to create the production image.

ARG NODE_VERSION=20.11.1

FROM node:${NODE_VERSION}-alpine as base
WORKDIR /usr/src/app
# Expose the port that the application listens on.
EXPOSE 3000

# For development stage
FROM base as dev

RUN --mount=type=bind,source=package.json,target=package.json \
    --mount=type=bind,source=package-lock.json,target=package-lock.json \
    --mount=type=cache,target=/root/.npm \
    npm ci --include=dev

# Run the application as a non-root user.
USER node
# Copy the rest of the source files into the image.
COPY . .
# Run the application.
CMD npm run dev


# For production stage
FROM base as prod

RUN --mount=type=bind,source=package.json,target=package.json \
    --mount=type=bind,source=package-lock.json,target=package-lock.json \
    --mount=type=cache,target=/root/.npm \
    npm ci --omit=dev

# Run the application as a non-root user.
USER node
# Copy the rest of the source files into the image.
COPY . .
# Run the application.
CMD node src/index.js



