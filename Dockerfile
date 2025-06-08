# Preparation
# - Preparation and Setup:
#   - IMPORTANT!!!
#       To deploy directly to the "dist" folder, change
#       `angular.json -> projects -> architect -> build -> options -> outputPath` to:
#          "outputPath": {
#              "base": "dist",
#              "browser": ""
#          },
#       THIS MAY GET CHANGED DURING ANGULAR UPGRADES (e.g. Angular 17 to 18).
#       Symptom: Instead of seeing the Angular site, you'll just see the nginx homepage.

# Multi-stage
# 1) Node image for building frontend assets
# 2) nginx stage to serve frontend assets

# Stage 1: Build the Angular app
FROM node:18-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package.json and package-lock.json to install dependencies
COPY package.json package-lock.json ./

# Install dependencies
RUN npm install

# Copy all files from current directory to working dir in image
COPY . .

# Build the Angular app
RUN npm run build --prod

# Stage 2: Serve the app with NGINX
FROM nginx:alpine

# Copy static assets from builder stage
COPY --from=builder /app/dist /usr/share/nginx/html

# Containers run nginx with global directives and daemon off
ENTRYPOINT ["nginx", "-g", "daemon off;"]
