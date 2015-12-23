# -*- coding: utf-8 -*-
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

##
# privacy
# =======
#
#  For root and user:
#    - Installs .bashrc privacy configuration.
#    - Clears .bash_history and .viminfo files for all users and root
#    - Prevents vim history from being written
#    - Prevents locate / updatedb from indexing /home, /rw and bind mounts
#
# Execute:
#   qubesctl state.sls privacy all
##

{% macro update_userdirs(content, caller) -%}
  {%- set userdirs = salt['config.readdirs']('/home', abspath=True) -%}
  {%- do userdirs.append('/root') -%}
  {% if userdirs -%}
    {% for userdir in userdirs -%}
      {%- set user = salt['user.info'](salt['file.basename'](userdir)) -%}
      {% if user and userdir == user.home -%}
        {%- set filemode = 644 if user.name not in ['root'] else 640 -%}
        {%- do user.update({'filemode': filemode}) -%}

        {{ caller(user) }}

      {%- endif %}
    {%- endfor %}
  {%- endif %}
{%- endmacro %}

{%- call(user) update_userdirs('content') %}
bashrc-{{ user.name }}:
  file.replace:
    - name: {{ user.home }}/.bashrc
    - pattern: ^\s*HISTFILESIZE\s*=(.*)$
    - repl: HISTFILESIZE=0
    - append_if_not_found: True

{{ user.home }}/.bash_history:
  file.managed:
    - source: salt://privacy/files/bash_history
    - user: {{ user.uid }}
    - group: {{ user.gid }}
    - replace: True
    - file_mode: {{ user.filemode }}

vimrc-present-{{ user.name }}:
  file.managed:
    - name: {{ user.home }}/.vimrc
    - content: set viminfo=
    - replace: False
    - user: {{ user.uid }}
    - group: {{ user.gid }}
    - file_mode: {{ user.filemode }}

vimrc-{{ user.name }}:
  file.replace:
    - name: {{ user.home }}/.vimrc
    - pattern: ^\s*set\s*viminfo\s*=(.*)$
    - repl: set viminfo=
    - append_if_not_found: True
    - require:
      - file: vimrc-present-{{ user.name }}

vimrc-absent-{{ user.name }}:
  file.absent:
    - name: {{ user.home }}/.viminfo
    - require:
      - file: vimrc-{{ user.name }}
{% endcall %}

# === updatedb =================================================================
updatedb_augeas:
  pkg.installed:
    - names: 
      - python-augeas
  
  file.managed:
    - name:  /usr/share/augeas/lenses/updatedb.aug
    - source: salt://privacy/files/updatedb.aug
    - replace: False
    - user: root
    - group: root
    - mode: 644
    - makedirs: True
    - require:
      - pkg: updatedb_augeas
  
updatedb-bind_mounts:
  augeas.change:
    - lens: UpdateDB.lns
    - context: /files/etc/updatedb.conf
    - changes:
      - set PRUNE_BIND_MOUNTS yes
    - require:
      - pkg: updatedb_augeas

updatedb_home:
  augeas.change:
    - lens: UpdateDB.lns
    - context: /files/etc/updatedb.conf
    - changes:
      - set PRUNEPATHS/entry[last()+1] /home
    - unless: grep "PRUNEPATHS" /etc/updatedb.conf | grep '/home'
    - require:
      - pkg: updatedb_augeas

updatedb_rw:
  augeas.change:
    - lens: UpdateDB.lns
    - context: /files/etc/updatedb.conf
    - changes:
      - set PRUNEPATHS/entry[last()+1] /rw
    - unless: grep "PRUNEPATHS" /etc/updatedb.conf | grep '/rw'
    - require:
      - pkg: updatedb_augeas
