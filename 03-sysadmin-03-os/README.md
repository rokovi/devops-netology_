##### 1. Какой системный вызов делает команда `cd`? В прошлом ДЗ мы выяснили, что `cd` не является самостоятельной  программой, это `shell builtin`, поэтому запустить `strace` непосредственно на `cd` не получится. Тем не менее, вы можете запустить `strace` на `/bin/bash -c 'cd /tmp'`. В этом случае вы увидите полный список системных вызовов, которые делает сам `bash` при старте. Вам нужно найти тот единственный, который относится именно к `cd`.

###### Ответ: 
`chdir("/tmp")`

Смотрим man ситсемного вызова `man 2 chdir`
```
NAME
       chdir, fchdir - change working directory

SYNOPSIS
       #include <unistd.h>

       int chdir(const char *path);
       int fchdir(int fd);

   Feature Test Macro Requirements for glibc (see feature_test_macros(7)):

       fchdir():
           _XOPEN_SOURCE >= 500
               || /* Since glibc 2.12: */ _POSIX_C_SOURCE >= 200809L
               || /* Glibc up to and including 2.19: */ _BSD_SOURCE

DESCRIPTION
       chdir() changes the current working directory of the calling process
       to the directory specified in path.

       fchdir() is identical to chdir(); the only difference  is  that  the
       directory is given as an open file descriptor.

RETURN VALUE
       On  success,  zero is returned.  On error, -1 is returned, and errno
       is set appropriately.

```
##### 2. Попробуйте использовать команду `file` на объекты разных типов на файловой системе. Например:
    ```bash
    vagrant@netology1:~$ file /dev/tty
    /dev/tty: character special (5/0)
    vagrant@netology1:~$ file /dev/sda
    /dev/sda: block special (8/0)
    vagrant@netology1:~$ file /bin/bash
    /bin/bash: ELF 64-bit LSB shared object, x86-64
    ```
Используя `strace` выясните, где находится база данных `file` на основании которой она делает свои догадки.
###### Ответ: 

Команда `file` берет данные из бд `/usr/share/misc/magic.mgc`, котороая является симлинком `</usr/lib/file/magic.mgc`

На примере трассировки `/dev/tty`:

```bash
root@vagrant:/tmp/test# strace -y -e openat file /bin/bash
openat(AT_FDCWD, "/etc/ld.so.cache", O_RDONLY|O_CLOEXEC) = 3</etc/ld.so.cache>
openat(AT_FDCWD, "/lib/x86_64-linux-gnu/libmagic.so.1", O_RDONLY|O_CLOEXEC) = 3</usr/lib/x86_64-linux-gnu/libmagic.so.1.0.0>
openat(AT_FDCWD, "/lib/x86_64-linux-gnu/libc.so.6", O_RDONLY|O_CLOEXEC) = 3</usr/lib/x86_64-linux-gnu/libc-2.31.so>
openat(AT_FDCWD, "/lib/x86_64-linux-gnu/liblzma.so.5", O_RDONLY|O_CLOEXEC) = 3</usr/lib/x86_64-linux-gnu/liblzma.so.5.2.4>
openat(AT_FDCWD, "/lib/x86_64-linux-gnu/libbz2.so.1.0", O_RDONLY|O_CLOEXEC) = 3</usr/lib/x86_64-linux-gnu/libbz2.so.1.0.4>
openat(AT_FDCWD, "/lib/x86_64-linux-gnu/libz.so.1", O_RDONLY|O_CLOEXEC) = 3</usr/lib/x86_64-linux-gnu/libz.so.1.2.11>
openat(AT_FDCWD, "/lib/x86_64-linux-gnu/libpthread.so.0", O_RDONLY|O_CLOEXEC) = 3</usr/lib/x86_64-linux-gnu/libpthread-2.31.so>
openat(AT_FDCWD, "/usr/lib/locale/locale-archive", O_RDONLY|O_CLOEXEC) = 3</usr/lib/locale/locale-archive>
openat(AT_FDCWD, "/etc/magic.mgc", O_RDONLY) = -1 ENOENT (No such file or directory)
openat(AT_FDCWD, "/etc/magic", O_RDONLY) = 3</etc/magic>
openat(AT_FDCWD, "/usr/share/misc/magic.mgc", O_RDONLY) = 3</usr/lib/file/magic.mgc>
openat(AT_FDCWD, "/usr/lib/x86_64-linux-gnu/gconv/gconv-modules.cache", O_RDONLY) = 3</usr/lib/x86_64-linux-gnu/gconv/gconv-modules.cache>
openat(AT_FDCWD, "/bin/bash", O_RDONLY|O_NONBLOCK) = 3</usr/bin/bash>
/bin/bash: ELF 64-bit LSB shared object, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, BuildID[sha1]=a6cb40078351e05121d46daa768e271846d5cc54, for GNU/Linux 3.2.0, stripped
+++ exited with 0 +++
root@vagrant:/tmp/test#

```

Также можно посмотреть в `man file`:
```
 The information iden‐
     tifying these files is read from /etc/magic and the compiled magic
     file /usr/share/misc/magic.mgc, or the files in the directory
     /usr/share/misc/magic if the compiled file does not exist.  In addi‐
     tion, if $HOME/.magic.mgc or $HOME/.magic exists, it will be used in
     preference to the system magic files.

```


##### 3. Предположим, приложение пишет лог в текстовый файл. Этот файл оказался удален (deleted в lsof), однако возможности сигналом сказать приложению переоткрыть файлы или просто перезапустить приложение – нет. Так как приложение продолжает писать в удаленный файл, место на диске постепенно заканчивается. Основываясь на знаниях о перенаправлении потоков предложите способ обнуления открытого удаленного файла (чтобы освободить место на файловой системе).
###### Ответ: 
Можно обнулить файл с помощью конструкции `echo > /proc/pid/fd/fd_number` или `truncate -s 0 /proc/pid/fd/fd_number`
##### 4. Занимают ли зомби-процессы какие-то ресурсы в ОС (CPU, RAM, IO)?
###### Ответ: 
Нет, т.к. дочерний процесс завершился, а родительский не смог обработать его код возврата(системный вызов `wait()`) 
##### 5. В iovisor BCC есть утилита `opensnoop`:
```bash
root@vagrant:~# dpkg -L bpfcc-tools | grep sbin/opensnoop
/usr/sbin/opensnoop-bpfcc
```
На какие файлы вы увидели вызовы группы `open` за первую секунду работы утилиты? Воспользуйтесь пакетом `bpfcc-tools` для Ubuntu 20.04. Дополнительные [сведения по установке](https://github.com/iovisor/bcc/blob/master/INSTALL.md).
###### Ответ: 
```bash
root@vagrant:/tmp# opensnoop-bpfcc
PID    COMM               FD ERR PATH
686    irqbalance          6   0 /proc/interrupts
686    irqbalance          6   0 /proc/stat
686    irqbalance          6   0 /proc/irq/20/smp_affinity
686    irqbalance          6   0 /proc/irq/0/smp_affinity
686    irqbalance          6   0 /proc/irq/1/smp_affinity
686    irqbalance          6   0 /proc/irq/8/smp_affinity
686    irqbalance          6   0 /proc/irq/12/smp_affinity
686    irqbalance          6   0 /proc/irq/14/smp_affinity
686    irqbalance          6   0 /proc/irq/15/smp_affinity
902    vminfo              6   0 /var/run/utmp
678    dbus-daemon        -1   2 /usr/local/share/dbus-1/system-services
678    dbus-daemon        45   0 /usr/share/dbus-1/system-services
678    dbus-daemon        -1   2 /lib/dbus-1/system-services
678    dbus-daemon        45   0 /var/lib/snapd/dbus-1/system-services/
902    vminfo              6   0 /var/run/utmp
```

##### 6. Какой системный вызов использует `uname -a`? Приведите цитату из man по этому системному вызову, где описывается альтернативное местоположение в `/proc`, где можно узнать версию ядра и релиз ОС.
###### Ответ:
`uname -a` использует истемный вызов `uname()`

Цитата из `man`:
```
Part   of   the   utsname   information   is   also  accessible  via
       /proc/sys/kernel/{ostype, hostname, osrelease, version, domainname}.
```
##### 7. Чем отличается последовательность команд через `;` и через `&&` в bash? Например:
    ```bash
    root@netology1:~# test -d /tmp/some_dir; echo Hi
    Hi
    root@netology1:~# test -d /tmp/some_dir && echo Hi
    root@netology1:~#
    ```
Есть ли смысл использовать в bash `&&`, если применить `set -e`?
###### Ответ:
`;`- команды выполняются последовательно:
```bash
root@vagrant:/tmp# echo 'true' ; echo 'false'
true
false
```
`&&` - команда2 выполняется в случае если команда1 вернула код возврата 0, т.е. выполнилась успешно:
```bash
root@vagrant:/tmp# echod 'true' && echo 'false'
bash: echod: command not found
```
`set -e` - смысл есть, т.к. при использваонии `set -e` работа shell не завершится даже если `&&` 
вернет отличный статус от `0`

Выдержка из `man bash`:
```
 -e      Exit immediately if a pipeline (which may consist  of
                      a  single simple command), a list, or a compound com‐
                      mand (see SHELL GRAMMAR above), exits with a non-zero
                      status.   The shell does not exit if the command that
                      fails is part of the command list immediately follow‐
                      ing  a  while or until keyword, part of the test fol‐
                      lowing the if or elif reserved  words,  part  of  any
                      command  executed  in a && or || list except the com‐
                      mand following the final && or ||, any command  in  a
                      pipeline  but  the  last,  or if the command's return
                      value is being inverted with !.  If a  compound  com‐
                      mand  other than a subshell returns a non-zero status
                      because a command failed while -e was being  ignored,
                      the  shell  does not exit.  A trap on ERR, if set, is
                      executed before the shell exits.  This option applies
                      to  the  shell environment and each subshell environ‐
                      ment separately (see  COMMAND  EXECUTION  ENVIRONMENT
                      above),  and  may cause subshells to exit before exe‐
                      cuting all the commands in the subshell.
```
##### 8. Из каких опций состоит режим bash `set -euxo pipefail` и почему его хорошо было бы использовать в сценариях?
###### Ответ:
`-e` - была рассмотрена выше.

`-u` - если переменная была не задана, то выдать сообщение об ошибке. При этом интерактивный shall не должен завершиться. 

`-x` - выводить команды и результат их выполнения.

`-o pipefail` - возвращает значение `|` последней(справа) команды которая вернула код возврата отличноый от `0`. 
Либо `0` в случае если все команды в `|` завершились успешно.

`set -euxo pipefail` - единственный кейс который приходит на ум - во время написания скрипта использовать 
данную конструкцию для отладки. 

##### 9. Используя `-o stat` для `ps`, определите, какой наиболее часто встречающийся статус у процессов в системе. В `man ps` ознакомьтесь (`/PROCESS STATE CODES`) что значат дополнительные к основной заглавной буквы статуса процессов. Его можно не учитывать при расчете (считать S, Ss или Ssl равнозначными).
###### Ответ:
Наиболее часто встречающийся статус процесса `S`