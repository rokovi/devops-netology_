# Домашнее задание к занятию "6.5. Elasticsearch"

## Задача 1

В этом задании вы потренируетесь в:
- установке elasticsearch
- первоначальном конфигурировании elastcisearch
- запуске elasticsearch в docker

Используя докер образ [centos:7](https://hub.docker.com/_/centos) как базовый и 
[документацию по установке и запуску Elastcisearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/targz.html):

- составьте Dockerfile-манифест для elasticsearch
- соберите docker-образ и сделайте `push` в ваш docker.io репозиторий
- запустите контейнер из получившегося образа и выполните запрос пути `/` c хост-машины

Требования к `elasticsearch.yml`:
- данные `path` должны сохраняться в `/var/lib`
- имя ноды должно быть `netology_test`

В ответе приведите:
- текст Dockerfile манифеста
```yml
#Prepare image for systemd
FROM centos:7

#Set envs
ENV container docker
ENV PATH=$PATH:/usr/share/elasticsearch/bin

RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;

#Install OpenJDK 8
RUN yum -y install java-1.8.0-openjdk.x86_64; yum clean all; \
echo "networkaddress.cache.ttl=60" >> /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.332.b09-1.el7_9.x86_64/jre/lib/security/java.security

#Copy rpm into container
COPY elasticsearch-8.2.2-x86_64.rpm /tmp

#Install Elastic
RUN yum -y localinstall /tmp/elasticsearch-8.2.2-x86_64.rpm; yum clean all; systemctl enable elasticsearch.service; \
chown -R elasticsearch:elasticsearch /etc/elasticsearch

#Copy conf files
COPY elasticsearch.yml /etc/elasticsearch

#Clean out
RUN rm -f /tmp/elasticsearch-8.2.2-x86_64.rpm

#Set workdir
WORKDIR /etc/elasticsearch

#Set user for run elastic
USER elasticsearch

EXPOSE 9200

CMD ["elasticsearch"]
```
- ссылку на образ в репозитории dockerhub

https://hub.docker.com/r/rokovi/elastic8


- ответ `elasticsearch` на запрос пути `/` в json виде
```json
new0ne@new0ne-dp:~/docker/netology0605$ curl --cacert http_ca.crt -u elastic https://localhost:9200
Enter host password for user 'elastic':
{
  "name" : "netology_test",
  "cluster_name" : "netology-cluster",
  "cluster_uuid" : "zzOaqtnVQFarkrj6iEuCoQ",
  "version" : {
    "number" : "8.2.2",
    "build_flavor" : "default",
    "build_type" : "rpm",
    "build_hash" : "9876968ef3c745186b94fdabd4483e01499224ef",
    "build_date" : "2022-05-25T15:47:06.259735307Z",
    "build_snapshot" : false,
    "lucene_version" : "9.1.0",
    "minimum_wire_compatibility_version" : "7.17.0",
    "minimum_index_compatibility_version" : "7.0.0"
  },
  "tagline" : "You Know, for Search"
}
```

Подсказки:
- возможно вам понадобится установка пакета perl-Digest-SHA для корректной работы пакета shasum
- при сетевых проблемах внимательно изучите кластерные и сетевые настройки в elasticsearch.yml
- при некоторых проблемах вам поможет docker директива ulimit
- elasticsearch в логах обычно описывает проблему и пути ее решения

Далее мы будем работать с данным экземпляром elasticsearch.

## Задача 2

В этом задании вы научитесь:
- создавать и удалять индексы
- изучать состояние кластера
- обосновывать причину деградации доступности данных

Ознакомтесь с [документацией](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html) 
и добавьте в `elasticsearch` 3 индекса, в соответствии со таблицей:

| Имя | Количество реплик | Количество шард |
|-----|-------------------|-----------------|
| ind-1| 0 | 1 |
| ind-2 | 1 | 2 |
| ind-3 | 2 | 4 |

Получите список индексов и их статусов, используя API и **приведите в ответе** на задание.

```bash
new0ne@new0ne-dp:~/docker/netology0605$ curl --cacert http_ca.crt -u elastic:HKaAp=vztj6dKMj7-i7F -X GET "https://localhost:9200/_cat/indices/_all?v=true&s=index&pretty"
health status index uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   ind-1 ukqtm7jyTSiMvWFLhN510A   1   0          0            0       225b           225b
yellow open   ind-2 1vOfFZIATx6OYzhBMocgrg   2   1          0            0       450b           450b
yellow open   ind-3 gxknyrv2Sh6T4eJpJAQ2Rg   4   2          0            0       900b           900b
```

Получите состояние кластера `elasticsearch`, используя API.

```json
new0ne@new0ne-dp:~/docker/netology0605$ curl --cacert http_ca.crt -u elastic:HKaAp=vztj6dKMj7-i7F -X GET "https://localhost:9200/_cluster/health?pretty"
{
  "cluster_name" : "netology-cluster",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 9,
  "active_shards" : 9,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 10,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 47.368421052631575
}

```

Как вы думаете, почему часть индексов и кластер находится в состоянии yellow?

>Elasticsearch - не назначит реплику той же ноде, где изначально был создан шард. Поэтому 
> ind-1 `green`, т.к. у него нет реплик. 
>
> Часть индексов находится в статусе yellow т.к. нет возможности аллоцировать 
> реплики, потому что используется всего одна нода, т.к. на ней расположены 
> primary шарды. Elastic никогда не назначит реплику на ноду, на 
> которой расположен primary шард.

Удалите все индексы.
```bash
new0ne@new0ne-dp:~/docker/netology0605$ curl --cacert http_ca.crt -u elastic:HKaAp=vztj6dKMj7-i7F -X DELETE "https://localhost:9200/ind-1?pretty"
{
  "acknowledged" : true
}
new0ne@new0ne-dp:~/docker/netology0605$ curl --cacert http_ca.crt -u elastic:HKaAp=vztj6dKMj7-i7F -X DELETE "https://localhost:9200/ind-2?pretty"
{
  "acknowledged" : true
}
new0ne@new0ne-dp:~/docker/netology0605$ curl --cacert http_ca.crt -u elastic:HKaAp=vztj6dKMj7-i7F -X DELETE "https://localhost:9200/ind-3?pretty"
{
  "acknowledged" : true
}
new0ne@new0ne-dp:~/docker/netology0605$ curl --cacert http_ca.crt -u elastic:HKaAp=vztj6dKMj7-i7F -X GET "https://localhost:9200/_cat/indices/_all?v=true&s=index&pretty"
health status index uuid pri rep docs.count docs.deleted store.size pri.store.size
```
**Важно**

При проектировании кластера elasticsearch нужно корректно рассчитывать количество реплик и шард,
иначе возможна потеря данных индексов, вплоть до полной, при деградации системы.

## Задача 3

В данном задании вы научитесь:
- создавать бэкапы данных
- восстанавливать индексы из бэкапов

Создайте директорию `{путь до корневой директории с elasticsearch в образе}/snapshots`.

Используя API [зарегистрируйте](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-register-repository.html#snapshots-register-repository) 
данную директорию как `snapshot repository` c именем `netology_backup`.

**Приведите в ответе** запрос API и результат вызова API для создания репозитория.

```json
new0ne@new0ne-dp:~/docker/netology0605$ curl --cacert http_ca.crt -u elastic:HKaAp=vztj6dKMj7-i7F -X PUT "https://localhost:9200/_snapshot/netology_backup?pretty" -H 'Content-Type: application/json' -d'
{
  "type": "fs",
  "settings": {
    "location": "/etc/elasticsearch/backups"
  }
}
'
{
  "acknowledged" : true
}

```

Создайте индекс `test` с 0 реплик и 1 шардом и **приведите в ответе** список индексов.

```bash
new0ne@new0ne-dp:~/docker/netology0605$ curl --cacert http_ca.crt -u elastic:HKaAp=vztj6dKMj7-i7F -X GET "https://localhost:9200/_cat/indices/_all?v=true&s=index&pretty"
health status index uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   test  cbVo2CEZQk68qReLgfmKmw   1   0          0            0       225b           225b

```

[Создайте `snapshot`](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-take-snapshot.html) 
состояния кластера `elasticsearch`.

**Приведите в ответе** список файлов в директории со `snapshot`ами.

```bash
bash-4.2$ ls -lah /etc/elasticsearch/backups/
total 48K
drwxr-sr-x 3 elasticsearch elasticsearch 4.0K Jun 15 18:53 .
drwxr-s--- 1 elasticsearch elasticsearch 4.0K Jun 15 18:44 ..
-rw-r--r-- 1 elasticsearch elasticsearch 1.1K Jun 15 18:53 index-0
-rw-r--r-- 1 elasticsearch elasticsearch    8 Jun 15 18:53 index.latest
drwxr-sr-x 5 elasticsearch elasticsearch 4.0K Jun 15 18:53 indices
-rw-r--r-- 1 elasticsearch elasticsearch  19K Jun 15 18:53 meta-WAvj3iZWTpOtST-LtAqRgA.dat
-rw-r--r-- 1 elasticsearch elasticsearch  387 Jun 15 18:53 snap-WAvj3iZWTpOtST-LtAqRgA.dat

```

Удалите индекс `test` и создайте индекс `test-2`. **Приведите в ответе** список индексов.

```bash
new0ne@new0ne-dp:~/docker/netology0605$ curl --cacert http_ca.crt -u elastic:HKaAp=vztj6dKMj7-i7F -X GET "https://localhost:9200/_cat/indices/_all?v=true&s=index&pretty"
health status index  uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   test-2 Ne0ogRJLRceKrdT7pdTwJQ   1   0          0            0       225b           225b
```

[Восстановите](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-restore-snapshot.html) состояние
кластера `elasticsearch` из `snapshot`, созданного ранее. 

**Приведите в ответе** запрос к API восстановления и итоговый список индексов.

```bash
new0ne@new0ne-dp:~/docker/netology0605$ curl --cacert http_ca.crt -u elastic:HKaAp=vztj6dKMj7-i7F -X GET "https://localhost:9200/_cat/indices/_all?v=true&s=index&pretty"
health status index  uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   test   73XgG-hbTUCt130q7Do84Q   1   0          0            0       225b           225b
green  open   test-2 Ne0ogRJLRceKrdT7pdTwJQ   1   0          0            0       225b           225b
```

Подсказки:
- возможно вам понадобится доработать `elasticsearch.yml` в части директивы `path.repo` и перезапустить `elasticsearch`

---
