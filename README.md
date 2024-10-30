# Chat with LLM

A web application that allows users to have conversations with Large Language Models (LLMs) through a clean, simple interface. Built with Ruby on Rails backend (GraphQL API) and React frontend using the OpenRouter API.

## Features

- Create new chats with different LLM models
- View chat history and continue conversations
- Real-time model responses
- Display of pricing per million tokens for each model
- Easy chat management (view, create, delete)

## Tech Stack

Backend:
- Ruby on Rails
- GraphQL API
- SQLite database

Frontend:
- React with TypeScript
- Vite & Bun
- Apollo Client for GraphQL
- Tailwind CSS
- Lucide React icons

## Setup

### Backend

1. Clone the repository
2. Navigate to the root directory
3. Install dependencies:
```bash
bundle
```
4. Setup database:
```bash
rails db:create db:migrate
```
5. Start the Rails server:
```bash
rails s
```

### Frontend

1. Navigate to the frontend directory:
```bash
cd frontend
```
2. Install dependencies:
```bash
bun install
```
3. Start the development server:
```bash
bun dev
```
