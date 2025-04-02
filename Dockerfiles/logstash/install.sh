PERFSONAR_VERSION="${PERFSONAR_VERSION:-5.2.0}"

LOGSTASH_DIR=/usr/lib/perfsonar/logstash

git clone --branch $PERFSONAR_VERSION https://github.com/perfsonar/logstash.git logstash-git

LOGSTASH_MAKE_DIR=logstash-git/perfsonar-logstash/perfsonar-logstash
make -C $LOGSTASH_MAKE_DIR ROOTPATH=$LOGSTASH_DIR CONFIGPATH=$LOGSTASH_DIR SYSTEMDPATH=/etc/systemd/system install

mkdir -p /etc/logstash
echo [] > /etc/logstash/pipelines.yml

python3 $LOGSTASH_DIR/scripts/update_logstash_pipeline_yml.py
python3 $LOGSTASH_DIR/scripts/enable_prometheus_pipeline.py