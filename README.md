# bitpocket

## About

**bitpocket** is a small but smart script that does 2-way directory
synchronization. It uses _rsync_ to do efficient data transfer and tracks local
file creation/removal to avoid known rsync problem when doing 2-way syncing
with deletion.

## Installation

Download script and place it in a directory in your $PATH:

    $ curl -sL https://raw.github.com/sickill/bitpocket/master/bin/bitpocket > ~/bin/bitpocket
    $ chmod +x ~/bin/bitpocket


## Setting up master

Create empty directory on some host that will be the master copy of your files:

    $ ssh example.org
    $ mkdir ~/BitPocketMaster


## Setting up slaves

On each machine you want to synchronize initialize empty directory as your bitpocket:

    $ mkdir ~/BitPocket
    $ cd ~/BitPocket
    $ bitpocket init example.org:~/BitPocketMaster


### Manual sync

Now whenever you want to sync with master just run _bitpocket_ inside your
bitpocket directory:

    $ cd ~/BitPocket
    $ bitpocket


### Automatic sync with cron

Add following line to your crontab to run bitpocket as often as desired:

    */5 * * * * (cd ~/BitPocket; nice ~/bin/bitpocket >>.bitpocket/log)

Note that cron usually has very limited environment and your ssh keys with
passhrases won't work in cron jobs as ssh-agents/keyrings don't work there.
Thus it's preferable to generate passphrase-less ssh key for bitpocket
authentication:

    $ cd ~/BitPocket
    $ ssh-keygen -t rsa -C bitpocket-`hostname` -N '' -f .bitpocket/id_rsa

and uncomment line with `RSYNC_SSH` in _.bitpocket/config_ file.


## Looking at log

    $ cd ~/BitPocket
    $ bitpocket log


## Author

Marcin Kulik / <https://github.com/sickill> / <http://ku1ik.com/>
