{%- from 'spark/settings.sls' import spark with context %}
{%- set user = spark.get('user', {}) %}
{%- set spark_clients = salt['mine.get']('roles:spark_client', 'network.interfaces', 'grain').keys() %}
{%- set all_roles = salt['grains.get']('roles', []) %}

{{ user.username }}:
  group.present:
    - gid: {{ user.uid }}
  user.present:
    - uid: {{ user.uid }}
    - gid: {{ user.uid }}
    - home: /home/{{ user.username }}
    - require:
      - group: {{ user.username }}

/etc/default/spark:
  file.managed:
    - source: salt://spark/files/env.jinja
    - mode: 644
    - template: jinja
    - user: root
    - group: root
    - context:
      java_home: {{ spark.java_home }}

unpack-spark-dist:
  cmd.run:
    - name: wget -4O- '{{ spark.source_url }}' | tar xz
    - cwd: /usr/lib
    - unless: test -d {{ spark['real_home'] }}/lib

spark-home-link:
  alternatives.install:
    - link: {{ spark['alt_home'] }}
    - path: {{ spark['real_home'] }}
    - priority: 30
    - require:
      - cmd: unpack-spark-dist

chown-spark-home:
  cmd.run:
    - name: chown -R root.root {{ spark['real_home'] }}

{% if 'spark_master' in all_roles %}
start-spark-master:
  cmd.run:
    - name: env JAVA_HOME={{ spark.java_home}} {{ spark.spark_master_cmd }}
    - user: {{ user.username }}
{% endif %}
{% if 'spark_client' in all_roles %}
start-spark-client:
  cmd.run:
    - name: env JAVA_HOME={{ spark.java_home }} {{ spark.spark_client_cmd }}
    - user: {{ user.username }}
{% endif %}

