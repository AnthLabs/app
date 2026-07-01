# Architecture Infrastructure

Le repository `app` constitue le point d'orchestration de la plateforme.

La couche `infra/` centralise l'ensemble des éléments liés au streaming sécurisé sans modifier les responsabilités Git des submodules `front/` et `api/`.

---

## Composants

- **Front React/Vite** : rejoint les salons Watch Together, reçoit les synchronisations de lecture et charge les flux HLS.
- **API Rust** : gère l'authentification, les salons et l'ingestion future des événements de lecture.
- **NGINX** : joue le rôle de CDN local et sert les playlists HLS ainsi que les segments chiffrés.
- **Serveur de clés** : valide un token signé à durée de vie limitée avant de retourner la clé AES.
- **Pipeline IA & Data** : exploitera ultérieurement les événements de lecture.

---

## Flux de requêtes

```text
React
   │
   ▼
NGINX
   │
   ├── master.m3u8
   ├── segment_001.ts
   ├── segment_002.ts
   └── ...

React
   │
   ▼
Key Server
   │
   ▼
media/keys/<asset>.key
```

Les segments HLS sont publics mais restent inutilisables sans la clé AES.

Les vidéos sources (`media/uploads`) ne sont jamais exposées afin d'empêcher tout contournement du flux HLS.

---

## Prototype vs Production

### Prototype Hackathon

Le script de packaging génère une playlist contenant un token temporaire.

Ce choix simplifie la démonstration tout en permettant d'illustrer le fonctionnement complet de la chaîne de diffusion sécurisée.

### Version cible

Dans une architecture de production :

- l'API Rust valide l'utilisateur ;
- l'API génère un manifest signé par session ;
- les URLs des clés deviennent temporaires ;
- les événements de lecture remontent vers l'API afin d'alimenter le pôle IA & Data.

---

## Frontière des repositories

Le dossier `infra/` appartient volontairement au repository `app` car il décrit l'orchestration de la plateforme :

- Docker ;
- NGINX ;
- Infrastructure locale ;
- Streaming sécurisé ;
- Documentation.

Les repositories `front` et `api` restent totalement indépendants et consommeront simplement les services exposés par cette couche.