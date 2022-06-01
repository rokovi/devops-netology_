# Домашнее задание к занятию "6.2. SQL"

## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 12) c 2 volume, 
в который будут складываться данные БД и бэкапы.

Приведите получившуюся команду или docker-compose манифест.
```bash

version: "2.2"

networks:
  postgres:
    driver: bridge

volumes:
    pg_data: {}
    pg_bu: {}

services:

  postgres:
    container_name: postgres-netology
    image: postgres:12
    environment:
      POSTGRES_PASSWORD: "pass"
      PGDATA: "/var/lib/postgresql/data/pgdata"
    volumes:
      - pg_data:/var/lib/postgresql/data
      - pg_bu:/backup
    ports:
      - "5432:5432"
    restart: always
    networks:
      - postgres

  adminer:
    container_name: adminer-netology
    image: adminer
    ports:
      - "8080:8080"
    restart: always
    networks:
      - postgres

```

## Задача 2

В БД из задачи 1: 
- создайте пользователя test-admin-user и БД test_db
- в БД test_db создайте таблицу orders и clients (спeцификация таблиц ниже)
- предоставьте привилегии на все операции пользователю test-admin-user на таблицы БД test_db
- создайте пользователя test-simple-user  
- предоставьте пользователю test-simple-user права на SELECT/INSERT/UPDATE/DELETE данных таблиц БД test_db

Таблица orders:
- id (serial primary key)
- наименование (string)
- цена (integer)

Таблица clients:
- id (serial primary key)
- фамилия (string)
- страна проживания (string, index)
- заказ (foreign key orders)

Приведите:
- итоговый список БД после выполнения пунктов выше,
``` sql
test_db=# \l
                                 List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges
-----------+----------+----------+------------+------------+-----------------------
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 |
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
 test_db   | postgres | UTF8     | en_US.utf8 | en_US.utf8 |
(4 rows)


```
- описание таблиц (describe)
``` sql
test_db=# \d orders
                                      Table "public.orders"
    Column    |         Type          | Collation | Nullable |              Default
--------------+-----------------------+-----------+----------+------------------------------------
 id           | integer               |           | not null | nextval('orders_id_seq'::regclass)
 Наименование | character varying(30) |           | not null |
 Цена         | integer               |           |          |
Indexes:
    "orders_pkey" PRIMARY KEY, btree (id)
Referenced by:
    TABLE "clients" CONSTRAINT "clients_Заказ_fkey" FOREIGN KEY ("Заказ") REFERENCES orders(id)

test_db=# \d+ clients
                                                             Table "public.clients"
      Column       |         Type          | Collation | Nullable |               Default               | Storage  | Stats target | Description
-------------------+-----------------------+-----------+----------+-------------------------------------+----------+--------------+-------------
 id                | integer               |           | not null | nextval('clients_id_seq'::regclass) | plain    |              |
 Фамилия           | character varying(30) |           | not null |                                     | extended |              |
 Страна_проживания | character varying(30) |           | not null |                                     | extended |              |
 Заказ             | integer               |           |          |                                     | plain    |              |
Indexes:
    "clients_pkey" PRIMARY KEY, btree (id)
    "country_idx" btree ("Страна_проживания")
Foreign-key constraints:
    "clients_Заказ_fkey" FOREIGN KEY ("Заказ") REFERENCES orders(id)
Access method: heap

```
- SQL-запрос для выдачи списка пользователей с правами над таблицами test_db
``` sql
SELECT
    grantee,
    privilege_type,
    table_name
FROM
    information_schema.role_table_grants
WHERE
    table_name = 'orders'
OR
    table_name = 'clients';
```
- список пользователей с правами над таблицами test_db
``` sql
     grantee      | privilege_type | table_name
------------------+----------------+------------
 postgres         | INSERT         | orders
 postgres         | SELECT         | orders
 postgres         | UPDATE         | orders
 postgres         | DELETE         | orders
 postgres         | TRUNCATE       | orders
 postgres         | REFERENCES     | orders
 postgres         | TRIGGER        | orders
 test-admin-user  | INSERT         | orders
 test-admin-user  | SELECT         | orders
 test-admin-user  | UPDATE         | orders
 test-admin-user  | DELETE         | orders
 test-admin-user  | TRUNCATE       | orders
 test-admin-user  | REFERENCES     | orders
 test-admin-user  | TRIGGER        | orders
 test-simple-user | INSERT         | orders
 test-simple-user | SELECT         | orders
 test-simple-user | UPDATE         | orders
 test-simple-user | DELETE         | orders
 postgres         | INSERT         | clients
 postgres         | SELECT         | clients
 postgres         | UPDATE         | clients
 postgres         | DELETE         | clients
 postgres         | TRUNCATE       | clients
 postgres         | REFERENCES     | clients
 postgres         | TRIGGER        | clients
 test-admin-user  | INSERT         | clients
 test-admin-user  | SELECT         | clients
 test-admin-user  | UPDATE         | clients
 test-admin-user  | DELETE         | clients
 test-admin-user  | TRUNCATE       | clients
 test-admin-user  | REFERENCES     | clients
 test-admin-user  | TRIGGER        | clients
 test-simple-user | INSERT         | clients
 test-simple-user | SELECT         | clients
 test-simple-user | UPDATE         | clients
 test-simple-user | DELETE         | clients
(36 rows)

```
## Задача 3

Используя SQL синтаксис - наполните таблицы следующими тестовыми данными:

Таблица orders

|Наименование|цена|
|------------|----|
|Шоколад| 10 |
|Принтер| 3000 |
|Книга| 500 |
|Монитор| 7000|
|Гитара| 4000|

Таблица clients

|ФИО|Страна проживания|
|------------|----|
|Иванов Иван Иванович| USA |
|Петров Петр Петрович| Canada |
|Иоганн Себастьян Бах| Japan |
|Ронни Джеймс Дио| Russia|
|Ritchie Blackmore| Russia|

Используя SQL синтаксис:
- вычислите количество записей для каждой таблицы 
- приведите в ответе:
    - запросы 
> SELECT COUNT(*) FROM orders;

> SELECT COUNT(*) FROM clients;
   
 - результаты их выполнения.
```sql
test_db=# SELECT COUNT(*) FROM orders;
 count
-------
     5
(1 row)

test_db=# SELECT COUNT(*) FROM clients;
 count
-------
     5
(1 row)
```

## Задача 4

Часть пользователей из таблицы clients решили оформить заказы из таблицы orders.

Используя foreign keys свяжите записи из таблиц, согласно таблице:

|ФИО|Заказ|
|------------|----|
|Иванов Иван Иванович| Книга |
|Петров Петр Петрович| Монитор |
|Иоганн Себастьян Бах| Гитара |

Приведите SQL-запросы для выполнения данных операций.
```bash
UPDATE clients SET Заказ = 3 WHERE id = 1;
UPDATE clients SET Заказ = 4 WHERE id = 2;
UPDATE clients SET Заказ = 5 WHERE id = 3;
```

Приведите SQL-запрос для выдачи всех пользователей, которые совершили заказ, а также вывод данного запроса.
> SELECT * FROM clients WHERE Заказ !=0;
```sql
test_db=# SELECT * FROM clients WHERE Заказ !=0;
 id |         ФИО          | Страна_проживания | Заказ
----+----------------------+-------------------+-------
  1 | Иванов Иван Иванович | USA               |     3
  2 | Петров Петр Петрович | Canada            |     4
  3 | Иоганн Себастьян Бах | Japan             |     5
(3 rows)

test_db=# SELECT *
FROM clients
INNER JOIN orders
ON clients.Заказ = orders.id;
 id |         ФИО          | Страна_проживания | Заказ | id | Наименование | Цена
----+----------------------+-------------------+-------+----+--------------+------
  1 | Иванов Иван Иванович | USA               |     3 |  3 | Книга        |  500
  2 | Петров Петр Петрович | Canada            |     4 |  4 | Монитор      | 7000
  3 | Иоганн Себастьян Бах | Japan             |     5 |  5 | Гитара       | 4000
(3 rows)

``` 
Подсказк - используйте директиву `UPDATE`.

## Задача 5

Получите полную информацию по выполнению запроса выдачи всех пользователей из задачи 4 
(используя директиву EXPLAIN).

Приведите получившийся результат и объясните что значат полученные значения.

```sql
test_db=# EXPLAIN SELECT * FROM clients WHERE Заказ !=0;
                         QUERY PLAN
------------------------------------------------------------
 Seq Scan on clients  (cost=0.00..15.25 rows=418 width=164)
   Filter: ("Заказ" <> 0)
(2 rows)

```
`Seq Scan` - последовательное чтение данных(блок за блоком)

`cost` - затраты на выполнение операции. Первое значение - получение первой строки,
второе - всех строк.

`rows` - кол-во возвращаемых строк.

`width` - средний размер строки в байтах.

## Задача 6

Создайте бэкап БД test_db и поместите его в volume, предназначенный для бэкапов (см. Задачу 1).

Остановите контейнер с PostgreSQL (но не удаляйте volumes).

Поднимите новый пустой контейнер с PostgreSQL.

Восстановите БД test_db в новом контейнере.

Приведите список операций, который вы применяли для бэкапа данных и восстановления. 

```bash
new0ne@new0ne-dp:~$ docker exec -it postgres-netology bash
root@c98db4df3171:/# su postgres
postgres@c98db4df3171:/$ rm /backup/test_db.sql
postgres@c98db4df3171:/$ pg_dump test_db > /backup/test_db.sql
new0ne@new0ne-dp:~/docker/netology0602/docker_pg$ docker ps
CONTAINER ID   IMAGE         COMMAND                  CREATED      STATUS      PORTS                                       NAMES
428407bf545d   adminer       "entrypoint.sh docke…"   3 days ago   Up 3 days   0.0.0.0:8080->8080/tcp, :::8080->8080/tcp   adminer-netologynetology
c98db4df3171   postgres:12   "docker-entrypoint.s…"   3 days ago   Up 3 days   0.0.0.0:5432->5432/tcp, :::5432->5432/tcp   postgres-netology
new0ne@new0ne-dp:~/docker/netology0602/docker_pg$ docker stop postgres-netology
postgres-netology
new0ne@new0ne-dp:~/docker/netology0602/docker_pg$ docker ps
CONTAINER ID   IMAGE     COMMAND                  CREATED      STATUS      PORTS                                       NAMES
428407bf545d   adminer   "entrypoint.sh docke…"   3 days ago   Up 3 days   0.0.0.0:8080->8080/tcp, :::8080->8080/tcp   adminer-netologynetology
new0ne@new0ne-dp:~/docker/netology0602/docker_pg$ docker run --name postgres-netology2 -e POSTGRES_PASSWORD=pass -v docker_pg_pg_bu:/backup -p 0.0.0.0:5432:5432/tcp -d postgres:12
3a256b5a1b048e04af9c9c0cb7790231d67c9d0e41fade8adc0fbf09f25b929f
new0ne@new0ne-dp:~/docker/netology0602/docker_pg$ docker exec -it postgres-netology2 bash
root@3a256b5a1b04:/# su postgres
postgres@3a256b5a1b04:/$ psql -c 'CREATE DATABASE test_db;'
CREATE DATABASE
postgres@3a256b5a1b04:/$ psql -c 'create user "test-admin-user";' && psql -c 'create user "test-simple-user";'
CREATE ROLE
CREATE ROLE
postgres@3a256b5a1b04:/$ psql test_db < /backup/test_db.sql
SET
SET
SET
SET
SET
 set_config
------------

(1 row)

SET
SET
SET
SET
SET
SET
ERROR:  database "test_db" already exists
CREATE TABLE
ALTER TABLE
CREATE SEQUENCE
ALTER TABLE
ALTER SEQUENCE
CREATE TABLE
ALTER TABLE
CREATE SEQUENCE
ALTER TABLE
ALTER SEQUENCE
ALTER TABLE
ALTER TABLE
COPY 5
COPY 5
 setval
--------
      5
(1 row)

 setval
--------
      5
(1 row)

ALTER TABLE
ALTER TABLE
CREATE INDEX
ALTER TABLE
GRANT
GRANT
GRANT
GRANT
postgres@3a256b5a1b04:/$ psql
psql (12.11 (Debian 12.11-1.pgdg110+1))
Type "help" for help.
postgres=# \c test_db
You are now connected to database "test_db" as user "postgres".
test_db=# \d
               List of relations
 Schema |      Name      |   Type   |  Owner
--------+----------------+----------+----------
 public | clients        | table    | postgres
 public | clients_id_seq | sequence | postgres
 public | orders         | table    | postgres
 public | orders_id_seq  | sequence | postgres
(4 rows)
```
---
