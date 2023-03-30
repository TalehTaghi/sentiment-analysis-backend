###################
# BUILD FOR LOCAL DEVELOPMENT
###################

FROM node:18-bullseye-slim As development

# Install Python 3 and pip
RUN apt-get update && apt-get install python3-pip -y

# Install joblib and scikit-learn
RUN pip3 install joblib && pip3 install scikit-learn

# Create app directory
WORKDIR /usr/src/app

# Copy application dependency manifests to the container image.
# A wildcard is used to ensure copying both package.json AND package-lock.json (when available).
# Copying this first prevents re-running npm install on every code change.
COPY --chown=node:node package*.json ./

# Install app dependencies using the `npm ci` command instead of `npm install`
RUN npm ci

# Bundle python files
COPY nlp/ nlp/

# Bundle app source
COPY --chown=node:node . .

# Use the node user from the image (instead of the root user)
USER node

###################
# BUILD FOR PRODUCTION
###################

FROM node:18-bullseye-slim As build

# Create app directory
WORKDIR /usr/src/app

# Copy application dependency manifests to the container image.
# A wildcard is used to ensure copying both package.json AND package-lock.json (when available).
# Copying this first prevents re-running npm install on every code change.
COPY --chown=node:node package*.json ./

# In order to run `npm run build` we need access to the Nest CLI.
# The Nest CLI is a dev dependency,
# In the previous development stage we ran `npm ci` which installed all dependencies.
# So we can copy over the node_modules directory from the development image into this build image.
COPY --chown=node:node --from=development /usr/src/app/node_modules ./node_modules

# Bundle python files
COPY nlp/ nlp/

# Bundle app source
COPY --chown=node:node . .

# Run the build command which creates the production bundle
RUN npm run build

# Set NODE_ENV environment variable
ENV NODE_ENV production

# Running `npm ci` removes the existing node_modules directory.
# Passing in --only=production ensures that only the production dependencies are installed.
# This ensures that the node_modules directory is as optimized as possible.
RUN npm ci --only=production && npm cache clean --force

# Use the node user from the image (instead of the root user)
USER node

###################
# PRODUCTION
###################

FROM node:18-bullseye-slim As production

# Install Python 3 and pip
RUN apt-get update && apt-get install python3-pip -y

# Install joblib and scikit-learn
RUN pip3 install joblib && pip3 install scikit-learn

# Set NODE_ENV environment variable
ENV NODE_ENV production

# Copy the bundled code from the build stage to the production image
COPY --chown=node:node --from=build /usr/src/app/node_modules ./node_modules
COPY --chown=node:node --from=build /usr/src/app/dist ./dist
COPY --chown=node:node --from=build /usr/src/app/nlp ./nlp

# Start the server using the production build
CMD [ "node", "dist/main.js" ]