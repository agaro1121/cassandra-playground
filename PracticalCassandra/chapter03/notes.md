# Data Modeling

- New columns can be added at any time
- Not every row (that you see on the screen) will have every field populated

## PRIMARY KEY
- tells how to store and distribute data
- first field is partition key
- subsequent fields are clustering keys(how data is stored on disk)

“Wide rows” refers to the rows that Cassandra is storing on disk, rather than the rows that are represented to you when you make a query.

### Example 1: Illustration of How Data May Be Stored Using a COMPOUND KEY

```sql
CREATE TABLE animals ( 
	name TEXT,
	species TEXT, 
	subspecies TEXT, 
	genus TEXT,
	family TEXT,
	PRIMARY KEY(family, genus) 
);
Data for each family will be stored on the same replica sets and presorted, or clustered, by the genus.This will allow for very fast lookups when the family and genus for an animal are known.```

Hot spots occur when a particular key (row) gets so many queries that it causes the load on the machine to spike. High load on a given machine can cause cluster-wide complications as the communication channels start to back up. Consideration also needs to be given to the row size. A single row has to fit on disk; if you have a single row containing billions of columns, it may extend past the amount of available disk space on the drive.

Modeling for Cassandra should follow the idea that disk space is cheap, so duplicating data (even multiple times) should not be an issue. In fact, “normalization” of data is an anti-pattern in Cassandra.

###Example 2: Example of Cassandra Data Model for Log Storage (Optimized)

```sql
CREATE TABLE events ( 
	hour TIMESTAMP,
	id TIMEUUID,
	time TIMESTAMP,
	event_type TEXT,
	data text,
	PRIMARY KEY((hour, event_type), time)
) WITH CLUSTERING ORDER BY (time DESC);
```
Separates stored events by the hour and then further by event_type for optimizaton. This will move event_type groups to different areas of disk to avoid hotspots.

###Example 3: Example of Using an Atomic Counter BATCH to Insert and Update
```sql
INSERT INTO events (hour, id, time, event_type, data)
	VALUES ('2013-06-13 11:00:00', NOW(), '2013-06-13 11:43:23',
		'click', '{"url":"http://example.com"}')
BEGIN COUNTER BATCH
 UPDATE event_metrics SET count = count + 1
  WHERE hour = '2013-06-13 11:00:00'
   AND event_type = 'click'
UPDATE url_metrics SET count = count + 1
 WHERE hour = '2013-06-13 11:00:00'
  AND url = 'http://example.com'
APPLY BATCH;
```

## Collections

- Cassandra also includes collections as part of its data model. Collections are a complex type that can provide flexibility in querying.

- Sets - unique set of items without the need for read-before-write
- Lists - maintains order
- Maps - <key, value> pair. Helps avoid saving whole json document into field.

# Model your queries, not your data !