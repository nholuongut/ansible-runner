.. _ug_usage_example2_events:

Example 2: List artifacts' job events
-------------------------------------

.. contents::
   :local:


Test negative result
^^^^^^^^^^^^^^^^^^^^

Let's modify the playbook so that it will fail. For example (8)

.. code-block:: yaml
   :linenos:
   :emphasize-lines: 1

   shell> cat ~/.ansible/runner/test_02/project/pb-01.yml
   - hosts: test_02
     remote_user: admin
     gather_facts: no
     tasks:
       - debug:
           msg: TEST
       - command: /usr/bin/false

		     
Cron email on failure
^^^^^^^^^^^^^^^^^^^^^

Then the cron task in the example *Cron: Example 1* will fail and
*admin* will receive an email similar to this one

.. code-block:: sh
   :linenos:
   :emphasize-lines: 1

   Date: Wed,  8 Jul 2020 13:27:07 +0200 (CEST)
   From: Cron Daemon <root@cntrlr.example.com>
   To: admin@cntrlr.example.com
   Subject: Cron <admin@cntrlr> $HOME/bin/ansible-cron-test.bash

   [OK]  test_01 pb-01.yml PASSED
   [ERR] 2020-07-08 13:27:03 /home/admin/bin/arwrapper.bash

   PLAY [test_02] **************************************************************

   TASK [debug] ****************************************************************
   ok: [test_02] => {
       "msg": "TEST"
       }

   TASK [command] **********************************************************
   fatal: [test_02]: FAILED! =>
   {"changed": true,
    "cmd": ["/usr/bin/false"],
    "delta": "0:00:00.013809",
    "end": "2020-07-08 +13:26:32.197207",
    "msg": "non-zero return code",
    "rc": 1,
    "start": "2020-07-08 13:26:32.183398",
    "stderr": "",
    "stderr_lines": [],
    "stdout": "",
    "stdout_lines": []}

   PLAY RECAP **************************************************************
   test_02: ok=1 changed=0 unreachable=0 failed=1 skipped=0 rescued=0 ignored=0
   .........................................................................
   [OK]  test_03 pb-01.yml PASSED


Artifacts
^^^^^^^^^

Let's take look at the artifacts of the failed project

.. code-block:: sh
   :linenos:
   :emphasize-lines: 1

   shell> tree ~/.ansible/runner/test_02/artifacts/
   /home/admin/.ansible/runner/test_02/artifacts/
   └── 0428ede5-40c2-48f9-b33d-b9d1a64609af
       ├── command
       ├── fact_cache
       ├── job_events
       │   ├── 1-ff7d4af5-26bc-4d4c-8eac-6c75e547cb22.json
       │   ├── 2-5ce0c5a2-1f02-fda4-7a07-00000000001f.json
       │   ├── 3-5ce0c5a2-1f02-fda4-7a07-000000000021.json
       │   ├── 4-a1e17955-d452-424d-a1c1-bb4b387fd180.json
       │   ├── 5-97175f4b-9c82-4160-a17c-32a3e6d0c3ff.json
       │   ├── 6-5ce0c5a2-1f02-fda4-7a07-000000000022.json
       │   ├── 7-e1a3349e-199f-4ad7-969c-8680bbb1bac0.json
       │   ├── 8-bb64ec8e-d1b0-4114-9093-9bbd6807b293.json
       │   └── 9-72588652-8937-4eda-9aa7-b6bc443e4aa9.json
       ├── rc
       ├── status
       └── stdout

   3 directories, 13 files


Playbook
^^^^^^^^

Prepare a playbook to help with the analysis of the artifacts. For
example, the playbook below will use `Ansible library
<https://github.com/vbotka/ansible-lib>`_ task `al_runner_events.yml
<https://github.com/vbotka/ansible-lib/blob/master/tasks/al_runner_events.yml>`_ (13)
and display selected attributes (18) from the *job events*. Feel free
to modify *msg* (18) and display other attributes

.. code-block:: yaml
   :linenos:
   :emphasize-lines: 1

   shell> cat ar-events.yml
   - hosts: localhost
     gather_facts: false
   
     vars:
       my_home: "{{ lookup('env','HOME') }}"
       al_runner_events_dir: "{{ my_home ~
       '/.ansible/runner/test_02/artifacts/0428ede5-40c2-48f9-b33d-b9d1a64609af/job_events' }}"
   
     tasks:
       - include_role:
           name: vbotka.ansible_lib
           tasks_from: al_runner_events
           apply:
             tags: always
         tags: always
       - debug:
           msg: "{{ item.counter }} {{ item.event }}"
         loop: "{{ al_runner_events_list|sort(attribute='counter') }}"
         loop_control:
           label: "{{ item.counter }}"
         tags: events
       - debug:
           msg: "{{ item.stdout }}"
         loop: "{{ al_runner_events_list|sort(attribute='counter') }}"
         loop_control:
           label: "{{ item.counter }}"
         when: item.event == 'runner_on_failed'
         tags: failed

.. seealso::
   * `Examples of ansible-runner <https://github.com/vbotka/ansible-examples/tree/master/examples/example-126>`_


Events
^^^^^^

The play below gives the list of the events

.. code-block:: yaml
   :emphasize-lines: 1

   shell> ansible-playbook ar-events.yml -t events | grep msg\":
       "msg": "1 playbook_on_start"
       "msg": "2 playbook_on_play_start"
       "msg": "3 playbook_on_task_start"
       "msg": "4 runner_on_start"
       "msg": "5 runner_on_ok"
       "msg": "6 playbook_on_task_start"
       "msg": "7 runner_on_start"
       "msg": "8 runner_on_failed"
       "msg": "9 playbook_on_stats"


Failed event(s)
^^^^^^^^^^^^^^^

The next play displays the details of the failed event(s)

.. code-block:: yaml
   :emphasize-lines: 1

   shell> echo -e $(ansible-playbook ar-events.yml -t failed | grep msg\":)
       "msg": "fatal: [test_02]: FAILED! =>{
       \"changed\": true,
       \"cmd\": [\"/usr/bin/false\"],
       \"delta\": \"0:00:00.014716\",
       \"end\": \"2020-07-08 17:05:56.104764\",
       \"msg\": \"non-zero return code\",
       \"rc\": 1,
       \"start\": \"2020-07-08 17:05:56.090048\",
       \"stderr\": \"\",
       \"stderr_lines\": [],
       \"stdout\": \"\",
       \"stdout_lines\": []}"
