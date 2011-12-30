# bitpocket

## About

**bitpocket** is a small but smart script that does 2-way directory
synchronization. It uses _rsync_ to do efficient data transfer and tracks local
file creation/removal to avoid known rsync problem when doing 2-way syncing
with deletion.

## Installation

Clone repository and symlink `bitpocket` bin to sth in your `$PATH`:

    $ git clone git://github.com/sickill/bitpocket.git
    $ ln -s `pwd`/bitpocket/bin/bitpocket ~/bin/bitpocket

Or download script and place it in a directory in your `$PATH`:

    $ curl -sL https://raw.github.com/sickill/bitpocket/master/bin/bitpocket > ~/bin/bitpocket
    $ chmod +x ~/bin/bitpocket


## Setting up master

Create empty directory on some host that will be the master copy of your files:

    $ ssh user@example.org
    $ mkdir ~/BitPocketMaster


## Setting up slaves

On each machine you want to synchronize initialize empty directory as your bitpocket:

    $ mkdir ~/BitPocket
    $ cd ~/BitPocket
    $ bitpocket init user@example.org:~/BitPocketMaster


### Manual sync

Now whenever you want to sync with master just run _bitpocket sync_ inside your
bitpocket directory:

    $ cd ~/BitPocket
    $ bitpocket sync


### Automatic sync with cron

Add following line to your crontab to synchronize every 5 minutes:

    */5 * * * * cd ~/BitPocket && nice ~/bin/bitpocket cron

Note that cron usually has very limited environment and your ssh keys with
passhrases won't work in cron jobs as ssh-agents/keyrings don't work there.
Thus it's preferable to generate passphrase-less ssh key for bitpocket
authentication:

    $ cd ~/BitPocket
    $ ssh-keygen -t rsa -C bitpocket-`hostname` -N '' -f .bitpocket/id_rsa
    $ ssh-copy-id -i .bitpocket/id_rsa user@example.org

and uncomment line with `RSYNC_SSH` in _.bitpocket/config_ file.


### Slow sync callbacks

When syncing takes more than 10 seconds (SLOW\_SYNC\_TIME setting) bitpocket
can fire off user provided command in background. This can be usefull to notify
user about long sync happening, preventing him from turning off the machine
during sync etc.

There are 3 settings that can be enabled in _.bitpocket/config_ file:

    # SLOW_SYNC_TIME=10
    # SLOW_SYNC_START_CMD="notify-send 'BitPocket sync in progress...'"
    # SLOW_SYNC_STOP_CMD="notify-send 'BitPocket sync finished'"

Just uncomment them and change at will.

You can show tray icon during long sync with
[traytor](https://github.com/sickill/traytor) and following settings:

    SLOW_SYNC_START_CMD='~/bin/traytor -t "BitPocket syncing..." -c "xdg-open ." .bitpocket/icons & echo $! >.bitpocket/traytor.pid'
    SLOW_SYNC_STOP_CMD='kill `cat .bitpocket/traytor.pid`'

## Displaying logs

    $ cd ~/BitPocket
    $ bitpocket log


## Author

Marcin Kulik / <https://github.com/sickill> / <http://ku1ik.com/>
