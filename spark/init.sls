{%- from 'spark/settings.sls' import spark with context %}

{%- set spark_clients = salt['mine.get']('roles:spark_client', 'network.interfaces', 'grain').keys() %}
{%- set all_roles = salt['grains.get']('roles', []) %}

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

{{ spark.real_home }}/conf/spark-env.sh:
  file.managed:
    - source: salt://spark/files/spark-env.sh.jinja
    - mode: 755
    - template: jinja
    - user: root
    - group: root
    - context:
      java_home: {{ spark.java_home }}
      spark_master: "{%- if 'spark_master' in all_roles %}{{ salt['grains.get']('id') }}{%- endif %}"
      spark_master_port: "{%- if 'spark_master' in all_roles %}{{ spark.spark_master_port }}{%- endif %}"
      daemon_opts: {{ spark.daemon_opts }}
    - require:
      - cmd: unpack-spark-dist

chown-spark-home:
  cmd.run:
    - name: chown -R root.root {{ spark['real_home'] }}

{% if 'spark_master' in all_roles %}
start-spark-master:
  cmd.run:
    - name: "{{ spark.spark_master_cmd }}"
    - require:
      - file: {{ spark.real_home }}/conf/spark-env.sh
{% endif %}
{% if 'spark_client' in all_roles %}
start-spark-client:
  cmd.run:
    - name: "{{ spark.spark_client_cmd }}"
    - require:
      - file: {{ spark.real_home }}/conf/spark-env.sh
{% endif %}

