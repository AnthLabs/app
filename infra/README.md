# Infrastructure

Ce dossier centralise le travail **Infrastructure, Sécurité & Cloud** de **V-Secure & Collaborate** dans le repository d'orchestration `app`.

Le choix est volontaire : l'infrastructure reste proche du front, de l'API, des médias et de Docker Compose, sans créer un quatrième repository `infra`.

## Structure

- `nginx/` : configuration du CDN local NGINX pour les playlists HLS et les segments chiffrés.
- `docker/` : services locaux reproductibles pour NGINX et le serveur de clés éphémères.
- `scripts/` : scripts de packaging HLS chiffré et de génération de tokens de démonstration.
- `terraform/` : description IaC locale volontairement simple.
- `docs/` : documentation d'architecture, modèle de menace et reproductibilité.

---

## Parcours de démonstration

1. L'application React rejoint un salon **Watch Together**.
2. Le présentateur lance une vidéo.
3. Le lecteur charge une playlist HLS servie par NGINX.
4. NGINX sert uniquement les playlists et segments présents dans `media/hls`.
5. Les vidéos sources (`media/uploads`) et les clés AES (`media/keys`) ne sont jamais exposées publiquement.
6. Le lecteur demande la clé AES au serveur de clés à l'aide d'un token temporaire.
7. Le serveur valide le token avant de retourner la clé.
8. Sans token valide, les segments restent chiffrés et ne peuvent pas être lus.
9. Les événements de lecture pourront ensuite alimenter le pôle IA & Data.

---

## Démarrage local

Depuis le repository `app` :

```bash
cp infra/docker/.env.example infra/docker/.env
docker compose \
  --env-file infra/docker/.env \
  -f infra/docker/docker-compose.infra.yml \
  up -d --build
```

### Générer un token

```bash
./infra/scripts/create-key-token.sh demo 3600
```

### Convertir une vidéo en HLS chiffré

```bash
./infra/scripts/generate-hls.sh media/uploads/demo.mp4 demo
```

### Playlist HLS

```text
http://localhost:8080/media/hls/demo/master.m3u8
```

### Vérifier l'état du serveur de clés

```text
http://localhost:8090/health
```

### Endpoint de récupération de clé

```text
http://localhost:8090/keys/demo.key?token=<temporary-token>
```

---

## Limites assumées du prototype

### Version Hackathon

- le token est embarqué dans la playlist générée ;
- la démonstration reste simple, rapide et reproductible ;
- l'objectif est de démontrer le fonctionnement de la chaîne :

```text
NGINX → HLS chiffré → Serveur de clés
```

### Version cible

Dans une architecture plus proche d'un environnement de production :

- l'API Rust valide l'utilisateur et son accès au salon ;
- l'API génère un manifest signé ou une URL de clé à durée de vie très courte ;
- le lecteur ne reçoit jamais une playlist statique contenant un token durable.

---

## Notes

- `media/uploads/` contient les vidéos sources et reste privé.
- `media/hls/` contient les playlists et segments HLS chiffrés servis par NGINX.
- `media/keys/` contient les clés AES et ne doit jamais être exposé publiquement.