.. _ug_issues_example1:

ANSIBLE_CALLBACK_PLUGINS in envvars is not working. #219
--------------------------------------------------------

* Updated: July,9 2020
* Status: `Closed without fix <https://github.com/ansible/ansible-runner/issues/219#issuecomment-525795580>`_ Aug 2019


It's not possible to change Ansible callback
plugin. ``ansible-runner`` ignores environment variable
``ANSIBLE_STDOUT_CALLBACK`` and uses hardwired callback plugins (2,4). See
`runner_config.py
<https://github.com/ansible/ansible-runner/blob/devel/ansible_runner/runner_config.py#L199>`_

.. code-block:: python
   :linenos:
   :emphasize-lines: 2,4

   if 'AD_HOC_COMMAND_ID' in self.env:
       self.env['ANSIBLE_STDOUT_CALLBACK'] = 'minimal'
   else:
       self.env['ANSIBLE_STDOUT_CALLBACK'] = 'awx_display'


To test it, set the environment variables of the project *test_02*

.. code-block:: sh
   :emphasize-lines: 1

   shell> cat ~/.ansible/runner/test_02/env/envvars
   ---
   MY_TEST_VAR: my-test-var
   ANSIBLE_STDOUT_CALLBACK: actionable


Prepare a playbook

.. code-block:: yaml
   :emphasize-lines: 1

   shell> cat pb-02.yml 
   - hosts: test_02
     remote_user: admin
     gather_facts: true
     tasks:
       - debug:
           msg: "HOME [{{ lookup('env','HOME') }}]"
       - debug:
           msg: "MY_TEST_VAR [{{ lookup('env','MY_TEST_VAR') }}]"
       - debug:
           msg: "ANSIBLE_STDOUT_CALLBACK [{{ lookup('env','ANSIBLE_STDOUT_CALLBACK') }}]"

and test it

.. code-block:: sh
   :emphasize-lines: 1,4,18

   shell> ansible-runner --version
   1.4.6

   shell> ansible-runner run ~/.ansible/runner/test_02 -p pb-02.yml

   TASK [debug] *******************************************************************
   ok: [test_02] => {
       "msg": "HOME [/home/admin]"
   }
   
   TASK [debug] *******************************************************************
   ok: [test_02] => {
       "msg": "MY_TEST_VAR [my-test-var]"
   }
   
   TASK [debug] *******************************************************************
   ok: [test_02] => {
       "msg": "ANSIBLE_STDOUT_CALLBACK [awx_display]"
   }
