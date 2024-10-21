.. _ug_usage_example1_cron:

Example 1: Run Ansible playbooks in cron
----------------------------------------

.. contents::
   :local:

Run ssh-agent
^^^^^^^^^^^^^

``ssh-agent`` is needed to provide the ssh connection plugin with the
password to the private key, when used. The script below is executed
by the command interpreter for login shells

.. code-block:: sh
   :linenos:
   :emphasize-lines: 1

   shell> cat /home/admin/.profile
   if [ -n "$BASH_VERSION" ]; then
       if [ -f "$HOME/.bashrc" ]; then
          . "$HOME/.bashrc"
       fi
       if [ -f "$HOME/.bashrc_ssh" ]; then
          . "$HOME/.bashrc_ssh"
       fi
   fi
   if [ -d "$HOME/bin" ] ; then
       PATH="$HOME/bin:$PATH"
   fi


and will start ``ssh-agent`` on login and prepare *SSH_ENV* (5)

.. code-block:: sh
   :linenos:
   :emphasize-lines: 1

   shell> cat /home/admin/.bashrc_ssh
   SSH_ENV="$HOME/.ssh/environment"
   function start_agent {
       echo "Initializing new SSH agent..."
       /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
       echo succeeded
       chmod 600 "${SSH_ENV}"
       . "${SSH_ENV}" > /dev/null
       /usr/bin/ssh-add;
   }
   if [ -f "${SSH_ENV}" ]; then
       . "${SSH_ENV}" > /dev/null
       #ps ${SSH_AGENT_PID} doesn't work under cywgin
       ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
           start_agent;
       }
   else
       start_agent;
   fi


Example of *.ssh/environment* created by *ssh-agent*

.. code-block:: sh
   :emphasize-lines: 1

   shell> cat /home/admin/.ssh/environment
   SSH_AUTH_SOCK=/tmp/ssh-8fUkZ7qOzVPs/agent.5214; export SSH_AUTH_SOCK;
   SSH_AGENT_PID=5216; export SSH_AGENT_PID;
   #echo Agent pid 5216;


.. seealso::
   * `Start ssh-agent on login - stackoverflow.com <https://stackoverflow.com/questions/18880024/start-ssh-agent-on-login>`_
   * `SSH Quick-Start Guide - FreeBSD handbook <https://www.freebsd.org/doc/en_US.ISO8859-1/articles/committers-guide/ssh.guide.html>`_
   * `Single Sign-On using SSH - ssh.com <https://www.ssh.com/ssh/agent>`_


Run gpg-agent
^^^^^^^^^^^^^

`Start gpg-agent
<https://www.gnupg.org/documentation/manuals/gnupg/Invoking-GPG_002dAGENT.html>`_
manually by running ``gpg``. ``gpg-agent`` is needed to provide
``gpg`` with the password to the private gpg key, when used. For
example, to sign or encrypt emails, or to configure user's passwords
with help of the ``passwordstore``. The configuration below enables
``gpg-agent`` also within a ssh session. In particular, *no-grab* (2)
allows cut&paste, *no-allow-external-cache* (3) disables any keyrings
and *pinentry-curses* (4) asks for the password in the terminal
instead of default *pinentry* asking in the remote (in the case of
ssh) desktop window. The time to live *ttl* (5,6) is set to 24
hours. This way, it's not necessary to re-enter the password when the
``cron``, which invokes the play with ``gpg-agent``, is run daily.

.. code-block:: sh
   :linenos:
   :emphasize-lines: 1

   shell> cat ~/.gnupg/gpg-agent.conf
   no-grab
   no-allow-external-cache
   pinentry-program /usr/bin/pinentry-curses
   default-cache-ttl 86400
   max-cache-ttl 86400

.. seealso::
   * `Ansible role linux_postinstall <https://galaxy.ansible.com/vbotka/linux_postinstall>`_ task `gpg.yml <https://github.com/vbotka/ansible-linux-postinstall/blob/master/tasks/gpg.yml>`_


Wrapper ansible-runner
^^^^^^^^^^^^^^^^^^^^^^
     
Wrapper of *ansible-runner* will source *.ssh/environment* (42) and run
the *playbook* from the *project* (44)

[`arwrapper.bash <https://github.com/vbotka/ansible-runner/blob/master/contrib/arwrapper.bash>`_]

.. literalinclude:: ../../contrib/arwrapper.bash
    :language: sh
    :linenos:
    :emphasize-lines: 42,44

Command for cron
^^^^^^^^^^^^^^^^

The script below will use *arwrapper.bash* (5) to run the playbook
*pb-01.yml* in the projects *test_01, test_02,* and *test_03*
(11-13). If the command (18) succeeds the script will print *[OK]*
report (23). If you don't want to receive email on success remove this
line. Optionally enable/disable the cleaning of the artifacts (24).

.. code-block:: sh
   :linenos:
   :emphasize-lines: 1

   shell> cat /home/admin/bin/ansible-cron-test.bash
   #!/bin/bash

   cmd=$HOME/bin/arwrapper.bash
   subcmd=${1:-run}
   rc=0

   typeset -A projects
   projects=(
       [test_01]="pb-01.yml"
       [test_02]="pb-01.yml"
       [test_03]="pb-01.yml"
   )

   for project in "${!projects[@]}"; do
       for playbook in ${projects[$project]}; do
           out=$("$cmd" "$subcmd" "$project" "$playbook" 2>&1)
           if [ "$?" -eq "0" ]; then
               if [ "$subcmd" = "test" ]; then
                   printf '%s\n' "[DRY] $out"
               fi
               printf '%s\n' "[OK] "$project" "$playbook" PASSED"
               $cmd clean $project
           else
               printf '%s\n' "[ERR] $out"
               rc=1
           fi
       done
    done
    exit $rc


Crontab
^^^^^^^
   
Schedule the script in *cron*

.. code-block:: sh
   :emphasize-lines: 1,3

   shell> whoami
   admin
   cntrlr> crontab -l
   MAILTO=admin
   #Ansible: Ansible runner daily test
   50 20 * * * $HOME/bin/ansible-cron-test.bash

.. seealso::
   * Ansible role's task `FreeBSD postinstall cron.yml <https://github.com/vbotka/ansible-freebsd-postinstall/blob/master/tasks/cron.yml>`_
   * Ansible role's task `Linux postinstall cron.yml <https://github.com/vbotka/ansible-linux-postinstall/blob/master/tasks/cron.yml>`_


Email sent by cron
^^^^^^^^^^^^^^^^^^

In our case the */etc/aliases* redirect the emails for *root* to the
user *admin*. Cron will report the result of the scpript
*ansible-cron-test.bash*. If you want to receive email on a failure only
remove the *[OK]* report from the script and optionally clean the
*artifacts*. The *artifacts* will be available for a review if the
script fails
      
.. code-block:: sh
   :emphasize-lines: 1

   Date: Tue,  7 Jul 2020 20:50:06 +0200 (CEST)
   From: Cron Daemon <root@cntrlr.example.com>
   To: admin@cntrlr.example.com
   Subject: Cron <admin@cntrlr> $HOME/bin/ansible-cron-test.bash

   [OK]  test_01 pb-01.yml PASSED
   [OK]  test_02 pb-01.yml PASSED
   [OK]  test_03 pb-01.yml PASSED


Project
^^^^^^^

Example of the project's directory without the artifacts. The
artifacts will be created by *ansible-runner*

.. code-block:: sh
   :emphasize-lines: 1

   shell> tree /home/admin/.ansible/runner/test_01
   /home/admin/.ansible/runner/test_01
   ├── env
   ├── inventory
   │   └── hosts
   └── project
       ├── ansible.cfg
       ├── group_vars
       ├── host_vars
       └── pb-01.yml


.. note:: It's necesary to provide *ansible-playbook* with the *vault
   password* if any data were encrypted. Use `env/cmdline
   <https://ansible-runner.readthedocs.io/en/latest/intro.html#env-cmdline>`_. For
   example

.. code-block:: sh
   :emphasize-lines: 1

   shell> cat /home/admin/.ansible/runner/test_01/env/cmdline
   --vault-password-file $HOME/.vault-psswd

.. seealso::
   * `Runner Input Directory Hierarchy <https://ansible-runner.readthedocs.io/en/latest/intro.html#runner-input-directory-hierarchy>`_
   * Example playbook how to create projects `pb_create_runner_private.yml <https://github.com/vbotka/ansible-ansible/blob/master/contrib/workbench/pb_create_runner_private.yml>`_


Playbook
^^^^^^^^

Example of a playbook used in the test

.. code-block:: sh
   :emphasize-lines: 1

   shell> cat /home/admin/.ansible/runner/test_01/project/pb-01.yml
   - hosts: test_01
     remote_user: admin
     gather_facts: no
     tasks:
       - debug:
           msg: TEST


Artifacts
^^^^^^^^^

Example of the project's artifacts

.. code-block:: sh
   :emphasize-lines: 1

   shell> tree /home/admin/.ansible/runner/test_01/artifacts/
   /home/admin/.ansible/runner/test_01/artifacts
   └── aaa5d36e-e8d4-432a-ab52-b69062c85311
       ├── command
       ├── fact_cache
       ├── job_events
       │   ├── 1-2b5c9412-f0c4-45dc-a425-5c8c29e37ec0.json
       │   ├── 2-5ce0c5a2-1f02-cdab-8869-00000000001f.json
       │   ├── 3-5ce0c5a2-1f02-cdab-8869-000000000021.json
       │   ├── 4-28749e27-409a-46c4-9551-7ce80c02be83.json
       │   ├── 5-997d90c1-6357-45c6-8df9-437c2940c74e.json
       │   └── 6-6e41cf27-8c1e-4266-9ffb-8a54375bd4cc.json
       ├── rc
       ├── status
       └── stdout


.. seealso::
   * `Runner Artifacts Directory Hierarchy <https://ansible-runner.readthedocs.io/en/latest/intro.html#runner-artifacts-directory-hierarchy>`_
   * `ansible_lib: al_runner_events <https://github.com/vbotka/ansible-lib/blob/master/tasks/al_runner_events.yml>`_
