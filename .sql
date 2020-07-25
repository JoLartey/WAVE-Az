CREATE TABLE users (
u_id integer PRIMARY KEY,
name text NOT NULL,
mobile text NOT NULL,
wallet_id integer NOT NULL,
when_created timestamp without time zone NOT NULL
-- more stuff :)
);
CREATE TABLE transfers (
transfer_id integer PRIMARY KEY,
u_id integer NOT NULL,
source_wallet_id integer NOT NULL,
dest_wallet_id integer NOT NULL,
send_amount_currency text NOT NULL,
send_amount_scalar numeric NOT NULL,
receive_amount_currency text NOT NULL,
receive_amount_scalar numeric NOT NULL,
kind text NOT NULL,
dest_mobile text,
dest_merchant_id integer,
when_created timestamp without time zone NOT NULL
-- more stuff :)
);
CREATE TABLE agents (
agent_id integer PRIMARY KEY,
name text,
country text NOT NULL,
region text,
city text,
subcity text,
when_created timestamp without time zone NOT NULL
-- more stuff :)
);
CREATE TABLE agent_transactions (
atx_id integer PRIMARY KEY,
u_id integer NOT NULL,
agent_id integer NOT NULL,
amount numeric NOT NULL,
fee_amount_scalar numeric NOT NULL,
when_created timestamp without time zone NOT NULL
-- more stuff :)
);
CREATE TABLE wallets (
wallet_id integer PRIMARY KEY,
currency text NOT NULL,
ledger_location text NOT NULL,
when_created timestamp without time zone NOT NULL
-- more stuff :)
);

--QUESTION 1
SELECT COUNT(u_id) FROM users

--QUESTION 2
SELECT COUNT(transfer_id) FROM transfers WHERE send_amount_currency = 'CFA';

--QUESTION 3
SELECT COUNT(u_id) FROM transfers WHERE send_amount_currency = 'CFA';

--QUESTION 4
SELECT COUNT(atx_id) FROM agent_transactions WHERE EXTRACT(YEAR FROM when_created)=2018 
GROUP BY EXTRACT(MONTH FROM when_created);

--QUESTION 5
WITH agentwithdrawers AS (SELECT COUNT(agent_id) AS netwithdrawers FROM agent_transactions HAVING COUNT(amount)
IN (SELECT COUNT(amount) FROM agent_transactions WHERE amount > -1 AND amount !=0 
HAVING COUNT(amount)>(SELECT COUNT(amount) FROM agent_transactions WHERE amount < 1 AND amount !=0)))
SELECT netwithdrawers FROM agentwithdrawers;

--QUESTION 6
SELECT COUNT(atx.amount) AS "atx volume city summary" ,ag.city FROM agent_transactions AS atx LEFT OUTER JOIN agents
AS ag ON atx.atx_id = ag.agent_id 
WHERE atx.when_created > current_date - interval '7 days' GROUP BY ag.city;

--QUESTION 7
SELECT COUNT(atx.amount) AS "atx volume ", COUNT(ag.country) AS "country", COUNT(ag.city)  AS "city" 
FROM agent_transactions AS atx INNER JOIN agents AS ag ON atx.atx_id = ag.agent_id GROUP BY ag.country;

--QUESTION 8


--QUESTION 9
SELECT COUNT(transfers.source_wallet_id) AS "unique senders", COUNT(transfer_id) AS "transfer_kind",
wallets.ledger_location AS "country", SUM(transfers.send_amount_scalar) AS "volume" FROM transfers 
INNER JOIN wallets ON transfers.source_wallet_id = wallets.wallet_id
WHERE transfers.when_created > current_date - interval '7 days' GROUP BY wallets.ledger_location, transfers.kind;


--QUESTION 10
SELECT SUM(transfers.send_amount_scalar) FROM transfers JOIN wallets ON wallets.wallet_id = transfers.source_wallet_id
WHERE transfers.send_amount_scalar > 10000000 AND transfers.send_amount_currency = 'CFA'
AND transfers.when_created > current_date - interval '1 month'