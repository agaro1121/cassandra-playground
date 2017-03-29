CREATE KEYSPACE hierro
  WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 3 };


CREATE TABLE hierro.users (
	email TEXT PRIMARY KEY,
	portfolios SET<UUID>,
	tickers SET<TEXT>
);

/*********************** SELECT ***********************/ 
select * from users;
/*********************** SELECT ***********************/

UPDATE users
SET portfolios = portfolios + {756716f7-2e54-4715-9f00-91dcbea6cf50}, 
tickers = tickers + {'AMZN'}
WHERE email = 'foo@bar.com'; 

UPDATE users
SET portfolios = portfolios + {756716f7-2e54-4715-9f00-91dcbea6cf50},
tickers = tickers + {'GOOG'}
WHERE email = 'foo@bar.com';


/************************ LISTS *************************/
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

/************************** MAPS **************************/
ALTER TABLE users
ADD ticker_updates map<text, timestamp>;

UPDATE users
SET ticker_updates = { 'AMZN':'2013-06-13 11:42:12' }
WHERE email = 'foo@bar.com';

UPDATE users
SET ticker_updates['GOOG'] = '2013-06-13 12:51:31'
WHERE email = 'foo@bar.com';

/* Delete */
DELETE ticker_updates['AMZN'] 
FROM users
WHERE email = 'foo@bar.com';