configure:
	bash ./01-generate_certificates.sh
	bash ./02-generate_passwords.sh
	bash ./03-generate_internal_users.sh
	bash ./04-generate_roles.sh
	bash ./05-generate_roles_mapping.sh
	bash ./06-configure_dashboards.sh
	bash ./07-configure_logstash.sh

docker:
	docker compose -f docker-compose-simple.yml up -d

post-config: docker
	bash ./08-configure_container_node.sh
	bash ./09-configure_container_dashboards.sh

clean:
	git checkout -- configs/
	git checkout -- pipeline/99-outputs.conf
	rm -f configs/auth_setup.out
	rm -f certs/*