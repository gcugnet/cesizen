# cesizen
A minimalist application to help people be aware of their mental health.

## Development

You should have [Nix](https://nixos.org/) installed on you machine in order to build the project's
environment.

1. Clone this repository
2. run `direnv allow` to build the project's environment.

### Backend

1. Install dependencies:
    ```
    mix deps.get
    ```

2. Create and seed the database with a project's script:
    ```
    reset-db
    ```

3. From within the `./backend` directory, start the web server:
    ```
    mix phx.server
    ```

4. **Congratulations 🥳**, you can play with the application!

### Frontend

1. Install dependencies:
    ```
    cargo install dioxus-cli && npm install
    ```

2. Start the Tailwind watcher with a project's script:
    ```
    start-tailwind
    ```

3. In another terminal, from within `./frontend/cesizen-app`, start the Dioxus
   development server:
    ```
    dx serve
    ```

4. **Congratulations 🥳**, you can play with the application!

## Documentation

### Backend

#### Entity-Relationship Diagram

```mermaid
---
title: CesiZen relations
---

erDiagram
    USER ||--o{ EMOTION_LOG : "one to many"
    EMOTION ||--o{ EMOTION_LOG : "one to many"
    BASIC_EMOTION ||--o{ EMOTION : "one to many"
    CATEGORY ||--o{ CONTENT : "has many"
    USER {
        id uuid PK "required"
        name ci_string "required"
        email ci_string "required, unique"
        password string "required, sensitive"
        role atom "required, default :user"
    }
    BASIC_EMOTION {
        id uuid PK "required"
        name ci_string "required, unique"
    }
    EMOTION {
        id uuid PK "required"
        basic_emotion_id uuid FK "required"
        name ci_string "required, unique"
    }
    EMOTION_LOG {
        id uuid PK "required"
        user_id uuid FK "required"
        emotion_id uuid FK "required"
        created_at timestamp "required"
        updated_at timestamp "required"
    }
    CATEGORY {
        id uuid PK "required"
        name ci_string "required, unique"
        description string
    }
    CONTENT {
        id uuid PK "required"
        category_id uuid FK "required"
        type atom "required, :text or :image"
        title string "required"
        body string
    }

```
