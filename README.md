# Tasky Project

A project management and task tracking application built with Vue 3, Quasar Framework, Node.js (Express), and MySQL.

## Prerequisites

Make sure you have the following installed on your machine:
- [Node.js](https://nodejs.org/en/) (v18+ recommended)
- [MySQL](https://www.mysql.com/) (v8.0+ recommended)

## Quick Start

Follow these steps to set up the project locally.

### 1. Database Setup

1. Create a MySQL database named `tasky`:
   ```sql
   CREATE DATABASE tasky;
   ```
2. Import the schema and seed data:
   - Import the table structures:
     ```bash
     mysql -u root -p tasky < database/schema.sql
     ```
   - Import the seed data (test users, projects, etc.):
     ```bash
     mysql -u root -p tasky < database/seed.sql
     ```

### 2. Backend (Server) Setup

1. Navigate to the `server` directory:
   ```bash
   cd server
   ```
2. Install the backend dependencies:
   ```bash
   npm install
   ```
3. Set up the environment variables:
   - Copy the example `.env` file:
     ```bash
     cp .env.example .env
     ```
   - Open `.env` and update the `DB_USER` and `DB_PASSWORD` to match your local MySQL credentials.
4. Start the backend server:
   ```bash
   npm start
   ```
   The backend should now be running on `http://localhost:3001`.

### 3. Frontend Setup

1. Open a new terminal and navigate to the project root directory.
2. Install the frontend dependencies:
   ```bash
   npm install
   ```
3. Set up the environment variables:
   - Copy the example `.env` file:
     ```bash
     cp .env.example .env
     ```
4. Start the frontend development server:
   ```bash
   npm run dev
   ```
   The frontend will be accessible at `http://localhost:9000` (or another port depending on your Quasar configuration).

## Test Accounts

The seed data provides a few test accounts to log in with:
- **Project Manager:** `pm@tasky.com` (Password: `password123`)
- **Employee:** `employee1@tasky.com` (Password: `password123`)

## Contributing
When adding new features, please ensure:
- Your code follows the ESLint and Prettier configurations.
- You do not commit `.env` files.
- Any database changes are accompanied by an updated `schema.sql`.