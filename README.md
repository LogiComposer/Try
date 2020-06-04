![LogiComposer logo](/images/logicomposer-logo.png)

# Logi Composer try and buy docker based distribution.

To try latest Logi Composer, clone this repo (or download as zip file) and execute this code in your terminal<p>
Linux:
```bash
cd latest
./try-logicomposer.sh up --build --detach
```
Windows:
```bash
cd latest
./try-logicomposer.ps1 up --build --detach
```

make sure you have `docker` and `docker-compose` installed before running this command.

# Logi Composer login info

Logi Composer instance is available at [http://localhost:8080/](http://localhost:8080/)

Use `admin/admin` user/password to access data and visualizations\
Use `supervisor/supervisor` user/password to configure the instance

# Wrapper script additionals
Wrapper scripts (`try-logicomposer.sh` and `try-logicomposer.ps1`) can consume regular `docker-compose` command as input. More to read [here](https://docs.docker.com/compose/reference/).<p>
Common actions:
- to stop all containers:
```bash
./try-logicomposer.sh stop
```
- to remove all stopped containers:
```bash
./try-logicomposer.sh rm -f
```

# Windows related steps

- download and install [git](https://git-scm.com/download/win). 
- make sure to set git default behavior of new line chars handling before cloning the repository
```bash
git config --global core.autocrlf false
```
