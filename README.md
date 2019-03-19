# Clickhouse cluster on Docker

You need to create a `ch*_volume` directory in the root git repo when you clone it.
These folders will be volumes for the clickhouse instances.
Since there are four nodes, we will need four volumes (folders) in the root repo.
```
    # Make data dirs
    mkdir -p ch1_volume
    mkdir -p ch2_volume
    mkdir -p ch3_volume
    mkdir -p ch4_volume

    # Make log dirs
    mkdir -p ch1_logs
    mkdir -p ch2_logs
    mkdir -p ch3_logs
    mkdir -p ch4_logs
```

You will also have to change the paths of the volumes to absolute paths in your own
machine in docker-compose.yml
```
volumes:
      - "path/to/ch1_volume:/var/lib/clickhouse"
      - "path/to/ch1_logs:/var/log/clickhouse-server"
      - "path/to/ch1_volume/tmp:/var/lib/clickhouse/tmp/"
```

To start the docker cluster:
```
    docker-compose up
```

Connect to the host `ch1`
```
    clickhouse-client --host=127.0.0.1 --port=9011
```

Then you can create a database with the following SQL command:
```
    create database test_db
``` 

Sample create table
```
    CREATE TABLE IF NOT EXISTS test_db.events_shard ON CLUSTER test_cluster (
      event_date           Date DEFAULT toDate(now()),
      company_id           UInt32,
      product_id           UInt32
    ) ENGINE=ReplicatedMergeTree(
        '/clickhouse/tables/{shard}/events_shard', '{replica}',
        event_date,
        (company_id),
        8192
    );
```

Sample distributed table
```
    CREATE TABLE IF NOT EXISTS test_db.events_dist
    ON CLUSTER test_cluster AS test_db.events_shard
    ENGINE = Distributed(test_cluster, test_db, events_shard, rand());
``` 

Insert into the database.
```
    INSERT INTO test_db.events_dist (company_id, product_id) VALUES (1, 11), (1, 12), (1, 13);
```

Select from the database.
```
    SELECT * FROM test_db.events_dist;
```