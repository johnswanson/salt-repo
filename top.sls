base:
  'hadoop-*':
    - hostsfile
    - sun-java
    - sun-java.env
    - hadoop
    - hadoop.hdfs
    - spark
    - lein
  '*zookeeper*':
    - hostsfile
    - sun-java
    - sun-java.env
    - zookeeper
    - zookeeper.server
