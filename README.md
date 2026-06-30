# AnthApp

To clone the main repository and initialize all submodules at the same time, use:

```bash
git clone --recurse-submodules https://github.com/AnthLabs/app.git
```

To run the projet as a frontend dev, use:

```bash
sudo docker compose -f docker-compose.base.yml -f docker-compose.front.yml up -d --build
```
> this will allow you to use nginx, mongodb and the api

To run the project as a api dev, use:

```bash

sudo docker compose -f docker-compose.base.yml -f docker-compose.api.yml up -d
```
> this will allow you to use nginx and mongodb.

# Working with Git Submodules

This repository contains two Git submodules:

* `front/`
* `api/`

Each submodule is an independent Git repository. Changes made inside a submodule must first be committed and pushed from that submodule, then the updated commit reference must be committed in the main repository.

## Making Changes in a Submodule

When working inside `front/` or `api/`, commit and push your changes from the corresponding submodule.

Example with the `api/` submodule:

```bash
cd api

git add .
git commit -m "feat: describe your changes"
git push
```

The same workflow applies to the `front/` submodule:

```bash
cd front

git add .
git commit -m "feat: describe your changes"
git push
```

## Updating the Submodule Reference

After pushing changes from a submodule, return to the main repository.

The main repository must record the new commit used by the submodule:

```bash
cd ..

git add api
git commit -m "chore: update api submodule reference"
git push
```

For the `front/` submodule:

```bash
git add front
git commit -m "chore: update front submodule reference"
git push
```

You can check which submodule references have changed with:

```bash
git status
```

## Pulling Changes from the Main Repository

To retrieve the latest changes from the main repository and update the submodules to the commits recorded by it, run:

```bash
git pull
git submodule update --init --recursive
```

This is the recommended command sequence for keeping your local repository synchronized with the versions committed in the main repository.
