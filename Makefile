.PHONY: all docker deploy

all: docker deploy

docker:
	docker build -t trueability/chef-server:latest .
	docker build \
		--build-arg WITH_MANAGE=1 \
		-t trueability/chef-server:latest-manage .

deploy:
	docker push -t trueability/chef-server:latest
	docker push -t trueability/chef-server:latest-manage

