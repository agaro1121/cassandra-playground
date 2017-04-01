# CQL

## Data Types

| Type | Description                |
| -------- | -----------------------|
|   ascii | ASCII character string. |    
|   bigint | 64-bit signed long. |    
|   blob | Arbitrary bytes (no validation). |    
|   boolean | True or false. |    
|   counter | Counter column (64-bit signed value). |    
|   decimal | Variable-precision decimal. |    
|   double | 64-bit IEEE 754 floating point. |    
|   float | 32-bit IEEE 754 floating point. |    
|   inet | An IP address. It can be either 4 bytes long (IPv4) or 16 bytes long (IPv6). There is no inet constant; IP addresses should be inputted as strings. |    
|   int | 32-bit signed int. |    
|   text | UTF-8 encoded string. |    
|   timestamp | A timestamp. Timestamps can be entered as either a string date or an integer as the number of milliseconds since the UNIX epoch (January 1, 1970, UTC). |    
|   timeuuid | Type 1 UUID. This is generally used as a “conflict-free” timestamp. |    
|   uuid | Type 1 or type 4 UUID. |    
|   varchar | UTF-8 encoded string. |    
|   varint | Arbitrary-precision integer. |   

## Data Formats:

- Date
Date Formats:
    * 1371081600000
    * 2013-06-13 00:00 0000
    * 2013-06-13 00:00:00 0000 n 2013-06-13T00:00 0000
    * 2013-06-13T00:00:00 0000 n 2013-06-13 00:00
    * 2013-06-13 00:00:00
    * 2013-06-13T00:00
    * 2013-06-13T00:00:00
    * 2013-06-13
    * 2013-06-13 0000

- Counters - you cannot create a table with columns that have a type of counter mixed with any other type.Tables created for counters are physically separate from other types of tables.
- TimeUUID
- now() - return a new TimeUUID with the time of the cur- rent timestamp
- minTimeuuid() and maxTimeuuid() - should be used only when querying data and never for inserting data
- dateOf() and unixTimestampOf() - Representative of the number of milliseconds since the UNIX epoch.

## Commands
- `CREATE/ALTER KEYSPACE`
- `USE`
- `DROP KEYSPACE`
- `CREATE TABLE/COLUMNFAMILY` - CREATE COLUMNFAMILY is an alias for CREATE TABLE.
- `PRIMARY KEY` 
    * First part of the key will be used as the underlying row key.This is called the partition key.
The remaining parts of the compound key will be used as the physical parts of the composite columns in the underlying data structure.
These are called the clustering keys.The clustering keys will determine the order in which the columns are stored on disk.
You can optionally specify a clustering order that will order the columns on disk and directly affect the ORDER BY clause. 

| Option | Default | Description |
| ------ | --------- | ------------|
| comment | none | A free-form, human-readable com- ment. |  
| read_repair_chance | 0.1 | The probability with which to query extra nodes for the purpose of read repairs. |  
| dclocal_read_repair_chance | 0 | The probability with which to query extra nodes belonging to the same data center as the read coordinator for the purpose of read repairs. |  
| gc_grace_seconds | 864000 | Time to wait before garbage-collect- ing tombstones (deletion markers). |  
| bloom_filter_fp_chance | 0.00075 | The target probability of false posi- tives of the SSTable bloom filters. Said bloom filters will be sized to provide the probability. | 
| compaction |  | The compaction options to use. | 
| compression |  | The compression options to use. | 
| replicate_on_write | true | Whether to replicate data on write. This can only be set to false for tables with counters values. | 
| caching | keys_only | Whether to cache keys (“key cache”) and/or rows (“row cache”) for this table. Valid values are all, keys_ only, rows_only, and none. | 

- `DROP TABLE`
- `TRUNCATE`
- `CREATE INDEX` - If there is existing data in the table during command execution, immediate indexing of current data will occur; after that, the indexes will automatically be updated when data is modified.
- `DROP INDEX` - Only drops those created by `CREATE INDEX`
- `INSERT` - The major differ- ence between CQL insert and SQL insert is that CQL insert requires that the `PRIMARY KEY` be specified during statement execution.
- `UPDATE` - if the row does not exist, CQL will just create it.
- `DELETE` - removes columns and rows.
- `BATCH` - All statements that have the same partition key will be applied atomically.
- `SELECT`
- `WHERE` - the columns specified in the WHERE clause must be either part of the PRIMARY KEY or on a column that has a secondary index specified. that is to say, if the compound key has four parts, you can use parts 1, 2, and 3
- `ORDER BY` - umn name and either ASC or DESC for ascending order or descending order, respectively. If the table was created with a clustering order, the available ordering options are those specified by that order or reversed. Otherwise, it is limited to the order of the clustering key.
- `LIMIT`
- `ALLOW FILTERING` - With ALLOW FILTERING you can tell the server that it can manually reduce the results by the WHERE clause as long as at least one component of the WHERE clause is specified in a secondary index.
