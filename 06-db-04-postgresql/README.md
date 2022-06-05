# Домашнее задание к занятию "6.4. PostgreSQL"

## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 13). Данные БД сохраните в volume.

```yml
version: "2.2"

networks:
  postgres:
    driver: bridge

volumes:
    postgres_data: {}

services:

  postgres:
    container_name: postgres-netology
    image: postgres
    environment:
      POSTGRES_PASSWORD: "pass"
      PGDATA: "/var/lib/postgresql/data/pgdata"
    volumes:
      - postgres_data:/var/lib/postgresql/data
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

Подключитесь к БД PostgreSQL используя `psql`.

```sql
root@a6fdd6e42005:/# psql -U postgres
psql (14.3 (Debian 14.3-1.pgdg110+1))
Type "help" for help.

postgres=#
```

Воспользуйтесь командой `\?` для вывода подсказки по имеющимся в `psql` управляющим командам.
**Найдите и приведите** управляющие команды для:
- вывода списка БД
>  \l[+]   [PATTERN]      list databases
- подключения к БД
>  \c[onnect] {[DBNAME|- USER|- HOST|- PORT|-] | conninfo}
                         connect to new database (currently "postgres")
- вывода списка таблиц
> \dt[S+] [PATTERN]      list tables
- вывода описания содержимого таблиц
>  \d[S+]  NAME           describe table, view, sequence, or index
- выхода из psql
> \q                     quit psql

## Задача 2

Используя `psql` создайте БД `test_database`.

```sql
postgres=# create database test_database;
CREATE DATABASE
```

Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-04-postgresql/test_data).

Восстановите бэкап БД в `test_database`.
```bash
new0ne@new0ne-dp:~/docker/netology0604$ docker exec -i postgres-netology psql -U postgres test_database < test_dump.sql
```

Перейдите в управляющую консоль `psql` внутри контейнера.
```bash
new0ne@new0ne-dp:~/docker/netology0604$ docker exec -it postgres-netology bash
```
Подключитесь к восстановленной БД и проведите операцию ANALYZE для сбора статистики по таблице.
```sql
root@a6fdd6e42005:/# psql -U postgres
psql (14.3 (Debian 14.3-1.pgdg110+1))
Type "help" for help.

postgres=# \c test_database
You are now connected to database "test_database" as user "postgres".
test_database=# analyze verbose public.orders;
INFO:  analyzing "public.orders"
INFO:  "orders": scanned 1 of 1 pages, containing 8 live rows and 0 dead rows; 8 rows in sample, 8 estimated total rows
ANALYZE
```

Используя таблицу [pg_stats](https://postgrespro.ru/docs/postgresql/12/view-pg-stats), найдите столбец таблицы `orders` 
с наибольшим средним значением размера элементов в байтах.

**Приведите в ответе** команду, которую вы использовали для вычисления и полученный результат.
```sql
test_database=# SELECT attname, avg_width FROM pg_stats
WHERE tablename = 'orders' ;
 attname | avg_width
---------+-----------
 id      |         4
 title   |        16
 price   |         4
(3 rows)

```

## Задача 3

Архитектор и администратор БД выяснили, что ваша таблица orders разрослась до невиданных размеров и
поиск по ней занимает долгое время. Вам, как успешному выпускнику курсов DevOps в нетологии предложили
провести разбиение таблицы на 2 (шардировать на orders_1 - price>499 и orders_2 - price<=499).

Предложите SQL-транзакцию для проведения данной операции.

Можно ли было изначально исключить "ручное" разбиение при проектировании таблицы orders?

```sql
alter table orders rename to orders_tmp;
create table orders (id integer, title varchar(80) NOT NULL, price integer DEFAULT NULL) partition by range(price);
create table orders_1 partition of orders for values from (0) to (499);
create table orders_2 partition of orders for values from (499) to (999999999);
insert into orders (id, title, price) select * from orders_tmp;
drop table orders_tmp;
```
Можно было бы если изначально настроить секционирование с наследованием с использованием
процедуры и тригера.

## Задача 4

Используя утилиту `pg_dump` создайте бекап БД `test_database`.

```bash
new0ne@new0ne-dp:~/docker/netology0604$ docker exec -i postgres-netology pg_dump -U postgres test_database > /tmp/test_database.sql
```

Как бы вы доработали бэкап-файл, чтобы добавить уникальность значения столбца `title` для таблиц `test_database`?

```sql
---

CREATE TABLE public.orders (
    id integer,
    title character varying(80) NOT NULL,
    price integer,
    UNIQUE(title)
)
PARTITION BY RANGE (price);


---

```

