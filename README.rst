===============
Privacy Formula
===============

Installs some privacy related configurations for all users and root user.

    - Updates `~/.bashrc` with `HISTFILESIZE=0` to prevent .bash_history file
      from being written to.

    - Updates `~/.vimrc` to prevent vim history from being written to
      `~/.viminfo`.
    
    - Clears `~/.bash_history` and and removes `~/.viminfo`

    - Updates `/etc/updatedb.conf` to prevent `locate` / `updatedb` from
      indexing `/home/**`, `/rw/**` and bind mounts

Files updated for /root and /home/user:

   .bashrc
   .vimrc
   .bash_history (cleared)
   .viminfo (removed)

Other files updates:

    /etc/updatedb.conf

Available states
================

.. contents::
    :local:

``privacy``
------------
