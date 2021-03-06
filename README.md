## A minimalistic rsync docker container for MacOS

### Purpose
On none-linux platform, docker volume that is mapped to host folder is 60x slower than Mac native disk I/O; inspired by docker-sync project (which depends on ruby gem, but you will need to upgrade your Mac's stock version), I created this minimalistic container for developing nodejs application. It will help me to avoid installing nodejs' billion packages on my mac that when invoked have full read/write access on my machine.

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

### git option as cross-platform requirement
for unix: 
```
git config --global core.autocrlf input
```
for windows
```
git config --global core.autocrlf true
```
### Scripts
- run the built rsync container with a name
``` run the built rsync container with a name.
# (remove --rm if you want to keep it detached)
# you can't access container on mac using 172.17.0.2:873 directly, so map port to localhost
docker run --rm -p 873:873 --name temp-rsync  sherman/rsync:1.0
```
- **syntax: the trailing '/' only matters for src path, it prevent the path itself being copied.**
- **if permission failed when sync .git files, remove rsync -a (archive) option.**
- **generally don't sync out any non-source-controlled build results, don't add file in container**


- sync data IN to container "in_sync.sh"
```
rsync -rv approot/ localhost::data
# for custom port
rsync -rv approot/ rsync://localhost:12301/data
```
if you have permission issues, make sure run 
``` in container
# chmod 777 -R /home/rysnc
```
- to diagnose rsync end point in container

```
$rsync -rdt rsync://HOST:port # list folders
$rsync -rdt rsync://HOST:port/data # list folder content
```

- sync .git/ OUT to host
```
rsync -rv localhost::data/.git approot/
```
- watching

I slightly modified a golang fsevent repo https://github.com/ShermanZhou/fsevents
compile the fsevents/example/main.go
```
go build -o mac_fsevents
```
To automatically invoke the sync script, copy the tool to parent folder of approot/
```
$ ./mac_fsevents -path approot/ -script "in_sync.sh" -shell "sh"
```
