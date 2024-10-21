Example 2: Install ansible-runner in FreeBSD from port
------------------------------------------------------

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
    ar_pkg_install: true
    ar_pip_install: false
    ar_debug: false
    freebsd_install_method: ports
    freebsd_use_packages: true

Install ansible-runner
    
.. code-block:: sh
   :emphasize-lines: 1

    shell> ansible-playbook ansible-runner.yml
    ...
    TASK [vbotka.ansible_runner : packages: Install Ansible Runner ports FreeBSD]
    changed: [test_01] => (item={'name': 'sysutils/py-ansible-runner'})

Show ansible-runner package was installed
    
.. code-block:: yaml
   :emphasize-lines: 1,4,8

   shell> whoami
   admin

   shell> pkg info | grep ansible-runner
   py27-ansible-runner-1.3.3      Extensible embeddable ansible job runner
   py36-ansible-runner-1.3.3      Extensible embeddable ansible job runner
   
   shell> which ansible-runner
   /usr/local/bin/ansible-runner
