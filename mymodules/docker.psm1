function Get-ListOfContainer
{
	docker ps -a
}

function Invoke-ComposeUp
{
	docker-compose up -d --remove-orphans
}
function Invoke-ComposeDown
{
	docker-compose down
}

function Invoke-ComposeRemove
{
	docker-compose rm --stop --force
}

function Invoke-ComposeStop
{
	docker-compose stop
}

function Get-ComposePs
{
	docker-compose ps
}

function Get-ContainerIPAddress {
	param (
		[string] $id
	)
	& docker inspect --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $id
}

function Invoke-ContainerStop
{
	param (
		[string] $id
	)
	& docker container stop $id
}

function Invoke-ContainerRemove
{
	param (
		[string] $id
	)
	& docker container rm $id
}
function Invoke-ContainerLog
{
	param (
		[string] $id
	)
	& docker logs --follow $id
}

# Argument: ImageID (docker images)
function Invoke-DockerfileImage
{
	param (
		[string] $id
	)
	& docker run -v /var/run/docker.sock:/var/run/docker.sock --rm laniksj/dfimage $id
}

function Invoke-ContainerConnect
{
	param (
		[string] $id
	)
	& docker exec -it $id /bin/bash
}

function Get-DockerStats
{
	docker stats
}