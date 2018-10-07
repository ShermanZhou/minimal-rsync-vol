## A minimalistic rsync docker container

### Purpose
On none-linux platform, docker volume that is mapped to host folder is 60x slower than Mac native disk I/O; inspired by docker-compose project (which depends on ruby gem), I created this minimalistic container for developing nodejs application. It will help me to avoid installing nodejs' billion packages on my mac that when invoked have full read/write access on my machine.

### Principle
- run this container that has a built-in rsync daemon running.
- sync source code from host folder to this container using rsync
- share this container's volume with nodejs container
- build nodejs application inside docker container

### Issues of One Way Sync
- I personally experienced unstable docker-compose with Mac-Native / Unison strategy, found that rsync strategy is great. However, rsync is oneway (from host to container).
- If you create / commit git branch inside container, your host doesn't have the git branch.
- If you create / commit git branch on host; the git hook that invokes unit testing and linting will fail.

### Solutions I need to document
- rsync can sync both way; but can't sync both way simutaneously, we can create one script for each way; from container back to host, we only need to sync the project/.git folder.

### Scripts
- run the built rsync container with a name
``` run the built rsync container with a name.
# (remove --rm if you want to keep it detached)
# you can't access container on mac using 172.17.0.2:873 directly, so map port to localhost
docker run --rm -p 873:873 --name temp-rsync  sherman/rsync:1.0
```
**syntax: the trailing '/' only matters for src path, it prevent the path itself being copied.**

** if permission failed when sync .git files, remove rsync -a (archive) option.
- sync data IN to container
```
rsync -vr approot/ localhost::data
```

- sync .git/ OUT to host
```
rsync -rv localhost::data/.git approot/
```
