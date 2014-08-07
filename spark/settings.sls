{% set p = salt['pillar.get']('spark', {}) %}
{% set pc = p.get('config', {}) %}
{% set g = salt['grains.get']('spark', {}) %}
{% set gc = g.get('config', {}) %}
{%- set spark_master = salt['mine.get']('roles:spark_master', 'network.interfaces', 'grain').keys() %}

{% set master_port = pc.get('master_port', '7077') %}
{% set client_port = pc.get('client_port', '') %}

{%- set versions = {} %}
{%- set default_dist_id = 'spark-1.0.2' %}
{%- set dist_id = g.get('version', p.get('version', default_dist_id)) %}

{%- set versions = { 'spark-1.0.2' : { 'version' : '1.0.2',
                                      'version_name' : 'spark-1.0.2-bin-hadoop2',
                                      'source_url' : g.get('source_url', p.get('source_url', 'http://www.apache.org/dist/spark/spark-1.0.2/spark-1.0.2-bin-hadoop2.tgz')),
                                      'major_version' : '1'
                                    },
  }%}

{%- set user = { 'username': 'spark', 'uid': '7001' } %}

{%- set version_info     = versions.get(dist_id, versions['spark-1.0.2']) %}
{%- set alt_home         = salt['pillar.get']('spark:prefix', '/usr/lib/spark') %}
{%- set real_home        = '/usr/lib/' + version_info['version_name'] %}
{%- set alt_config       = gc.get('directory', pc.get('directory', '/etc/spark/conf')) %}
{%- set real_config      = alt_config + '-' + version_info['version'] %}
{%- set real_config_dist = alt_config + '.dist' %}
{%- set default_log_root = '/var/log/spark' %}
{%- set log_root         = gc.get('log_root', pc.get('log_root', default_log_root)) %}

{%- set spark_master_cmd = alt_home + '/sbin/start-master.sh' %}
{%- set spark_client_cmd = alt_home + '/bin/spark-class org.apache.spark.deploy.worker.Worker spark://{{ spark_master }}:{{ master_port }}' %}

{%- set java_home        = salt['pillar.get']('java_home', '/usr/lib/java') %}
{%- set config_core_site = gc.get('core-site', pc.get('core-site', {})) %}

{%- set spark = {} %}
{%- do spark.update( {   'dist_id'          : dist_id,
                         'cdhmr1'           : version_info.get('cdhmr1', False),
                         'version'          : version_info['version'],
                         'version_name'     : version_info['version_name'],
                         'source_url'       : version_info['source_url'],
                         'major_version'    : version_info['major_version'],
                         'alt_home'         : alt_home,
                         'real_home'        : real_home,
                         'alt_config'       : alt_config,
                         'real_config'      : real_config,
                         'real_config_dist' : real_config_dist,
                         'initscript'       : initscript,
                         'spark_master_cmd' : spark_master_cmd,
                         'spark_client_cmd' : spark_client_cmd,
                         'java_home'        : java_home,
                         'log_root'         : log_root,
                         'default_log_root' : default_log_root,
                         'config_core_site' : config_core_site,
                         'user'             : user,
                         }) %}

