## Задача 1

- Опишите своими словами основные преимущества применения на практике IaaC паттернов.
- Какой из принципов IaaC является основополагающим?

###### Ответ:

* Основными преимуществами являются: 
 
    - Непрерывная интеграция (CI), за счет ранее описанной инфраструктуры в виде кода,
что исключает ошибки человеческого фактора и дает идемпотентность конфигураций, 
обнаружение на ранней стадии ошибок, за счет автоматических тестов и т.д.
    - Непрерывная доставка (CD) - паттерн который позволяет оперативно 
развернуть\откатить изменения в коде. Делается вручную.
    - Непрерывное развертывание (CD) - позволяте автоматизировать процесс 
непрерывной доставки, исключив человеческий фактор в виде ручного деплоя человеком.
На практике используется для выкатывания обновлений на dev-стенд или тестовый-стенд.
**Обычно выкатывание в прод. не автоматизируется!**
* Основопологающий принцип IaaC - идемпотентность - результат который всегда будет
идентичен предыдущему.

## Задача 2

- Чем Ansible выгодно отличается от других систем управление конфигурациями?
- Какой, на ваш взгляд, метод работы систем конфигурации более надёжный push или pull?

###### Ответ:
* Ansible выгодно отличается тем, что использует уже существующую архитекруту ssh.
Другими словами: дополнительно не нужно разворачивать ПО(агентов).
* Зависит от объемов конечных уст-в. В случае, если их большое кол-во, то на практике
метод pull будет более надежным и эффективным, т.к. в этом случае можно настроить
агентов так, что-бы они обращались к серверу оркестрации не сразу всем скопом, а
с временным смещением, что позволит серверу оркестрации обслуживать большее кол-во
конечных уст-в.

## Задача 3

Установить на личный компьютер:

- VirtualBox
- Vagrant
- Ansible

*Приложить вывод команд установленных версий каждой из программ, оформленный в markdown.*

```bash
root@new0ne-dp:/home/new0ne# vboxmanage -v
6.1.32_Ubuntur149290

root@new0ne-dp:/home/new0ne# vagrant -v
Vagrant 2.2.19

root@new0ne-dp:/home/new0ne# ansible --version
ansible 2.9.6
  config file = /etc/ansible/ansible.cfg
  configured module search path = ['/root/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3/dist-packages/ansible
  executable location = /usr/bin/ansible
  python version = 3.8.10 (default, Mar 15 2022, 12:22:08) [GCC 9.4.0]

```

## Задача 4 (*)

Воспроизвести практическую часть лекции самостоятельно.

- Создать виртуальную машину.
- Зайти внутрь ВМ, убедиться, что Docker установлен с помощью команды
```
vagrant@server1:~$ docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
vagrant@server1:~$ docker -v
Docker version 20.10.14, build a224086

```