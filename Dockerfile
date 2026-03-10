# Use Node.js LTS version
FROM node:20-alpine

# Set working directory
WORKDIR /app

# Copy package.json and package-lock.json (if exists)
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy source code and tests
COPY src ./src
COPY tests ./tests
COPY tsconfig.json ./

# Run tests by default
CMD ["npm", "run", "test"]