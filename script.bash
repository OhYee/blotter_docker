#!/bin/bash

export SHELL_FOLDER=$(cd "$(dirname "$(realpath "$0")")";pwd)
export backendImageTag="1.8.1"
export frontendImageTag="1.8.0"
export backendImage="ohyee/blotter:$backendImageTag"
export frontendImage="ohyee/blotter_page:$frontendImageTag"

func_check_docker() {
    DOCKER_PATH=$(which docker)
    if [[ $? -eq 0 ]]; then
        echo "Docker in ${DOCKER_PATH}"
    else
        echo "Can not find docker, please install it first"
        exit
    fi

    DOCKER_COMPOSE_PATH=$(which docker-compose)
    if [[ $? -eq 0 ]]; then
        echo "Docker compose in ${DOCKER_COMPOSE_PATH}"
    else
        echo "Can not find docker-compose, please install it first"
        exit
    fi
}

func_build_backend() {
    echo "Building blotter backend"

    cd blotter && bash ./build.bash && cd ..
}

func_build_frontend() {
    echo "Building blotter frontend"

    cd blotter_page && bash ./build.bash && cd ..
}

func_pull() {
    echo "Pulling blotter"
    docker pull ${backendImage}
    docker pull ${frontendImage}
}

func_push() {
    echo "Pushing blotter"

    backendLatest="$(echo $backendImage | cut -d ":" -f 1):latest"
    docker tag ${backendImage} ${backendLatest}
    docker push ${backendImage}
    docker push ${backendLatest}

    frontendLatest="$(echo $frontendImage | cut -d ":" -f 1):latest"
    docker tag ${frontendImage} ${frontendLatest}
    docker push ${frontendImage}
    docker push ${frontendLatest}
}


func_start() {
    echo "Starting blotter"

    docker-compose up -d
}

func_stop() {
    echo "Stopping blotter"

    docker-compose down
}

func_run_develop() {
    echo "start Nginx and MongoDB"
    export dockerHost=$(cat /etc/hosts | grep host.docker.internal | tr '\t' ' ' | tr -s " " | cut -f 1 -d " ")
    export localHost=$(ip addr show eth0 | grep 'inet ' | cut -f 6 -d ' ' | cut -f 1 -d '/')

    docker run \
        -d \
        --rm \
        --name "nginx" \
        -p 50001:50001 \
        --add-host=backend:${localHost} \
        --add-host=frontend:${localHost} \
        -v ${SHELL_FOLDER}/nginx/conf.d:/etc/nginx/conf.d \
        -v ${SHELL_FOLDER}/nginx/ssl:/etc/nginx/ssl \
        -v /etc/localtime:/etc/localtime \
        nginx:1.19.9 

    docker run \
        -d \
        --rm \
        --name "mongo" \
        -p 27017:27017 \
        -v ${SHELL_FOLDER}/data:/data/db \
        -v /etc/localtime:/etc/localtime \
        mongo:4.4.5

    echo "go run main.go -address 0.0.0.0:50000"
    echo "yarn dev"
}

func_stop_develop() {
    docker stop nginx
    docker stop mongo
}

func_help() {
    echo "Blotter Docker ??????"
    echo ""
    # echo "1. ?????? docker???docker-compose ??????"
    # echo "2. ???????????? bash script.bash init ????????????????????????"
    # echo "3. bash script.bash build ?????????????????????????????????????????????????????????????????????????????????"
    # echo "4. bash script.bash start ?????? blotter ???????????????"
    # echo "5. bash script.bash stop ?????????????????????"
    echo "bash script.bash pull     ????????????"
    echo "bash script.bash start    ??????????????????"
    echo ""
    echo "mongodb ??????????????? data ????????????nginx ????????????????????? conf.d ??????????????????????????????????????? HTTPS"
}

func_init() {
    git clone https://github.com/OhYee/blotter.git --depth=1
    git clone https://github.com/OhYee/blotter_page.git --depth=1
}

func_update() {
    cd blotter && git pull && cd ..
    cd blotter_page && git pull && cd ..
}

case $1 in
    "check")    func_check_docker   $@;;
    "update")   func_update         $@;;
    "pull")   func_pull         $@;;
    "push")   func_push         $@;;
    "backend")  func_check_docker && func_build_backend  $@;;
    "frontend") func_check_docker && func_build_frontend $@;;
    "build")    func_check_docker && func_build_backend && func_build_frontend $@;;
    "start")    func_start          $@;;
    "stop")     func_stop           $@;;
    "init")     func_init           $@;;
    "dev")      func_run_develop    $@;;
    "stop_dev") func_stop_develop   $@;;
    *)          func_help           $@;;
esac
