# Steps

## 1. Setup Lab - Optional

```bash
# Build image
docker build -t ssh-node -f Dockerfile.lab .
docker run -d --privileged --rm --name ssh-test -p 2222:22 -p 3001:3000 ssh-node
# ssh devuser@localhost -p 2222
```

## 2. Build Image

```bash
docker build -t my-app:latest .
```

## 3. Save Image

```bash
docker save -o my-app.tar my-app:latest
```

## 4. Transfer the file

```bash
scp -P 2222 ./my-app.tar ./docker-compose.yml devuser@localhost:/home/devuser/
```

## 5. SSH into remote device

```bash
ssh devuser@localhost -p 2222
```

## 6. Load & Run Image

```bash
docker load -i my-app.tar
docker compose up -d
docker compose logs -f app
```
