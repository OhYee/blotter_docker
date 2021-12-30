#!/bin/bash

export backendImageTag="1.5.5"
export frontendImageTag="1.5.1"
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

func_help() {
    echo "Blotter Docker 环境"
    echo ""
    # echo "1. 安装 docker、docker-compose 环境"
    # echo "2. 需要运行 bash script.bash init 初始化前后端代码"
    # echo "3. bash script.bash build 构建前后端镜像（构建后可以删除前后端源码（但是没必要）"
    # echo "4. bash script.bash start 启动 blotter 前后端程序"
    # echo "5. bash script.bash stop 停止前后端程序"
    echo "bash script.bash pull     拉取镜像"
    echo "bash script.bash start    启动服务镜像"
    echo ""
    echo "mongodb 数据存储在 data 目录中、nginx 配置文件存储在 conf.d 文件夹中，可根据需要自定义 HTTPS"
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
    *)          func_help           $@;;
esac
