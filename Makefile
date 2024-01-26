VOLUME_NAME="db"

all: build run

build: build_todo build_subdir build_singlestage build_multistage dev build_build_output

run: run_getting_started run_todo run_subdir run_todo_with_volume dev



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

build_dev:
	@docker build --tag dev --file "dev/Dockerfile" "./dev"

run_dev:
	@docker run --tty --interactive --entrypoint "/bin/bash" dev

build_subdir:
	@docker build --tag subdir --file some_subdir/Dockerfile "./some_subdir"

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

build_build_output:
	@docker build --tag build_output \
		--file "./build_output/Dockerfile" \
		--output type=local,dest="./build_output/out" \
		"./build_output"



# Cleaning up
clean: clean_containers clean_volumes
	@rm -rf ./build_output/env

kill_all:
	@docker ps -q | xargs --no-run-if-empty docker kill

clean_containers:
	@docker ps -aq | xargs --no-run-if-empty docker rm --force

clean_volumes:
	@docker volume prune --force

clean_images:
	@docker image ls | grep "<none>" | awk -F ' ' '{print $$3}' \
		| xargs --no-run-if-empty docker image rm && \
	docker image ls | grep -P "(todo-app|dev|subdir|node|docker\/getting-started|singlestage|multistage)" \
		| awk -F ' ' '{print $$3}' | xargs --no-run-if-empty docker image rm