# Домашнее задание к занятию "3.7. Компьютерные сети, лекция 2"

#####  1. Проверьте список доступных сетевых интерфейсов на вашем компьютере. Какие команды есть для этого в Linux и в Windows?
###### Ответ:
Linux: **ip**
```bash
root@vagrant:~# ip -c a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:b1:28:5d brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic eth0
       valid_lft 58082sec preferred_lft 58082sec
    inet6 fe80::a00:27ff:feb1:285d/64 scope link
       valid_lft forever preferred_lft forever
```
Windows: **ipconfig**

```bat
C:\Users\someone>ipconfig

Настройка протокола IP для Windows


Адаптер Ethernet LAN:

   Состояние среды. . . . . . . . : Среда передачи недоступна.
   DNS-суффикс подключения . . . . . :

Адаптер Ethernet Подключение по локальной сети* 13:

   Состояние среды. . . . . . . . : Среда передачи недоступна.
   DNS-суффикс подключения . . . . . :

Адаптер Ethernet VirtualBox Host-Only Network:

   DNS-суффикс подключения . . . . . :
   IPv4-адрес. . . . . . . . . . . . : 192.168.56.1
   Маска подсети . . . . . . . . . . : 255.255.255.0
   Основной шлюз. . . . . . . . . :

Адаптер беспроводной локальной сети Подключение по локальной сети* 1:

   Состояние среды. . . . . . . . : Среда передачи недоступна.
   DNS-суффикс подключения . . . . . :

Адаптер беспроводной локальной сети Подключение по локальной сети* 9:

   Состояние среды. . . . . . . . : Среда передачи недоступна.
   DNS-суффикс подключения . . . . . :

Адаптер беспроводной локальной сети WLAN:

   DNS-суффикс подключения . . . . . :
   IPv4-адрес. . . . . . . . . . . . : 192.168.1.159
   Маска подсети . . . . . . . . . . : 255.255.255.0
   Основной шлюз. . . . . . . . . : 192.168.1.1
```
##### 2. Какой протокол используется для распознавания соседа по сетевому интерфейсу? Какой пакет и команды есть в Linux для этого?
###### Ответ:
На данный момент широко распространены 2 основных протокола:
 - CDP - проприетарный протокол Cisco.
 - LLDP - opensource.

В Linux используется пакет `lldpd`:
- `lldpctl` - выводит подробную информацию о соседе
```bash
root@vagrant:~# ip -c -br link
lo               UNKNOWN        00:00:00:00:00:00 <LOOPBACK,UP,LOWER_UP>
eth0             UP             08:00:27:b1:28:5d <BROADCAST,MULTICAST,UP,LOWER_UP>
root@vagrant:~# lldpctl
-------------------------------------------------------------------------------
LLDP neighbors:
-------------------------------------------------------------------------------
root@vagrant:~# lldpctl eth0
-------------------------------------------------------------------------------
LLDP neighbors:
-------------------------------------------------------------------------------
```
- `lldpcli` - интерактивный режим работы(конфигурация, настройка), аналогично как на сетевом оборудовании.
```bash
root@vagrant:~# lldpcli
[lldpcli] #
-- Help
       show  Show running system information
      watch  Monitor neighbor changes
     update  Update information and send LLDPU on all ports
  configure  Change system settings
unconfigure  Unconfigure system settings
       help  Get help on a possible command
      pause  Pause lldpd operations
     resume  Resume lldpd operations
       exit  Exit interpreter

[lldpcli] #
```
##### 3. Какая технология используется для разделения L2 коммутатора на несколько виртуальных сетей? Какой пакет и команды есть в Linux для этого? Приведите пример конфига.
###### Ответ:
Для разделения на несколько виртуальных сетей используется технология ***VLAN***.

В Linux используется пакет `vlan`.

После установки пакета `vlan` необходимо проверить утсановлен ли модуль `8021q` 
и звгрузить его в случае отсутствия:
```bash
root@vagrant:~# lsmod | grep 8021q
root@vagrant:~# modprobe 8021q
root@vagrant:~# lsmod | grep 8021q
8021q                  32768  0
garp                   16384  1 8021q
mrp                    20480  1 8021q
```

Vlan в Linux настраивается черех пакет `ip(route2)`

Например: 
```bash
#Создаем vlan 100
sudo ip link add link eth0 name eth0.100 type vlan id 100

#Назначаем адресс на вновь созданный vlan
sudo ip addr add 192.168.1.1/24 dev eth0.100

#Включаем интерфейс
sudo ip link set up eth0.100
```
Для того чтобы настройки были перманентными:

- Добавим модуль в автозагрузку:

`sudo su -c 'echo "8021q" >> /etc/modules'`
- Создадим файл с найтройками интрефейса  `/etc/network/interfaces`:
```bash
auto eth0.100
iface eth0.100 inet static
    address 192.168.1.1
    netmask 255.255.255.0
    vlan-raw-device eth0
```
##### 4. Какие типы агрегации интерфейсов есть в Linux? Какие опции есть для балансировки нагрузки? Приведите пример конфига.
###### Ответ:

Типы агрегации можно посмотреть [тут](https://www.kernel.org/doc/Documentation/networking/bonding.txt)

Режимы работы(типы агрегации):
- `balance-rr` - Передавать пакеты последовательно через доступные интерфейсы
- `active-backup` - 1 интерфейс активный, другой пассивный(переключение в случае сбоя)
- `balance-xor` - по умолчанию: XOR между mac-адресом источника и mac-адресом назначения.
Алтернативные политики задаются через опцию `xmit_hash_policy`
- `broadcast` - Передать данные во все интерфейсы
- `802.3ad` - классический LACP к которому также применятеся `xmit_hash_policy` 
- (необходима поддержка с другой стороны)
- `balance-tlb` - адаптивная передача с балансировкой (не требует поддержки с другой стороны)
- `balance-alb` - тоже что и `balance-tlb`плюс балансировка для входящего трафика (не требует поддержки с другой стороны)

Опции балансировки нагрузки(xmit_hash_policy):

- layer2 - XOR mac-адреса и типа пакета из поля `type ID` для генерации hash'a
Отправляет весь трафик конкретного хоста через один и тот же порт.
- layer2+3 - Использует для генерации hash'a как mac-адреса так и IP.
- layer3+4 - Использует IP адреса и протоколы 4 уровня для генерации hash'a.
- encap2+3 - Работает также как и `layer2+3`но опирается на `skb_flow_dissect`
что-бы получить заголовок и тип инкапсуляции (GRE, L2TP, VLAN )
- encap3+4 - Работает также как и `layer3+4` но опирается на `skb_flow_dissect`
что-бы получить заголовок и тип инкапсуляции (GRE, L2TP, VLAN )

Для настройки можно воспользоваться пакетом `iproute2` и загрузить модуль:
```bash
$ modeprob bonding
$ sudo ip link add bond0 type bond mode 802.3ad
$ sudo ip link set eth0 master bond0
$ sudo ip link set eth1 master bond0
```
Для персистентности добвим:

- Модуль в автозагрузку:


`sudo su -c 'echo "bonding" >> /etc/modules'`
- Конфигурацию интерфейса в: `/etc/network/interfaces`:
```bash
auto bond0
iface bond0 inet static
	address 192.168.1.1
	netmask 255.255.255.0	
	gateway 192.168.1.254
	dns-nameservers 192.168.1.254 8.8.8.8
	dns-search domain.local
		slaves eth0 eth1
		bond_mode 4
		lacp_rate=fast 
		xmit_hash_policy=layer2+3
		bond-miimon 100
		bond_downdelay 200
		bond_updelay 200

```

##### 5. Сколько IP адресов в сети с маской /29 ? Сколько /29 подсетей можно получить из сети с маской /24. Приведите несколько примеров /29 подсетей внутри сети 10.10.10.0/24.
###### Ответ:
- /29 = 8 - 2 = 6 адресов - 2 адреса, 1 на адрес сети и 1 на широковещательный адрес.
- В /24 маске мржно получить 32 подести /29
- 10.10.10.0/29, 10.10.10.8/29, 10.10.10.16/29 ... 10.10.10.248/29
##### 6. Задача: вас попросили организовать стык между 2-мя организациями. Диапазоны 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16 уже заняты. Из какой подсети допустимо взять частные IP адреса? Маску выберите из расчета максимум 40-50 хостов внутри подсети.
###### Ответ:
Можно взять адреса из диапозона 100.64.0.0/10 - выделенный пул для CGNAT который также является частным,
т.е. не маршрутизируется в сети интернет.
- 100.64.0.0/26 - Сеть А - по 64 -2 = 62 адреса на подсеть
- 100.64.0.64/26 - Сеть В - по 64 -2 = 62 адреса на подсеть
##### 7. Как проверить ARP таблицу в Linux, Windows? Как очистить ARP кеш полностью? Как из ARP таблицы удалить только один нужный IP?
###### Ответ:
 - Linux:
```bash
root@vagrant:~# ip -c ne
10.0.2.2 dev eth0 lladdr 52:54:00:12:35:02 REACHABLE
10.0.2.3 dev eth0 lladdr 52:54:00:12:35:03 STALE
root@vagrant:~# ip ne flush all
root@vagrant:~# ip ne del dev eth0 10.0.2.2
```
 - Windows:
```bat
C:\Users\someone>arp -a


Интерфейс: 192.168.1.159 --- 0x15
  адрес в Интернете      Физический адрес      Тип
  192.168.1.1           e0-60-66-f2-07-24     динамический
  224.0.0.22            01-00-5e-00-00-16     статический
  232.44.44.233         01-00-5e-2c-2c-e9     статический
  239.255.255.250       01-00-5e-7f-ff-fa     статический
  255.255.255.255       ff-ff-ff-ff-ff-ff     статический

C:\Users\someone>netsh interface IP delete arpcache
C:\Users\someone>arp -d 192.168.1.1
```