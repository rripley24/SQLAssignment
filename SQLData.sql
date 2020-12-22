CREATE TABLE card_holder (
  id INT NOT NULL,
  name VARCHAR(50),
  PRIMARY KEY (id)
);

CREATE TABLE credit_card (
  card VARCHAR(20) NOT NULL,
  id_card_holder INT,
  PRIMARY KEY (card)
);

CREATE TABLE merchant_category (
  id INT NOT NULL,
  name VARCHAR(15),
  PRIMARY KEY (id)
);

CREATE TABLE merchant (
  id INT NOT NULL,
  name VARCHAR(30),
  id_merchant_category INT NOT NULL,
  FOREIGN KEY (id_merchant_category) REFERENCES merchant_category (id),
  PRIMARY KEY (id)
);

CREATE TABLE transaction (
  id INT NOT NULL,
  date timestamp NOT NULL,
  amount float,
  card VARCHAR(20),
  id_merchant INT,
  FOREIGN KEY (card) REFERENCES credit_card (card),
  FOREIGN KEY (id_merchant) REFERENCES merchant (id),
  PRIMARY KEY (id)
);

--How can you isolate (or group) the transactions of each cardholder?
select count(*), id_card_holder,name 
from transaction
inner join credit_card on transaction.card = credit_card.card
inner join card_holder on credit_card.id_card_holder=card_holder.id
group by id_card_holder, name;

--Consider the time period 7:00 a.m. to 9:00 a.m.
select date
from transaction
where date_part('hour', date) >= 7
and date_part('hour', date) < 9;

--What are the 100 highest transactions during this time period?
select date, amount
from transaction 
where date_part('hour', date) >= 7
and date_part('hour', date) < 9
order by 2 desc
limit 100;

--Do you see any fraudulent or anomalous transactions?
--- Yes

--If you answered yes to the previous question, 
--explain why you think there might be fraudulent transactions during this time frame.
--- One has way too many decimals and some are very large (without decimals) 
--- when compared against the rest.


-- Count the transactions less than $2.00 per cardholder subtracted min from max date
select count(*), card, max(date) - min(date)
from transaction
where amount < 2 
group by card
order by 1 desc;

--joined 3 tables to find the card holder
select count(*), credit_card.id_card_holder
from transaction
inner join credit_card on transaction.card = credit_card.card
inner join card_holder on credit_card.id_card_holder=card_holder.id
where amount < 2 
group by credit_card.id_card_holder;

--further investigated top transaction card
select * 
from transaction 
where card = '376027549341849'
and amount < 2;

--If we are assuming anything less than $2.00 is fraudulent, then yes, we found the
--top fraudulent cards with counts higher than 10.


--What are the top five merchants prone to being hacked using small transactions?
select count(*), card 
from transaction
where amount < 2 
group by card 
order by 1 desc
limit 5;

select count(*), id_merchant, name
from transaction
inner join merchant on transaction.id_merchant = merchant.id
where amount < 2
group by id_merchant, name
order by 1 desc
limit 5;
-- Top 5 merchants hacked are Wood-Ramirez, Hood-Phillips, Baker Inc,
-- Henderson and Sons, and Atkinson Ltd.

--Once you have a query that can be reused, create a view for each of the previous queries.
create view vw_cardholder_transactions as 
select count(*), id_card_holder,name from transaction
inner join credit_card on transaction.card = credit_card.card
inner join card_holder on credit_card.id_card_holder=card_holder.id
group by id_card_holder, name;

select * from vw_cardholder_transactions

create view vw_transaction_time as 
select date
from transaction
where date_part('hour', date) >= 7
and date_part('hour', date) < 9;

select * from vw_transaction_time

create view vw_100_highest_transactions as 
select date, amount
from transaction 
where date_part('hour', date) >= 7
and date_part('hour', date) < 9
order by 2 desc
limit 100;

select * from vw_100_highest_transactions

create view vw_smallest_transactions as 
select count(*), card, max(date) - min(date)
from transaction
where amount < 2 
group by card
order by 1 desc;

select * from vw_smallest_transactions

create view vw_top_5_merchant_hacked as 
select count(*), id_merchant, name
from transaction
inner join merchant on transaction.id_merchant = merchant.id
where amount < 2
group by id_merchant, name
order by 1 desc
limit 5;

select * from vw_top_5_merchant_hacked

--Verify if there are any fraudulent transactions in the 
-- history of two of the most important customers of the firm. 
--  For privacy reasons, you only know that their cardholders' IDs are 18 and 2.

create view vw_2_important_customers as 
select id_card_holder, name, amount, date
from transaction
inner join credit_card on transaction.card = credit_card.card
inner join card_holder on credit_card.id_card_holder=card_holder.id
where id_card_holder = '2' or id_card_holder = '18'
group by id_card_holder, name, amount, date
order by 3 desc;

-- view for customer 2
create view vw_important_customer2 as 
select amount, date
from transaction
inner join credit_card on transaction.card = credit_card.card
inner join card_holder on credit_card.id_card_holder=card_holder.id
where id_card_holder = '2'
group by amount, date
order by 2 desc;

--view for customer 18
create view vw_important_customer18 as 
select amount, date
from transaction
inner join credit_card on transaction.card = credit_card.card
inner join card_holder on credit_card.id_card_holder=card_holder.id
where id_card_holder = '18'
group by amount, date
order by 2 desc;

--data of daily transactions from jan to jun 2018 for card holder 25
-- use table.column to parse thru and collect the data I want
select card_holder.name, transaction.date, transaction.amount, transaction.id_merchant
from transaction
inner join credit_card on transaction.card = credit_card.card
inner join card_holder on credit_card.id_card_holder=card_holder.id
where id_card_holder = '25'
and date_part('month', date) >= 1
and date_part('month', date) < 7
order by 2;

--view of data of daily transactions from jan to jun 2018 for card holder 25
create view vw_cardholder25 as 
select amount, date
from transaction
inner join credit_card on transaction.card = credit_card.card
inner join card_holder on credit_card.id_card_holder=card_holder.id
where id_card_holder = '25'
and date_part('month', date) >= 1
and date_part('month', date) < 7
group by amount, date
order by 2;

