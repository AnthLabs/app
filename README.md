# AnthApp

AnthApp est le repository d'orchestration de la plateforme **V-Secure & Collaborate**.

Il relie le front React, l'API Rust, le stockage média local, NGINX, Docker et la couche infrastructure du hackathon.

## Lancer l'application:
```bash
git clone --recurse-submodules https://github.com/AnthLabs/app.git
cp .env.example .env
docker compose up -d --build
```
Après ces commandes pour aurez accès à l'application sur votre localhost ou le addresse ip de la machine qui a lancé l'application au port que vous avez renseigné dans le .env (généralement http://localhost:8080)

## Organisation

- `front/` : submodule React / Vite.
- `api/` : submodule API Rust.
- `media/` : stockage local des médias.
- `infra/` : couche Infrastructure, Sécurité & Cloud.
- `docker-compose.base.yml` : socle commun.
- `docker-compose.front.yml` : dépendances nécessaires au développement front.
- `docker-compose.api.yml` : dépendances nécessaires au développement API.

Les fichiers `docker-compose.*.yml` décrivent les dépendances nécessaires pour travailler sur un module donné.  
Ils ne correspondent pas forcément à un service unique portant le même nom.

## Couche infrastructure

Le travail infrastructure vit dans [`infra/`](infra/README.md), afin de garder une plateforme cohérente sans ajouter un quatrième repository.

Cette couche fournit :

- un CDN local NGINX pour les playlists HLS et les segments `.ts` chiffrés ;
- des scripts de packaging HLS AES-128 ;
- un serveur de clés éphémères qui valide des tokens temporaires signés ;
- une configuration Docker Compose dédiée à la reproduction locale ;
- des fichiers Terraform décrivant une approche IaC locale volontairement simple ;
- une documentation d'architecture, de menace et de reproductibilité.

Le flux applicatif principal chiffre maintenant les vidéos uploadées par l'API Rust en HLS AES-128. NGINX sert les playlists et segments, tandis que le serveur de clés Python valide le token temporaire avant de retourner la clé AES.

Lancer la démonstration applicative :

```bash
docker compose -f docker-compose.base.yml -f docker-compose.front.yml up -d --build
```

La stack infra isolée reste disponible comme démonstrateur autonome :

```bash
cp infra/docker/.env.example infra/docker/.env
docker compose --env-file infra/docker/.env -f infra/docker/docker-compose.infra.yml up -d --build
```

## Cloner le projet

    ```bash
    git clone --recurse-submodules https://github.com/AnthLabs/app.git
    ```

## Lancer le socle commun

    ```bash
    docker compose -f docker-compose.base.yml up -d --build
    ```

Ce socle lance :

- MongoDB ;
- NGINX pour les médias HLS.

## Développement front

Le front React/Vite est lancé depuis le submodule `front/`.

Le fichier `docker-compose.front.yml` ajoute l'API Rust nécessaire au front :

    ```bash
    docker compose -f docker-compose.base.yml -f docker-compose.front.yml up -d --build
    ```

## Développement API

L'API Rust n'a pas besoin de service additionnel pour l'instant.  
Le fichier `docker-compose.api.yml` existe pour garder une convention homogène :

    ```bash
    docker compose -f docker-compose.base.yml -f docker-compose.api.yml up -d
    ```

## Travailler avec les submodules Git

Ce repository contient deux submodules Git :

- `front/`
- `api/`

Chaque submodule est un repository Git indépendant.

Les changements faits dans un submodule doivent d'abord être commités et poussés depuis ce submodule, puis la référence du submodule doit être mise à jour dans le repository principal.

### Exemple avec `api`

    ```bash
    cd api
    git add .
    git commit -m "feat: describe your changes"
    git push
    ```

    ```bash
    cd ..
    git add api
    git commit -m "chore: update api submodule reference"
    git push
    ```

### Exemple avec `front`

    ```bash
    cd front
    git add .
    git commit -m "feat: describe your changes"
    git push
    ```

    ```bash
    cd ..
    git add front
    git commit -m "chore: update front submodule reference"
    git push
    ```

## Mettre à jour les submodules

    ```bash
    git pull
    git submodule update --init --recursive
    ```
