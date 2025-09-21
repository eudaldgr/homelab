# shellcheck disable=SC2148

XDG_RUNTIME_DIR="/run/user/$(id -u)"

export XDG_RUNTIME_DIR
export PODMAN_COMPOSE_WARNING_LOGS=false
export DOCKER_HOST="unix://${XDG_RUNTIME_DIR}/podman/podman.sock"