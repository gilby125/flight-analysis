-- Initialize flight analysis database
CREATE USER flight_user WITH PASSWORD 'flight_pass';
CREATE DATABASE flight_db;
GRANT ALL PRIVILEGES ON DATABASE flight_db TO flight_user;

-- Create extension if needed
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";