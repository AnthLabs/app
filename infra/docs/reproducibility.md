# Reproductibilité

L'objectif est de pouvoir reconstruire l'environnement de démonstration en quelques minutes sur n'importe quel poste de développement.

---

## Docker Compose principal

Docker Compose principal constitue le point d'entrée recommandé pour lancer la démonstration applicative complète.

Depuis le repository `app` :

```bash
docker compose -f docker-compose.base.yml -f docker-compose.front.yml up -d --build
```

Services disponibles :

| Service | URL |
|---------|-----|
| Front Vite | http://localhost:5173 |
| API Rust | http://localhost:3000 |
| CDN NGINX | http://localhost:8080 |
| Key Server | http://localhost:8090 |
| Healthcheck Key Server | http://localhost:8090/health |

Le front est toujours lancé depuis le submodule `front/` en développement Vite. La stack Docker fournit l'API, MongoDB, NGINX et le serveur de clés.

---

## Démonstrateur infra autonome

La stack `infra/docker/docker-compose.infra.yml` sert à démontrer NGINX et le key-server sans l'API Rust.

Elle doit être lancée séparément de la stack principale, ou avec des ports modifiés, car elle expose aussi NGINX et le key-server.

```bash
cp infra/docker/.env.example infra/docker/.env

docker compose \
  --env-file infra/docker/.env \
  -f infra/docker/docker-compose.infra.yml \
  up -d --build
```

Services autonomes :

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
