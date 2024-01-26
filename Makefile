VOLUME_NAME="db"

all: build run

build: build_todo build_subdir

run: run_getting_started run_todo run_subdir run_todo_with_volume



# Volumes
create_volume:
	@docker volume create ${VOLUME_NAME}

run_todo_with_volume:
	@docker run --detach --publish 3001:3001 --volume db:/etc/todos todo-app

run_todo_with_mount:
	@docker run --detach --publish 3000:3000 \
      --workdir /app \
      --mount type=bind,source="$$(realpath sample-app)",destination="/app" \
      node:12-alpine \
      sh -c "yarn install && yarn run dev"



# Image-specific
run_getting_started:
	@docker run -d -p 80:80 docker/getting-started

build_todo:
	@docker build -t todo-app "./sample-app"

run_todo:
	@docker run -dp 3000:3000 todo-app

build_subdir:
	@docker build --tag subdir --file dev/some_subdir/Dockerfile "./dev/some_subdir"

run_subdir:
	@docker run --name subdir --rm subdir

build_singlestage:
	@docker build --tag singlestage --file "./multistage/Dockerfile" "./multistage"

run_singlestage:
	@docker run --tty --interactive --name singlestage --rm singlestage

build_multistage:
	@docker build --tag multistage --file "./multistage/Dockerfile_multistage" "./multistage"

run_multistage:
	@docker run --tty --interactive --name multistage --rm multistage



# Cleaning up
clean: clean_containers clean_volumes

kill_all:
	@docker kill $$(docker ps -q)

clean_containers:
	@docker rm --force $$(docker ps -aq)

clean_volumes:
	@docker volume prune --force

clean_images:
	@docker image rm $$(docker image ls | grep "<none>" | awk -F ' ' '{print $$3}') && \
	docker image rm $$(docker image ls | grep -P "(todo-app|dev|subdir|node|docker\/getting-started|singlestage|multistage)" | awk -F ' ' '{print $$3}')