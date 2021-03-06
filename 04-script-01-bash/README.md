# Домашнее задание к занятию "4.1. Командная оболочка Bash: Практические навыки"

## Обязательная задача 1

Есть скрипт:
```bash
a=1
b=2 
c=a+b
d=$a+$b
e=$(($a+$b))
```

Какие значения переменным c,d,e будут присвоены? Почему?

| Переменная  | Значение | Обоснование                                                                      |
| ------------- |----------|----------------------------------------------------------------------------------|
| `c`  | a+b      | В переменную $c мы записали новую строку 'a+b'                                   |
| `d`  | 1+2      | Сложили 2 неявно объявленные переменные(строки)                                  |
| `e`  | 3        | Произвели арифметическую операцию с переменными через конструкцию $(($var+$var)) |


## Обязательная задача 2
На нашем локальном сервере упал сервис и мы написали скрипт, который постоянно проверяет его доступность, записывая дату проверок до тех пор, пока сервис не станет доступным (после чего скрипт должен завершиться). В скрипте допущена ошибка, из-за которой выполнение не может завершиться, при этом место на Жёстком Диске постоянно уменьшается. Что необходимо сделать, чтобы его исправить:
```bash
while ((1==1)
do
	curl https://localhost:4757
	if (($? != 0))
	then
		date >> curl.log
	fi
done
```

### Ваш скрипт:
```bash
while ((1==1)
do
	curl https://localhost:4757
	if (($? != 0))
	then
		date >> curl.log
	else 
	return 0
	fi
done
```

## Обязательная задача 3
Необходимо написать скрипт, который проверяет доступность трёх IP: `192.168.0.1`, `173.194.222.113`, `87.250.250.242` по `80` порту и записывает результат в файл `log`. Проверять доступность необходимо пять раз для каждого узла.

### Ваш скрипт:
```bash
#!/usr/bin/env bash
ip_arr=("192.168.0.1" "173.194.222.113" "87.250.250.242")

i=0
for host in ${ip_arr[@]}
do
 ii=0
  while (($ii < 5))
  do
      curl http://${ip_arr[$i]}
       if (($? == 0 ))
        then
            echo "${ip_arr[$i]} works" >> check.log
        else
            echo "smth wrong with ${ip_arr[$i]} check this out" >> check.log
       fi
     ((ii++))
  done
 ((i++))
done
```

## Обязательная задача 4
Необходимо дописать скрипт из предыдущего задания так, чтобы он выполнялся до тех пор, пока один из узлов не окажется недоступным. Если любой из узлов недоступен - IP этого узла пишется в файл error, скрипт прерывается.

### Ваш скрипт:
```bash
#!/usr/bin/env bash
ip_arr=("192.168.0.1" "173.194.222.113" "87.250.250.242")

i=0
for host in ${ip_arr[@]}
do
 ii=0
  while (($ii < 5))
  do
      curl http://${ip_arr[$i]}
       if (($? == 0 ))
        then
            echo "${ip_arr[$i]} works" >> check.log
        else
            echo "smth wrong with ${ip_arr[$i]} check this out" >> error.log
            exit 1
       fi
     ((ii++))
  done
 ((i++))
done
```

## Дополнительное задание (со звездочкой*) - необязательно к выполнению

Мы хотим, чтобы у нас были красивые сообщения для коммитов в репозиторий. Для этого нужно написать локальный хук для git, который будет проверять, что сообщение в коммите содержит код текущего задания в квадратных скобках и количество символов в сообщении не превышает 30. Пример сообщения: \[04-script-01-bash\] сломал хук.

### Ваш скрипт:
```bash
#!/usr/bin/env bash
pattern="^\[[0-9]{2}-[a-z]{0,8}-[0-9]{2}-[a-z]{0,8}\]:\s.*"
check=$(grep -Eoh "$pattern" "$1")

if [[ $? == 0 ]] && [[ ${#check} -le 30 ]]
then
   echo "Commit message policy is OK"
    exit 0
  else
   echo "Commit message polisy is violated. Example: \"[01-test-01-test]: some text\" and no more then 30 chars."
    exit 1
fi
```