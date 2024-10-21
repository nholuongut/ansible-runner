Example 1: Install ansible-runner in Ubuntu by pip for admin
------------------------------------------------------------

Create a playbook

.. code-block:: yaml
   :emphasize-lines: 1

   shell> cat ansible-runner.yml
   - hosts: test_01
     become: true
     roles:
       - vbotka.ansible_runner

Create variables in the file *host_vars/test_01/ansible-runner.yml*

.. code-block:: yaml
   :emphasize-lines: 1

    shell> cat host_vars/test_01/ansible-runner.yml
    ar_pkg_install: false
    ar_pip_install: true
    ar_debug: false
    ar_owner: admin
    ar_pip_extraagrs: "--user"

Install ansible-runner
    
.. code-block:: sh
   :emphasize-lines: 1

    shell> ansible-playbook ansible-runner.yml
    ...
    TASK [vbotka.ansible_runner : packages: Install Ansible Runner pip packages for admin]
    changed: [test_01] => (item={'name': 'ansible-runner'})

Show ansible-runner package was installed by pip for admin
    
.. code-block:: yaml
   :emphasize-lines: 1,4,7

   shell> whoami
   admin

   shell> pip list | grep ansible-runner
   ansible-runner               1.4.6

   shell> which ansible-runner
   /home/admin/.local/bin/ansible-runner
