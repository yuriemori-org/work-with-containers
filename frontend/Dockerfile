# Use Node.js LTS
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install only production dependencies
RUN npm ci --omit=dev

# Copy the pre-built application
COPY dist ./dist

# Expose port
EXPOSE 3000

# Start the application
CMD ["npm", "start"]