.. _ug_usage_example3_status:

Example 3: Handle custom status of playbook
-------------------------------------------

.. contents::
   :local:

Playbook
^^^^^^^^

Generate random success or failure of the script (9,15) and register
the results (10,16). Put the *rc* codes into the dictionary *my_rc*
(11,17). Put the the dictionary into the custom status of the playbook
(23).

.. code-block:: yaml
   :linenos:
   :emphasize-lines: 9-11,15-17,23

   shell> cat private6/project/playbook.yml
   - hosts:
       - test_01
       - test_02
       - test_03
     ignore_errors: true

     tasks:
       - shell: '[ "$(jot -r 1 0 100)" -gt "50" ] && true || false'
         register: result
       - set_fact:
           my_rc: "{{ my_rc|default({})|
                      combine({inventory_hostname:
                              {'script1': result.rc}}, recursive=True) }}"
       - shell: '[ "$(jot -r 1 0 100)" -gt "50" ] && true || false'
         register: result
       - set_fact:
           my_rc: "{{ my_rc|default({})|
                      combine({inventory_hostname:
                              {'script2': result.rc}}, recursive=True) }}"
       - set_stats:
           data:
             my_rc: "{{ my_rc }}"
           per_host: false


Enable custom status
^^^^^^^^^^^^^^^^^^^^
	   
.. code-block:: sh
   :linenos:
   :emphasize-lines: 2

   shell> cat private6/env/envvars
   ANSIBLE_SHOW_CUSTOM_STATS: true


Wrapper ansible-runner
^^^^^^^^^^^^^^^^^^^^^^

[`arwrapper.bash <https://github.com/vbotka/ansible-runner/blob/master/contrib/arwrapper.bash>`_]

.. literalinclude:: ../../contrib/arwrapper.bash
    :language: sh
    :linenos:
    :emphasize-lines: 42,44


Run the playbook and display the artifacts' directory
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Run the playbook with the wrapper command *runid* (1). Last line of
the output is the directory of the artifacts (59)

.. code-block:: sh
   :linenos:
   :emphasize-lines: 1,59

   shell> arwrapper.bash runid private6 playbook.yml
   2020-09-26 19:23:45 ./arwrapper.bash

   PLAY [test_01,test_02,test_03] *************************************************

   TASK [Gathering Facts] *********************************************************
   ok: [test_02]
   ok: [test_01]
   ok: [test_03]

   TASK [shell] *******************************************************************
   ...ignoring
   fatal: [test_01]: FAILED! => {"changed": true, "cmd": "[ \"$(jot -r 1 0 100)\" -gt \"50\" ] && true || false", "delta": "0:00:00.025406", "end": "2020-09-26 19:18:52.908024", "msg": "non-zero return code", "rc": 1, "start": "2020-09-26 19:18:52.882618", "stderr": "", "stderr_lines": [], "stdout": "", "stdout_lines": []}
   ...ignoring
   ...ignoring
   fatal: [test_02]: FAILED! => {"changed": true, "cmd": "[ \"$(jot -r 1 0 100)\" -gt \"50\" ] && true || false", "delta": "0:00:00.025532", "end": "2020-09-26 19:18:52.912931", "msg": "non-zero return code", "rc": 1, "start": "2020-09-26 19:18:52.887399", "stderr": "", "stderr_lines": [], "stdout": "", "stdout_lines": []}
   ...ignoring
   changed: [test_03]

   TASK [set_fact] ****************************************************************
   ok: [test_02]
   ok: [test_01]
   ok: [test_03]

   TASK [shell] *******************************************************************
   changed: [test_02]
   fatal: [test_01]: FAILED! => {"changed": true, "cmd": "[ \"$(jot -r 1 0 100)\" -gt \"50\" ] && true || false", "delta": "0:00:00.022179", "end": "2020-09-26 19:18:53.258569", "msg": "non-zero return code", "rc": 1, "start": "2020-09-26 19:18:53.236390", "stderr": "", "stderr_lines": [], "stdout": "", "stdout_lines": []}
   ...ignoring
   fatal: [test_03]: FAILED! => {"changed": true, "cmd": "[ \"$(jot -r 1 0 100)\" -gt \"50\" ] && true || false", "delta": "0:00:00.023787", "end": "2020-09-26 17:18:53.261070", "msg": "non-zero return code", "rc": 1, "start": "2020-09-26 17:18:53.237283", "stderr": "", "stderr_lines": [], "stdout": "", "stdout_lines": []}
   ...ignoring

   TASK [set_fact] ****************************************************************
   ok: [test_02]
   ok: [test_01]
   ok: [test_03]

   TASK [set_stats] ***************************************************************
   ok: [test_02]
   ok: [test_01]
   ok: [test_03]

   test_01: ok=6    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=2
   test_02: ok=6    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=1
   test_03: ok=6    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=1

   CUSTOM STATS: ******************************************************************


   PLAY RECAP *********************************************************************
   test_01: ok=6    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=2
   test_02: ok=6    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=1
   test_03: ok=6    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=1


   CUSTOM STATS: ******************************************************************

   RUN: { "my_rc": {  "test_01": {   "script1": 1,   "script2": 1  },  "test_02": {   "script1": 1,   "script2": 0  },  "test_03": {   "script1": 0,   "script2": 1  } }}

   9f27dbaf-45e2-44c7-bf2f-c84f081cbc17


Display the custom status from the artifacts
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: sh
   :linenos:
   :emphasize-lines: 1

   shell> arwrapper.bash custom private6 9f27dbaf-45e2-44c7-bf2f-c84f081cbc17

   { "my_rc": {  "test_01": {   "script1": 1,   "script2": 1  },  "test_02": {   "script1": 1,   "script2": 0  },  "test_03": {   "script1": 0,   "script2": 1  } }}



Select results of the first script
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: sh
   :linenos:
   :emphasize-lines: 1

   shell> arwrapper.bash custom private6 9f27dbaf-45e2-44c7-bf2f-c84f081cbc17 | jq .my_rc[].script1
   1
   1
   0
