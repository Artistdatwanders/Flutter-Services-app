# Handyman Backend

Node.js backend for the Handyman app using MongoDB.

## Setup

1. Install dependencies:
   ```bash
   npm install
   ```

2. Set up MongoDB:
   - Install MongoDB locally or use MongoDB Atlas
   - Update MONGODB_URI in .env file

3. Seed services:
   ```bash
   npm run seed
   ```

4. Start the server:
   ```bash
   npm run dev
   ```

## API Endpoints

### Auth
- POST /api/auth/register
- POST /api/auth/login

### Jobs
- POST /api/jobs (create job)
- GET /api/jobs (get user's jobs)
- GET /api/jobs/leads (provider leads)
- PUT /api/jobs/:id/accept
- PUT /api/jobs/:id/decline
- PUT /api/jobs/:id/complete

### Services
- GET /api/services

### Users
- GET /api/users/profile
- PUT /api/users/profile

## Real-time Features

Uses Socket.IO for real-time job notifications to providers.