FROM node:18-alpine AS build

WORKDIR /usr/src/app

# Copy package.json and package-lock.json to leverage Docker's cache
COPY package*.json ./

RUN npm ci --only=production

COPY . .

# Optional: Run the build command if your app has a build step (e.g., for React/Next.js)
# RUN npm run build

# Stage 2: Run Stage
# Use a minimal Node.js Alpine image to run the app
FROM node:18-alpine

WORKDIR /usr/src/app

# Copy only the necessary files from the build stage
COPY --from=build /usr/src/app .

# Set the environment variable to production
ENV NODE_ENV=production

RUN addgroup -S nodegroup && adduser -S nodeuser -G nodegroup
USER nodeuser

EXPOSE 3000

CMD ["npm", "start"]

# Optional: Add a health check to monitor app health
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s CMD curl --fail http://localhost:3000 || exit 1
