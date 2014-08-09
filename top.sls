base:
  'hadoop-*':
    - hostsfile
    - sun-java
    - hadoop
    - hadoop.hdfs
    - hadoop.mapred
    - spark
  '*zookeeper*':
    - hostsfile
    - sun-java
    - zookeeper
    - zookeeper.server
