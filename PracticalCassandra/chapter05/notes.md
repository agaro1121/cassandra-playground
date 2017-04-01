# Deployment and Provisioning

## Keyspace Creation
- Decide on a few things: your data center layout and your replication strategy
- How many copies of your data do you want, and where do you want to keep them? Much of this depends on your application and your usage patterns

### Replication Factor (RF)
- No primary/master concept

#### Replication Strategies
##### SimpleStrategy
- Good for individual machine or with single-data-center clusters
##### NetworkTopologyStrategy
- The strategy describes the number of replicas that should be in each data center.
    * This number is set at keyspace creation time.
-         
###### Replica Counts
- Do your reads leave your data center? Latency
- Failover Scenarios
    * Two replicas per data center  - if(numOfNodesInDataCenter >= 4) set RF=2
    * Three replicas per data center - if(numOfNodesInDataCenter >= 6) set RF=2
- Asymmetrical replication - number of replicas in one data center does not match the number of replicas in the other data centers
    * For instance, if you do the majority of your reads in datacenter1 and the majority of your writes in datacenter2, having more nodes in datacenter1 to reduce read latency may be a good strategy
    
### Snitches
- A protocol that helps map IPs -> racks & data centers
- Not needed for writes
- Has an effect only on the way Cassandra talks to itself
- **All nodes in a cluster must use the same snitch**
- You must make the change in the configuration file and then restart the entire cluster

#### Simple[Snitch]
- Single machine or even a single-data-center deployment
- When setting, you need to put the `replication_factor=#` in your keyspace `strategy_options`
#### Dynamic
- The DynamicSnitch uses latency possibility calculations to determine the best approach
    * **WARNING: These calculations can take longer than the query itself !!!**
- Options:
    * Use recent update statistics
    * Calculate a score for each host and run the query based on the best score
        * **Shit happens during this calculation i.e nodes going down**
##### RackInferringSnitch
- works by assuming it knows the topology of your network, by the octets in a node’s IP address
- Example: Cassandra node at 10.20.30.1
    * 10 The first octet has no special meaning.
    * 20 The second octet is the data center octet. If there was another node at 10.30.40.1, Cassandra would assume that this node was in a different physical data center.
    * 30 The third octet is the rack octet. Cassandra assumes that all nodes in this octet are in the same rack.
    * 40 The final octet is the node octet.
- **When defining your keyspace `strategy_options`, be sure to include the second octet as the data center name for clarity.**    

##### Ec2Snitch
- region = data center
- availability zones = racks in those data centers
- Single-region deployment
    * you don’t have to worry about public IPs for the Cassandra nodes
Example: 

```sql
CREATE KEYSPACE VideoStore
WITH replication = {'class': 'NetworkTopologyStrategy', 'us-east' : 3} 
AND durable_writes = true;
```

##### Ec2MultiRegion
- Requires the use of public IPs to be able to talk across regions
Example: 

```sql
CREATE KEYSPACE VideoStore
WITH replication = {'class': 'NetworkTopologyStrategy', 'us-east' : 3, 'us-west': 3 }
AND durable_writes = true;
```

##### Property File
- layout is user-defined
- file name: `cassandra-topology.properties.`
    * must be in sync on every machine in the cluster
    * every node in the cluster must be in this file
    * datacenter names must match in properties and keyspace def'n 
- typical use case: non-uniform IPs    

Example:

```sql
CREATE KEYSPACE VideoStore
WITH replication = {'class': 'NetworkTopologyStrategy', 'DC1' : 2, 'DC2' : 2}
AND durable_writes = true;
```

### Partitioners
- At its core, the partitioner is just a hashing function for computing the token (aka the hash) of a row key
- **Once chosen, can never change it**
#### Byte Order (NOT RECOMMENDED)
#### Random Partitioners
- a partitioner that distributes data in a random but **consistent** fashion around the cluster
##### RandomPartitioner (DON'T BOTHER)
##### Murmer3Partitioner (Default)
- provides a faster hashing function than RandomPartitioner called the MurmurHash
- This function creates a 64-bit hash value of the row key. Its values range from -263 to ( 263-1)

### Firewalls
- Ports:
    * 7000 - non-ssl
    * 7001 - ssl
    * 7199 - initial JMX handshake
    * 9160 - usual client interaction
    * 22 - ssh
