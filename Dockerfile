
# Use official Node LTS image
FROM node:20-bullseye-slim

# Create app directory
WORKDIR /usr/src/app

# Install pnpm globally to match the project's packageManager (pnpm@10.17.1)
RUN npm install -g pnpm@10.17.1

# Copy package manifests first for better layer caching
COPY package.json pnpm-lock.yaml ./

# Install dependencies according to the lockfile.
RUN pnpm install --frozen-lockfile

# Copy the rest of the project (includes db.json and src/)
COPY . .

# Expose a port if the app listens (no harm if unused)
EXPOSE 3000

# Default command: run npm start which runs `tsx index.ts` per package.json
CMD ["npm", "start"]
