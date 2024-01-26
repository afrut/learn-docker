A playarea for Docker.

# Setup
- Install Docker on Windows: https://docs.docker.com/desktop/install/windows-install/

# Notes
- Create a container in detached mode (`-d`, `--detach`) and (`-p`, `--publish`) map port 80 of host to port 80 of container.
- Detached mode means the container runs in the background and doesn't receive input or display output.
- This automatically downloads an image and starts a container.
- A container is just another process on the host that is isolated.
- An image contains application code, libraries, tools and other dependencies needed by the application.
- Use docker desktop to monitor status of containers and images.
- How to change location where docker stores container images on Windows:
  https://stackoverflow.com/questions/62441307/how-can-i-change-the-location-of-docker-images-when-using-docker-desktop-on-wsl2


# Getting Started
- Start a container.
  ```
  docker run -d -p 80:80 docker/getting-started
  ```

- If the Docker daemon is not running, open Powershell with Admin privileges and execute
  ```
  & 'C:\Program Files\Docker\Docker\DockerCli.exe' -SwitchDaemon
  ```

# Creating your own image
- Sample to do list app is located here:
  https://github.com/docker/getting-started

- Using the Dockerfile in this directory, build an image called todo-app using `-t` (`--tag`).
  - A Dockerfile is a list of text instructions on how to construct an image.
  - Create Dockerfile in directory containing application.
  - Last argument is the directory (`"./sample-app"`) containing the build context.
  ```
  docker build -t todo-app "./sample-app"
  ```

- Run the image
  ```
  docker run -dp 3000:3000 todo-app
  ```

- Build using a `Dockerfile` at a different location. In the `dev` directory:
  ```
  docker build --tag subdir --file some_subdir/Dockerfile .
  ```

## Multi-stage Builds
- Multi-stage builds can be used to reduce the final size of images by building
  all dependencies in one stage, then copying binaries into the final stage.
- Build both singlestage and multistage. Both images contain Python packages.
  `singlestage` contains `python3-pip` and `python3-venv` but `multistage` does not.
  ```
  make build_singlestage
  make build_multistage
  ```
- Inspect image sizes.
  ```
  docker image ls | grep -P "(singlestage|multistage)"
  # multistage              latest    93beca777a40   6 minutes ago    652MB
  # singlestage             latest    74ee2ddf3338   30 minutes ago   1.17GB
  ```

# Managing images
- List all images
  ```
  docker image ls
  ```

- Display detailed information on the image image-id
  ```
  docker image inspect image-id
  ```

- Remove image-id
  ```
  docker image rm image-id
  ```

- Create an image named todo-app from the Dockerfile in the `sample-app` directory.
  ```
  docker image build -t todo-app "./sample-app"
  ```

- Pull the apache/spark image from a registry
  - Find images here: https://hub.docker.com/search?q=
  ```
  docker image pull apache/spark
  ```

- List images with REPOSITORY or TAG of '<none>'.
  ```
  docker image ls | grep "<none>"
  ```

- List image id's of images with REPOSITORY or TAG of '<none>'.
  ```
  docker image ls | grep "<none>" | awk -F ' ' '{print $3}'
  ```

- Remove images with REPOSITORY or TAG of '<none>'.
  ```
  docker image rm $(docker image ls | grep "<none>" | awk -F ' ' '{print $3}')
  ```

# Managing containers
- Run a container indefinitely.
  - By default, a container is terminated when the command it is specified to run terminates.
  - Use the `-t` (`--tty`) flag to run the container indefinitely. `-t` starts a pseudo-tty (terminal).
  - The -d flag can be used to run it in the background.
  ```
  docker run -t -d image-id
  ```

- Run a container indefinitely and interact via a terminal using `-i` (`--interactive`).
  ```
  docker run -it image-id
  ```

- Run a container and name it using `--name`.
  - `--rm` removes the container after it exits.
  ```
  docker run --name subdir --rm subdir
  ```

- Run a command started in a container.
  ```
  CMD='echo Hello, World'
  docker run --name subdir --rm subdir $CMD
  ```

- List all running containers. `-q` (`--quiet`) returns only container id's.
  ```
  docker ps -q
  ```

- List all containers regardless of whether they are running using `-a` (`--all`).
  ```
  docker ps -a
  ```

- Kill a container. This doesn't remove the container and the container will
  still show up on `docker ps -a`.
  ```
  docker kill container-id
  ```

- Kill all running containers. `-q` (`--quiet`) returns only container id's.
  ```
  docker kill $(docker ps -q)
  ```

- Remove a container.
  - This kills and removes the container so that it doesn't show up on `docker ps -a`.
  ```
  docker rm container-id --force
  ```

- Stream a container's logs to STDIN and STDERR using `-f` (`--follow`).
  ```
  docker logs -f container-id
  ```

- Start bash temrinal for container
  ```
  docker exec -it container-id bash
  docker exec -it container-id sh
  ```

- Remove all containers and associated anonymous volumes. `-f` (`--force`).
  ```
  docker rm -f $(docker ps -aq)
  ```

# Volumes and persisting container data
- Create a volume
  - Volumes connect a part of the container filesystem to the host machine's file system.
  - It is used to persist data that is created/updated/deleted on the container.
  ```
  docker volume create db
  ```

- Run while mounting a volume (named volume)
  ```
  docker run -dp 3000:3000 -v volume-name:/path/to/mount todo-app
  docker run -dp 3000:3000 -v db:/etc/todos todo-app
  ```

- Inspect a volume
- On a windows system, it is stored in
  `\\wsl$\docker-desktop-data\data\docker\volumes`
  ```
  docker volume inspect volume-name
  ```

- The following command is used to setup a development container to develop node.js applications
- `-w` (`--workdir`) sets working directory of container
- `-v` (`--volume`) "/path/to/source/data:/path/to/mount" specifies the source and destination paths of the bind mount.
- node:12-alpine is the image.
- sh -c "yarn install && yarn run dev" is the command to run to start the container.
  ```
  docker run -dp 3000:3000 \
      -w /app -v "sample-app:/app" \
      node:12-alpine \
      sh -c "yarn install && yarn run dev"
  ```

- Use the `--mount` flag instead of `--volume`. It is more verbose and explicit.
  - [Reference for `--mount`.](https://docs.docker.com/storage/bind-mounts/)
  - The `--mount` equivalent of the previous command is:
  ```
  docker run --detach --publish 3000:3000 \
      --workdir /app \
      --mount type=bind,source="$(realpath ./sample-app)",destination="/app" \
      node:12-alpine \
      sh -c "yarn install && yarn run dev"
  ```

# Managing volumes
- List all volumes
  ```
  docker volume ls
  ```

- Remove volume with volume id volume-id
  ```
  docker volume rm volume-id
  ```

- Delete all volumes not currently being referenced by any containers
  ```
  docker volume prune --force
  ```

- Find the container currently referencing a volume with volume id volume-id
  ```
  docker container ls -a --filter volume=volume-id
  ```

# Networking and multi-container applications
- Two containers run on the same network can communicate with each other.
- Create a network.
  ```
  docker network create todo-app
  ```

- Start a MYSQL container and attach it to the network.
  - `--network` specifies the network to create this container on
  - `--network-alias` specifies the alias of the container on the network
  - `-v` specifies a named volume
  - `-e` specifies environment variables
  ```
  docker run -d `
      --network todo-app --network-alias mysql `
      -v todo-mysql-data:/var/lib/mysql `
      -e MYSQL_ROOT_PASSWORD=secret `
      -e MYSQL_DATABASE=todos `
      mysql:5.7
  ```

- Test connectivity to the mysql database.
  ```
  docker exec -it <mysql-container-id> mysql -u root -p
  ```

- In mysql prompt, check that the todos database is present. Then quit the mysql prompt.
  ```
  show databases;
  \q
  ```

- Run a container with the image nicolaka/netshoot.
  - This image contains utilities for inspecting and troubleshooting networking issues.
  ```
  docker run -it --network todo-app nicolaka/netshoot
  ```

- Find the the ip address of the mysql container.
  - "mysql" is the parameter given to --network-alias when running the mysql container.
  ```
  dig mysql
  ```

- Use environment variables in the todo-app to specify the connection to the MySQL database.
  - This is not good practice in production. Instead, use the container orchestrator's secrets feature.
  - The image for todo-app has to specifically support these environment variables.
  - Inspect the logs to validate that the development container is using the MySQL database.
  ```
  docker run -dp 3000:3000 `
    -w /app -v "$(pwd):/app" `
    --network todo-app `
    -e MYSQL_HOST=mysql `
    -e MYSQL_USER=root `
    -e MYSQL_PASSWORD=secret `
    -e MYSQL_DB=todos `
    node:12-alpine `
    sh -c "yarn install && yarn run dev"
  ```

- Connect to the MySQL database and validate that data is being written.
  ```
  docker exec -it container-id mysql -p todos
  SELECT * FROM todo_items;
  ```

- Remove a network.
  ```
  docker network rm network-id
  ```

- List all networks
  ```
  docker network ls
  ```

# Cleaning up
- Remove all containers, networks, images and volumes that are not being used.
  ```
  docker system prune --all --force --volumes
  ```

# Using docker-compose
- Check that docker-compose is installed.
  - `docker-compose` is a better way to specify multi-container apps.
  - The specification is a yml file, can be version-controlled, and shared.
  ```
  docker-compose version
  ```

- See sample-app/docker-compose.yml.

- Run the application stack in detached mode (run in terminal's background).
  ```
  docker-compose up -d
  ```

- View logs of docker-compose.
  - The logs of all containers are interleaved into a single stream.
  - The follow flag -f gives live output as the logs are generated.
  ```
  docker-compose logs -f
  ```

- View for container app.
- View the log for a specific service (container) run through docker-compose.
  ```
  docker-compose logs -f app
  ```

- Kill all containers started by docker-compose.
  ```
  docker-compose down
  ```

# Go templates
- Many docker commands have the --format flag that can be used to format output.
  - For example, to return only the container id, image name, and container name from docker container ls:
  ```
  docker container ls --format "{{.ID}};{{.Image}};{{.Names}}"
  ```

- To find out what can be printed
  ```
  docker container ls --format "{{json .}}"
  ```

# Links
- [Dockerfile Reference](https://docs.docker.com/engine/reference/builder/)
- [`docker build`](https://docs.docker.com/engine/reference/commandline/image_build/)
  - [Build context](https://docs.docker.com/build/building/context/)
  - [Multi-stage builds](https://docs.docker.com/build/building/multi-stage/)