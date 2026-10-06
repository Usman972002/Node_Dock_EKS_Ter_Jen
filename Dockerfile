FROM node:22-alpine AS base            
WORKDIR /app                           

COPY package*.json ./                  
RUN npm ci --omit=dev && npm cache clean --force   

COPY --chown=node:node src ./src       

ENV NODE_ENV=production                
EXPOSE 8000                            

USER 1000:1000                         
CMD ["node", "src/index.js"]   
