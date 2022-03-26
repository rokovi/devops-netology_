# Домашнее задание к занятию "4.2. Использование Python для решения типовых DevOps задач"

## Обязательная задача 1

Есть скрипт:
```python
#!/usr/bin/env python3
a = 1
b = '2'
c = a + b
```

### Вопросы:
| Вопрос  | Ответ                                            |
| ------------- |--------------------------------------------------|
| Какое значение будет присвоено переменной `c`?  | Никакое. Будет ошибка о разных типах переменных. |
| Как получить для переменной `c` значение 12?  | c = str(a) + b                                             |
| Как получить для переменной `c` значение 3?  | c = a + int(b)                                             |

## Обязательная задача 2
Мы устроились на работу в компанию, где раньше уже был DevOps Engineer. Он написал скрипт, позволяющий узнать, какие файлы модифицированы в репозитории, относительно локальных изменений. Этим скриптом недовольно начальство, потому что в его выводе есть не все изменённые файлы, а также непонятен полный путь к директории, где они находятся. Как можно доработать скрипт ниже, чтобы он исполнял требования вашего руководителя?

```python
  

import os

bash_command = ["cd ~/netology/sysadm-homeworks", "git status"]
result_os = os.popen(' && '.join(bash_command)).read()
is_change = False
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        print(prepare_result)
        break
```

### Ваш скрипт:
```python
#!/usr/bin/env python3

import os

bash_command = ["cd /mnt/d/2022/!EDUC/Netology/DevOps/HomeWorks/devops-netology_/", "git status"]
path = bash_command[0].replace('cd ', '')
result_os = os.popen(' && '.join(bash_command)).read()
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        print(f"{path}{prepare_result}")
```

### Вывод скрипта при запуске при тестировании:
```
new0ne@rokovi-lp:/mnt/d/2022/!EDUC/Netology/DevOps/HomeWorks/devops-netology_/04-script-02-py$ python3 ./test.py
/mnt/d/2022/!EDUC/Netology/DevOps/HomeWorks/devops-netology_/04-script-01-bash/hook.sh
/mnt/d/2022/!EDUC/Netology/DevOps/HomeWorks/devops-netology_/04-script-02-py/test.txt
```

## Обязательная задача 3
1. Доработать скрипт выше так, чтобы он мог проверять не только локальный репозиторий в текущей директории, а также умел воспринимать путь к репозиторию, который мы передаём как входной параметр. Мы точно знаем, что начальство коварное и будет проверять работу этого скрипта в директориях, которые не являются локальными репозиториями.

### Ваш скрипт:
```python
#!/usr/bin/env python3

import os
import sys

if not os.path.exists(sys.argv[1] + '.git'):
    print('This is not a git repository')
else:
    place = 'cd ' + sys.argv[1]
    bash_command = [place, "git status"]
    result_os = os.popen(' && '.join(bash_command)).read()
    for result in result_os.split('\n'):
        if result.find('modified') != -1:
            prepare_result = result.replace('\tmodified:   ', '')
            print(f"{sys.argv[1]}{prepare_result}")

```

### Вывод скрипта при запуске при тестировании:
```
new0ne@rokovi-lp:/mnt/d/2022/!EDUC/Netology/DevOps/HomeWorks/devops-netology_/04-script-02-py$ python3 ./test.py /mnt/d/2022/\!EDUC/Netology/DevOps/HomeWorks/devops-netology_/
/mnt/d/2022/!EDUC/Netology/DevOps/HomeWorks/devops-netology_/04-script-01-bash/hook.sh
/mnt/d/2022/!EDUC/Netology/DevOps/HomeWorks/devops-netology_/04-script-02-py/test.txt
new0ne@rokovi-lp:/mnt/d/2022/!EDUC/Netology/DevOps/HomeWorks/devops-netology_/04-script-02-py$ python3 ./test.py /mnt/d/2022/\!EDUC/Netology/DevOps/HomeWorks/
This is not a git repository
```

## Обязательная задача 4
1. Наша команда разрабатывает несколько веб-сервисов, доступных по http. Мы точно знаем, что на их стенде нет никакой балансировки, кластеризации, за DNS прячется конкретный IP сервера, где установлен сервис. Проблема в том, что отдел, занимающийся нашей инфраструктурой очень часто меняет нам сервера, поэтому IP меняются примерно раз в неделю, при этом сервисы сохраняют за собой DNS имена. Это бы совсем никого не беспокоило, если бы несколько раз сервера не уезжали в такой сегмент сети нашей компании, который недоступен для разработчиков. Мы хотим написать скрипт, который опрашивает веб-сервисы, получает их IP, выводит информацию в стандартный вывод в виде: <URL сервиса> - <его IP>. Также, должна быть реализована возможность проверки текущего IP сервиса c его IP из предыдущей проверки. Если проверка будет провалена - оповестить об этом в стандартный вывод сообщением: [ERROR] <URL сервиса> IP mismatch: <старый IP> <Новый IP>. Будем считать, что наша разработка реализовала сервисы: `drive.google.com`, `mail.google.com`, `google.com`.

### Ваш скрипт:
```python
#!/usr/bin/env python3

import socket
import ast
import os

# set list
hostnames = ['drive.google.com', 'mail.google.com', 'google.com']


def d_create():
    # set empty dict
    mydict = {}
    # fill mydict
    for host in hostnames:
        ip = socket.gethostbyname(host)
        mydict[host] = ip
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
        for k in mod:
            print('[ERROR]', k, 'IP mismatch:', o_dict[k], curr_dict[k])
        for k in same:
            print(k, '-', curr_dict[k])


if not os.path.isfile("dict.txt"):
    show()
else:
    compare()

```

### Вывод скрипта при запуске при тестировании:
```
[ERROR] drive.google.com IP mismatch: 64.233.165.195 64.233.165.194
[ERROR] mail.google.com IP mismatch: 64.233.162.17 64.233.162.18
google.com - 64.233.162.139
```

## Дополнительное задание (со звездочкой*) - необязательно к выполнению

Так получилось, что мы очень часто вносим правки в конфигурацию своей системы прямо на сервере. Но так как вся наша команда разработки держит файлы конфигурации в github и пользуется gitflow, то нам приходится каждый раз переносить архив с нашими изменениями с сервера на наш локальный компьютер, формировать новую ветку, коммитить в неё изменения, создавать pull request (PR) и только после выполнения Merge мы наконец можем официально подтвердить, что новая конфигурация применена. Мы хотим максимально автоматизировать всю цепочку действий. Для этого нам нужно написать скрипт, который будет в директории с локальным репозиторием обращаться по API к github, создавать PR для вливания текущей выбранной ветки в master с сообщением, которое мы вписываем в первый параметр при обращении к py-файлу (сообщение не может быть пустым). При желании, можно добавить к указанному функционалу создание новой ветки, commit и push в неё изменений конфигурации. С директорией локального репозитория можно делать всё, что угодно. Также, принимаем во внимание, что Merge Conflict у нас отсутствуют и их точно не будет при push, как в свою ветку, так и при слиянии в master. Важно получить конечный результат с созданным PR, в котором применяются наши изменения. 

### Ваш скрипт:
```python
???
```

### Вывод скрипта при запуске при тестировании:
```
???
```