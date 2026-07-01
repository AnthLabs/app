# Modèle de menace

Ce document résume les principaux éléments à protéger, les mécanismes de sécurité mis en place et les limites connues du prototype.

---

## Assets à protéger

- Vidéos sources dans `media/uploads`.
- Playlists HLS et segments chiffrés dans `media/hls`.
- Clés AES-128 dans `media/keys`.
- Tokens temporaires d'accès aux clés.
- Appartenance aux salons Watch Together.
- Événements de lecture destinés au futur pôle IA & Data.

---

## Protections mises en place

- Les clés HLS ne sont jamais exposées par le serveur statique NGINX.
- Les vidéos sources `media/uploads` ne sont pas servies par NGINX.
- L'accès à une clé exige un token signé avec une date d'expiration.
- Les tokens sont scopés à un asset précis.
- Les réponses du serveur de clés utilisent `Cache-Control: no-store`.
- Le CORS du serveur de clés est limité par configuration, par défaut à `http://localhost:5173`.
- Les playlists et segments HLS sont servis avec des types MIME explicites.
- Le serveur de clés expose un endpoint `/health` pour faciliter la supervision locale.

---

## Risques principaux

- Un token fuité peut permettre de déchiffrer une vidéo jusqu'à son expiration.
- Les playlists statiques avec token embarqué sont acceptables pour la démonstration, mais ne sont pas adaptées à une version cible.
- AES-128 HLS protège les segments contre un accès sans clé, mais ne constitue pas un DRM.
- Les secrets de développement local ne doivent pas être utilisés en production.
- Sans HTTPS, un environnement exposé hors local pourrait révéler les tokens ou les clés sur le réseau.

---

## Limites assumées du prototype

### Version Hackathon

- le token est embarqué dans la playlist générée par l'API Rust ou par le script autonome ;
- le serveur de clés vérifie la signature, l'asset et l'expiration ;
- la chaîne sécurisée est démontrable via l'upload applicatif réel ;
- l'objectif est de prouver le fonctionnement du flux sécurisé, pas de fournir une solution DRM complète.

### Version cible

Dans une architecture plus proche d'un environnement de production :

- l'émission des tokens resterait dans l'API Rust, mais après validation forte de l'utilisateur et de son accès au salon ;
- les manifests seraient générés ou signés par utilisateur/session ;
- les URLs de clés auraient une durée de vie très courte ;
- les clés pourraient être tournées par asset, par session ou par période ;
- TLS serait placé devant NGINX et le serveur de clés ;
- les événements de lecture seraient envoyés au pipeline IA & Data via des appels API authentifiés.

---

## Conclusion

Le prototype apporte une protection réaliste pour un contexte de hackathon : les vidéos sources et les clés ne sont pas exposées directement, les segments HLS restent chiffrés, et l'accès aux clés passe par un contrôle de token temporaire.

La solution ne remplace pas un DRM, mais elle démontre une approche Zero-Trust simple, lisible et intégrable à la plateforme.
