{% set p = salt['pillar.get']('spark', {}) %}
{% set pc = p.get('config', {}) %}
{% set g = salt['grains.get']('spark', {}) %}
{% set gc = g.get('config', {}) %}

{% set default_dist_id = 'spark-1.0.2-bin-hadoop2' %}
{% set dist_id = g.get('version', p.get('version', default_dist_id)) %}
{% set versions = { 'spark-1.0.2-bin-hadoop2' : { 'version'       : '1.0.2',
                                                  'version_name'  : 'spark-1.0.2-bin-hadoop2',
                                                  'source_url'    : g.get(
                                                    'source_url',
                                                    p.get('source_url', 'http://www.apache.org/dist/spark/spark-1.0.2/spark-1.0.2-bin-hadoop2.tgz')
                                                  ),
                                                  'major_version' : '1',
                                                },
                    'spark-1.0.2-bin-hadoop1' : { 'version'       : '1.0.2',
                                                  'version_name'  : 'spark-1.0.2-bin-hadoop1',
                                                  'source_url'    : g.get(
                                                    'source_url',
                                                    p.get('source_url', 'http://www.apache.org/dist/spark/spark-1.0.2/spark-1.0.2-bin-hadoop1.tgz')
                                                  ),
                                                  'major_version' : '1',
                                                },
                    'spark-1.0.2-bin-cdh4'    : { 'version'       : '1.0.2',
                                                  'version_name'  : 'spark-1.0.2-bin-cdh4',
                                                  'source_url'    : g.get(
                                                    'source_url',
                                                    p.get('source_url', 'http://www.apache.org/dist/spark/spark-1.0.2/spark-1.0.2-bin-cdh4.tgz')
                                                  ),
                                                  'major_version' : '1',
                                                },
  }%}

{%- set version_info     = versions.get(dist_id, versions[default_dist_id]) %}

{% set daemon_opts = "" %}

{% if p.get('recovery') and p.recovery.get('mode', '') == 'zookeeper': %}
  {% from 'zookeeper/settings.sls' import zk with context %}
  {% set zookeepers = salt['mine.get']('roles:zookeeper', 'network.interfaces', 'grain').keys() %}
  {% set zks = [] %}
  {% for zookeeper in zookeepers: %}
    {% do zks.append(zookeeper + ":" + zk.port) %}
  {% endfor %}
  {% set zks = zks|join(",") %}
  {% set zookeeper_dir = p.recovery.get('zookeeper_dir', '/spark') %}
  {% set daemon_opts = "-Dspark.deploy.recoveryMode=ZOOKEEPER -Dspark.deploy.zookeeper.url=" + zks + " -Dspark.deploy.zookeeper.dir=" + zookeeper_dir %}
{% endif %}

{% set master_port = p.get('master_port', '7077') %}

{%- set alt_home         = p.get('prefix', '/usr/lib/spark') %}
{%- set real_home        = '/usr/lib/' + version_info['version_name'] %}

{%- set spark_master_stop  = alt_home + '/sbin/stop-master.sh' %}
{%- set spark_master_start = alt_home + '/sbin/start-master.sh' %}
{%- set spark_master_cmd   = spark_master_stop + " && sleep 1 && " + spark_master_start %}

{% set spark_master_port = pc.get('master_port', 7077) %}
{% set masters = salt['mine.get']('roles:spark_master', 'network.interfaces', 'grain').keys() %}
{% set masters_with_ports = [] %}
{% for master in masters: %}
  {% do masters_with_ports.append(master + ":" + (spark_master_port|string)) %}
{% endfor %}
{% set masters_with_ports = masters_with_ports|join(",") %}

{%- set spark_client_stop  = alt_home + '/sbin/spark-daemon.sh stop org.apache.spark.deploy.worker.Worker 0' %}
{%- set spark_client_start = alt_home + '/sbin/spark-daemon.sh start org.apache.spark.deploy.worker.Worker 0 spark://' + masters_with_ports %}
{%- set spark_client_cmd   = spark_client_stop + " && sleep 1 && " + spark_client_start %}

{%- set java_home = salt['pillar.get']('java_home', p.get('java_home', '/usr/lib/java')) %}

{%- set spark = {} %}
{%- do spark.update( {   'dist_id'           : dist_id,
                         'cdhmr1'            : version_info.get('cdhmr1', False),
                         'version'           : version_info['version'],
                         'version_name'      : version_info['version_name'],
                         'source_url'        : version_info['source_url'],
                         'major_version'     : version_info['major_version'],
                         'alt_home'          : alt_home,
                         'real_home'         : real_home,
                         'spark_master_port' : spark_master_port,
                         'spark_master_cmd'  : spark_master_cmd,
                         'daemon_opts'       : daemon_opts,
                         'spark_client_cmd'  : spark_client_cmd,
                         'java_home'         : java_home,
                         }) %}

