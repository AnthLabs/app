# Reproductibilité

L'objectif est de pouvoir reconstruire l'environnement de démonstration en quelques minutes sur n'importe quel poste de développement.

---

## Docker Compose

Docker Compose constitue le point d'entrée principal pour lancer la démonstration.

Depuis le repository `app` :

```bash
cp infra/docker/.env.example infra/docker/.env

docker compose \
  --env-file infra/docker/.env \
  -f infra/docker/docker-compose.infra.yml \
  up -d --build
```

Services disponibles :

| Service | URL |
|---------|-----|
| CDN NGINX | http://localhost:8080 |
| Key Server | http://localhost:8090 |
| Healthcheck | http://localhost:8090/health |

---

## Terraform

Terraform est volontairement limité.

Son objectif est uniquement de démontrer une approche **Infrastructure as Code** locale.

Il décrit :

- le réseau Docker ;
- le conteneur NGINX ;
- les volumes nécessaires au streaming.

Utilisation :

```bash
cd infra/terraform

terraform init
terraform apply
```

Le serveur de clés reste volontairement piloté par Docker Compose afin de conserver une démonstration simple.

---

## Organisation des médias

```text
media/
├── uploads/
│   └── vidéos sources (privées)
│
├── hls/
│   └── playlists + segments HLS chiffrés
│
└── keys/
    └── clés AES privées
```

Le dossier `media/keys` ne doit jamais être versionné, à l'exception du fichier `.gitkeep` utilisé pour conserver l'arborescence Git.