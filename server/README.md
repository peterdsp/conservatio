# Conservatio API Server

Ktor-based REST API server for the Conservatio platform. Designed to run on a Raspberry Pi 4 alongside PostgreSQL.

## Stack

- Ktor 3.0 (Netty engine)
- Exposed ORM (Kotlin SQL framework)
- PostgreSQL 16
- JWT authentication with bcrypt password hashing
- Local filesystem image storage

## Endpoints

### Auth
- `POST /api/auth/register` - Create account
- `POST /api/auth/login` - Get JWT token

### Objects (requires auth)
- `GET /api/objects` - List user's objects
- `GET /api/objects/:id` - Get object detail
- `POST /api/objects` - Create object
- `DELETE /api/objects/:id` - Delete object

### Reports (requires auth)
- `GET /api/reports?objectId=` - List reports
- `POST /api/reports` - Create report
- `DELETE /api/reports/:id` - Delete report

### Images (requires auth)
- `POST /api/images` - Upload image (multipart)
- `GET /api/images/:imageId` - Download image

### Projects and Clients
- `GET /api/projects` - List projects (stub)
- `GET /api/clients` - List clients (stub)

## Development

```bash
./gradlew :server:run
```

## Docker deployment (Raspberry Pi)

From the project root:

```bash
./gradlew :server:fatJar
docker compose up -d
```

Data is stored on the external HDD at `/mnt/media/conservatio/`.

## Environment variables

| Variable | Default | Description |
|----------|---------|-------------|
| DATABASE_URL | jdbc:postgresql://localhost:5432/conservatio | Postgres connection |
| DATABASE_USER | conservatio | DB username |
| DATABASE_PASSWORD | conservatio | DB password |
| JWT_SECRET | (dev default) | JWT signing secret |
| STORAGE_PATH | /data/conservatio/images | Image storage directory |
| PORT | 8080 | Server port |
