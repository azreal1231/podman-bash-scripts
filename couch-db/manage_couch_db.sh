
#!/bin/bash

# This script will manage the CouchDB container

CONTAINER_NAME="my-couchdb"
COUCHDB_USER="admin"
COUCHDB_PASSWORD="mysecretpassword"
HOST_PORT=5986
CONTAINER_PORT=5984
COUCHDB_IMAGE="docker.io/library/couchdb"
HELP_FILE="help_commands.txt"

function check_image() {
    sudo podman images | grep -q $COUCHDB_IMAGE
    return $?
}

function pull_image() {
    echo "Pulling the CouchDB image..."
    sudo podman pull $COUCHDB_IMAGE
}

function confirm() {
    read -r -p "Are you sure you want to delete the container $CONTAINER_NAME? [y/N] " response
    case "$response" in
        [yY][eE][sS]|[yY]) 
            true
            ;;
        *)
            false
            ;;
    esac
}

function show_help() {
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
    
    HELP_FILE_PATH="$SCRIPT_DIR/$HELP_FILE"
    if [ -f "$HELP_FILE_PATH" ]; then
        cat "$HELP_FILE_PATH"
    else
        echo "Help file not found."
    fi
}

case "$1" in
  create)
    if ! check_image ; then
        read -r -p "CouchDB image not found. Do you want to pull it? [y/N] " pull_response
        case "$pull_response" in
            [yY][eE][sS]|[yY])
                pull_image
                ;;
            *)
                echo "CouchDB image is required to create the container."
                exit 1
                ;;
        esac
    fi
    # Create and start the CouchDB container
    podman run -d --name $CONTAINER_NAME -p $HOST_PORT:$CONTAINER_PORT -e COUCHDB_USER=$COUCHDB_USER -e COUCHDB_PASSWORD=$COUCHDB_PASSWORD $COUCHDB_IMAGE
    ;;
  start)
    # Start the CouchDB container
    podman start $CONTAINER_NAME
    ;;
  stop)
    # Stop the CouchDB container
    podman stop $CONTAINER_NAME
    ;;
  restart)
    # Restart the CouchDB container
    podman restart $CONTAINER_NAME
    ;;
  delete)
    # Stop and delete the CouchDB container after confirmation
    if confirm ; then
      podman stop $CONTAINER_NAME
      podman rm $CONTAINER_NAME
      echo "Container $CONTAINER_NAME has been deleted."
    else
      echo "Delete action cancelled."
    fi
    ;;
  help)
    # Show help information
    show_help
    ;;
  *)
    show_help
    exit 1
esac

exit 0