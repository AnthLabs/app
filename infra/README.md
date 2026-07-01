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
2. Le présentateur téléverse une vidéo depuis le front.
3. L'API Rust sauvegarde la source dans `media/uploads`.
4. L'API génère une clé AES-128 dans `media/keys`.
5. L'API convertit la vidéo en HLS chiffré dans `media/hls/<asset>/master.m3u8`.
6. NGINX principal sert uniquement les playlists et segments présents dans `media/hls`.
7. Le lecteur demande la clé AES au serveur de clés à l'aide du token embarqué dans la playlist.
8. Le serveur valide le token avant de retourner la clé.
9. Sans token valide, les segments restent chiffrés et ne peuvent pas être lus.
10. Les événements de lecture pourront ensuite alimenter le pôle IA & Data.

---

## Flux applicatif principal

Le flux utilisé par l'application passe par le Docker Compose principal :

```bash
docker compose -f docker-compose.base.yml -f docker-compose.front.yml up -d --build
```

Cette stack lance MongoDB, NGINX, l'API Rust et le serveur de clés Python.

Le front ne connaît qu'une URL HLS classique. La différence est côté API : les playlists générées pointent vers le key-server pour récupérer la clé AES.

Variables importantes :

- `PUBLIC_MEDIA_URL` : URL publique de NGINX pour les playlists et segments.
- `KEY_SERVER_PUBLIC_URL` : URL publique du serveur de clés vue par le navigateur.
- `KEY_TOKEN_SECRET` : secret partagé entre l'API Rust et le key-server Python.
- `KEY_TOKEN_TTL_SECONDS` : durée de vie du token embarqué dans la playlist.

---

## Démonstrateur infra autonome

Le compose `infra/docker/docker-compose.infra.yml` reste disponible pour démontrer la couche infra seule, sans lancer l'API Rust.

Depuis le repository `app`, à lancer séparément de la stack principale ou avec des ports modifiés :

```bash
cp infra/docker/.env.example infra/docker/.env
docker compose \
  --env-file infra/docker/.env \
  -f infra/docker/docker-compose.infra.yml \
  up -d --build
```

### Générer un token autonome

```bash
./infra/scripts/create-key-token.sh demo 3600
```

### Convertir une vidéo en HLS chiffré hors API

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

- le token est embarqué dans la playlist générée par l'API ou par le script autonome ;
- la démonstration reste simple, rapide et reproductible ;
- l'objectif est de démontrer le fonctionnement de la chaîne :

```text
NGINX → HLS chiffré → Serveur de clés
```

### Version cible

Dans une architecture plus proche d'un environnement de production :

- l'API Rust valide l'utilisateur et son accès au salon ;
- l'API génère un manifest signé par session ou une URL de clé à durée de vie très courte ;
- le lecteur ne reçoit jamais une playlist statique contenant un token durable.

---

## Notes

- `media/uploads/` contient les vidéos sources et reste privé.
- `media/hls/` contient les playlists et segments HLS chiffrés servis par NGINX.
- `media/keys/` contient les clés AES et ne doit jamais être exposé publiquement.
