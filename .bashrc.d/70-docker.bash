
docker() {

	# Don't cover the real docker binary.
	unset docker

	has docker || return 0

	# Warn if docker containers are running.
	docker_is_running() {
		curl --connect-timeout 0.0001 -s --unix-socket /var/run/docker.sock http/_ping > /dev/null 2>&1
	}
	
	# Returns the number of running docker containers.
	# If docker's not running or there are zero containers,
	# the command fails with nonzero exit code.
	docker_running_containers_count() {
		local COUNT=0
		docker_is_running && COUNT="$(docker ps -q | wc -l | xargs)" || return 1
		echo "$COUNT"
	}
	
	print_docker_status() {
		local COUNT
		COUNT="$(docker_running_containers_count)" || return 0
		[[ "$COUNT" -ne 0 ]] || return 0
		echo "NOTE: You have $COUNT docker containers running. Run 'docker ps;' to see what they are."
	}
	
	print_docker_status
}
