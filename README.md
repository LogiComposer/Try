![Zoomdata logo](https://www.zoomdata.com/sites/all/themes/zoomadu/logo.svg)

# Zoomdata try and buy docker based distribution.

To try latest Zoomdata clone this repo (or download as zip file) and execute this code in your terminal<p>
Linux:
```bash
cd latest
./try-zoomdata.sh up --build --detach
```
Windows:
```bash
cd latest
./try-zoomdata.ps1 up --build --detach
```

make sure you have `docker` and `docker-compose` installed before running this commands.

# Zoomdata login info

Zoomdata instance is available at [http://localhost:8080/](http://localhost:8080/)

Use `admin/admin` user/password to access data and visualizations\
Use `supervisor/supervisor` user/password to configure the instance

# Wrapper script additionals
wrapper scripts (`try-zoomdata.sh` and `try-zoomdata.ps1`) can consume regular `docker-compose` command as input. More to read [here](https://docs.docker.com/compose/reference/).<p>
Common actions:
- to stop all containers:
```bash
./try-zoomdata.sh stop
```
- to remove all stopped containers:
```bash
./try-zoomdata.sh rm -f
```

# Windows related steps

- download and install [git](https://git-scm.com/download/win). 
- make sure to set git default behavoiur of new line chars handling before cloning the repository
```bash
git config --global core.autocrlf false
```
