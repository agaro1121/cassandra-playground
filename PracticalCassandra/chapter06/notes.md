# Performance Tuning

- level: lowest -> highest
    * hardware && OS
    * kernel
    * JVM

## Methodology
- Get baseline **FIRST** w/simple *unix tools: `vmstat, iostat, dstat` and monitor tools: `htop, atop, and top`
- Instrumental Graphs: **[Cacti](http://www.cacti.net/), [Munin](http://munin-monitoring.org/), and [Ganglia](http://ganglia.sourceforge.net/)**
- You should have a control machine as well as an experimental machine
- Run a query or a script run on both the control machine and the experimental machine and compare their response times

### Testing in Production
- As long as you have over 6 nodes with RF=2 then you should not experience performance issues

## Tuning
- Settings apply to all differ- ent stages of the architecture

### Timeouts
- how long coordinator node waits for workers
    * too high - latency while waiting for workers
    * too low - possibility of inconsistent data
- By default, there is no timeout in Cassandra for streaming operations
- Allows nodes to communicate timeout information to each other
    * initially off is because the timing can properly be synchronized only if system clocks on all nodes are in sync

### CommitLog
- Put it on a separate drive
- `commitlog_sync = periodic`
- For archiving: 8-16mb backups for finer-grained restore points

### MemTables
- Larger MemTables take memory away from caches
- Larger MemTables do not improve write performance
- Larger MemTables are better for unbatched writes
- Larger MemTables lead to more effective compaction

### Concurrency
- Cassandra is designed for faster write performance
- the writes come to memory => bottleneck = reads
- reads = if(number_of_drives == 2) 2 else 16 * number_of_drives
- writes = 8 * number_of_cores

### Durability and Consistency
- when to use which consistency level at what time
- if you can decide at write time or connection time which data is important enough to require higher consistency levels in your writes, you can save quite a bit of round-trip and wait time on your write calls
- If latency is an issue, you should also consider using CL.ONE. 
- If consistency is more important, you can ensure that a read will always reflect the most recent write by using the following: `(nodes_written + nodes_read) > replication_factor`

### Compression
- System Level
- ColumnFamily Level
    * In addition to saving space on disk, compression also reduces actual disk I/O
    * The speed increase on writes happens because the data is compressed when the MemTable is flushed to disk
    * As a negative, it adds a little more CPU overhead to the flush
- Network Level
    * Options: Ignore, all traffic, only between datacenters
    * Default: All traffic - Doesn't really hinder performance
    * CPU Bound

#### SnappyCompressor
- tailored to 64-bit CPU architecture
- within the same range as LZF
- uses the Java port of the original library written in C  
- Good for: read-heavy workload

#### DeflateCompressor
- Java's version of zip
- reads might come a little slower, but your data on disk will be smaller

#### File System
- ZFS but ext4 is just fine
- Some ext4 setting to look into:
    * noatime
    * barriers=0
    * data=journal, commit=15
    * data=writeback, nobh
    * **Note that if you make changes on a disk that is already mounted, you will have to unmount and remount the disk in order for the changes to take effect**

### Caching
- coordinator node and the queried node will cache
#### How it works
- When row and key cache enabled, search goes: row cache -> key cache -> SSTables -> MemTables
- if target column is in cached row, then Cassandra will unpack that row and return the column
