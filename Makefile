configure:
	01-generate_certificates.sh
	02-generate_passwords.sh
	03-generate_internal_users.sh
	04-generate_roles.sh
	05-generate_roles_mapping.sh
	06-configure_dashboards.sh
	07-configure_logstash.sh

docker:
	docker-compose -f docker-compose-simple.yml up -d

post-config: docker
	08-configure_container_node.sh
	09-configure_container_dashboards.sh

clean:
	git checkout -- configs/
	git checkout -- pipeline/99-outputs.conf
	rm -f configs/auth_setup.out
	rm -f certs/*