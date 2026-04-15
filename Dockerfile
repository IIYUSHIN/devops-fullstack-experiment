# ============================================
# PART 1: Dockerfile — Multi-Stage Build
# ============================================
# This Dockerfile uses a multi-stage build process:
#   Stage 1 (build): Uses Node.js to install dependencies and build the React app
#   Stage 2 (production): Uses Nginx Alpine to serve the built static files
# Result: A production-ready image under 100MB

# ──────────────────────────────────────────────
# STAGE 1: Build Stage
# ──────────────────────────────────────────────
# Purpose: Install dependencies, build the React app into static HTML/CSS/JS files
# Base image: node:18-alpine (small Linux + Node.js 18)

FROM node:18-alpine AS build

# Set working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json FIRST (for Docker layer caching)
# Docker caches each layer. If package.json hasn't changed, Docker reuses
# the cached node_modules instead of running npm install again — saves time!
COPY package*.json ./

# Install all dependencies (including devDependencies needed for build)
RUN npm ci --silent

# Now copy the rest of the application source code
COPY . .

# Set environment variables for the build
# These get baked into the static files during build
ARG REACT_APP_VERSION=1.0.0
ARG REACT_APP_ENV=production
ARG REACT_APP_BUILD_DATE
ENV REACT_APP_VERSION=$REACT_APP_VERSION
ENV REACT_APP_ENV=$REACT_APP_ENV
ENV REACT_APP_BUILD_DATE=$REACT_APP_BUILD_DATE

# Build the React app — outputs to /app/build folder
RUN npm run build

# ──────────────────────────────────────────────
# STAGE 2: Production Stage
# ──────────────────────────────────────────────
# Purpose: Serve the built static files using Nginx
# Base image: nginx:alpine (~40MB — very lightweight)
# NOTE: Node.js is NOT included here — we only need the built files

FROM nginx:alpine AS production

# Remove default Nginx configuration
RUN rm /etc/nginx/conf.d/default.conf

# Copy our custom Nginx configuration
# This configures: port 8080, gzip compression, caching headers, SPA routing
COPY nginx.conf /etc/nginx/conf.d/

# Copy the built React app from Stage 1 into Nginx's serving directory
# --from=build references Stage 1 above
COPY --from=build /app/build /usr/share/nginx/html

# Expose port 8080 (the port Nginx listens on per our nginx.conf)
EXPOSE 8080

# Health check — Docker/ECS uses this to verify the container is healthy
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:8080/ || exit 1

# Start Nginx in the foreground (required for Docker — daemon mode would exit)
CMD ["nginx", "-g", "daemon off;"]
