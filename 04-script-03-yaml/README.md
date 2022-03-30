# Домашнее задание к занятию "4.3. Языки разметки JSON и YAML"


## Обязательная задача 1
Мы выгрузили JSON, который получили через API запрос к нашему сервису:
```
    { "info" : "Sample JSON output from our service\t",
        "elements" :[
            { "name" : "first",
            "type" : "server",
            "ip" : 7175 
            },
            { "name" : "second",
            "type" : "proxy",
            "ip" : "71.78.22.43"
            }
        ]
    }
```
  Нужно найти и исправить все ошибки, которые допускает наш сервис

## Обязательная задача 2
В прошлый рабочий день мы создавали скрипт, позволяющий опрашивать веб-сервисы и получать их IP. К уже реализованному функционалу нам нужно добавить возможность записи JSON и YAML файлов, описывающих наши сервисы. Формат записи JSON по одному сервису: `{ "имя сервиса" : "его IP"}`. Формат записи YAML по одному сервису: `- имя сервиса: его IP`. Если в момент исполнения скрипта меняется IP у сервиса - он должен так же поменяться в yml и json файле.

### Ваш скрипт:
```python
#!/usr/bin/env python3

import socket
import ast
import os
import json
import yaml

# set list
hostnames = ['drive.google.com', 'mail.google.com', 'google.com']


def d_create():
    # set empty dict
    mydict = {}
    # fill mydict
    for host in hostnames:
        ip = socket.gethostbyname(host)
        mydict[host] = ip
    # save to json
    for k in mydict:
        create_oneline_dict = {k: mydict[k]}
        with open(f'{k}.json', 'w') as f:
            json.dump(create_oneline_dict, f)
        with open(f'{k}.yaml', 'w') as ff:
            yaml.dump(create_oneline_dict, ff)
    # save mydict to file
    file_w = open("dict.txt", "w")
    file_w.write(str(mydict))
    file_w.close()
    return mydict


def show():
    # show urls with IPs
    for host in hostnames:
        ip = socket.gethostbyname(host)
        print(f'{host} - {ip}')
    d_create()


def compare():
    # read form previously crated file
    file_r = open("dict.txt", "r")
    # make dict from str via ast module
    o_dict = ast.literal_eval(file_r.read())
    file_r.close()
    # cause o_dict already read in step above we can rewrite
    curr_dict = d_create()
    if curr_dict == o_dict:
        show()
    else:
        mod = [k for k in curr_dict if curr_dict[k] != o_dict[k]]
        same = [k for k in curr_dict if curr_dict[k] == o_dict[k]]
        # create new empty dict for parse
        d_json_mod = {}
        for k in mod:
            print('[ERROR]', k, 'IP mismatch:', o_dict[k], curr_dict[k])
            # fill d_json_mod dict with changed IPs
            d_json_mod[k] = curr_dict[k]
            # create json file
        for kk in d_json_mod:
            compare_oneline_dict = {kk: d_json_mod[kk]}
            with open(f'{kk}.json', 'w') as f:
                json.dump(compare_oneline_dict, f)
            # create yaml file
            with open(f'{kk}.yaml', 'w') as ff:
                yaml.dump(compare_oneline_dict, ff)
        for k in same:
            print(k, '-', curr_dict[k])


if not os.path.isfile("dict.txt"):
    show()
else:
    compare()
```

### Вывод скрипта при запуске при тестировании:
```
[ERROR] mail.google.com IP mismatch: 142.251.1.83 64.233.165.19
[ERROR] google.com IP mismatch: 64.233.162.139 209.85.233.113
drive.google.com - 74.125.131.194

Process finished with exit code 0
```

### json-файл(ы), который(е) записал ваш скрипт:
```json
{"mail.google.com": "64.233.165.19"}
{"google.com": "209.85.233.113"}
{"drive.google.com": "74.125.131.194"}
```

### yml-файл(ы), который(е) записал ваш скрипт:
```yaml
mail.google.com: 64.233.165.19
google.com: 209.85.233.113
drive.google.com: 74.125.131.194
```

## Дополнительное задание (со звездочкой*) - необязательно к выполнению

Так как команды в нашей компании никак не могут прийти к единому мнению о том, какой формат разметки данных использовать: JSON или YAML, нам нужно реализовать парсер из одного формата в другой. Он должен уметь:
   * Принимать на вход имя файла
   * Проверять формат исходного файла. Если файл не json или yml - скрипт должен остановить свою работу
   * Распознавать какой формат данных в файле. Считается, что файлы *.json и *.yml могут быть перепутаны
   * Перекодировать данные из исходного формата во второй доступный (из JSON в YAML, из YAML в JSON)
   * При обнаружении ошибки в исходном файле - указать в стандартном выводе строку с ошибкой синтаксиса и её номер
   * Полученный файл должен иметь имя исходного файла, разница в наименовании обеспечивается разницей расширения файлов

### Ваш скрипт:
```python
???
```

### Пример работы скрипта:
???