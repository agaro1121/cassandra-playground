CREATE KEYSPACE hierro
  WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 3 };


CREATE TABLE hierro.users (
	email TEXT PRIMARY KEY,
	portfolios SET<UUID>,
	tickers SET<TEXT>
);

select * from users;

UPDATE users
SET portfolios = portfolios + {756716f7-2e54-4715-9f00-91dcbea6cf50}, 
tickers = tickers + {'AMZN'}
WHERE email = 'foo@bar.com'; 

UPDATE users
SET portfolios = portfolios + {756716f7-2e54-4715-9f00-91dcbea6cf50},
tickers = tickers + {'GOOG'}
WHERE email = 'foo@bar.com';

//Add list type column
ALTER TABLE users ADD top_tickers list<text>;

UPDATE users
SET top_tickers = ['GOOG'] 
WHERE email = 'foo@bar.com';

//Add item to list
UPDATE users
SET top_tickers = top_tickers + ['AMZN']
WHERE email = 'foo@bar.com';

//Replace AMZN ticker in list
UPDATE users
SET top_tickers[1] = 'FB'
WHERE email = 'foo@bar.com';

//Remove item from List
UPDATE users
SET top_tickers = top_tickers - ['FB']
WHERE email = 'foo@bar.com';