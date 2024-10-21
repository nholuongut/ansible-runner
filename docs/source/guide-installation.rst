************
Installation
************

The most convenient way how to install an Ansible role is to use Ansible Galaxy CLI
``ansible-galaxy``. The utility comes with the standard Ansible package and provides the user with a
simple interface to the Ansible Galaxy's services. For example, take a look at the current status of
the role ::

   shell> ansible-galaxy role info vbotka.ansible_runner

and install it ::

    shell> ansible-galaxy role install vbotka.ansible_runner

Install the library ::

    shell> ansible-galaxy role install vbotka.ansible_lib

Install the collection ::

    shell> ansible-galaxy collection install community.general

.. seealso::
   * To install specific versions from various sources see `Installing content <https://galaxy.ansible.com/docs/using/installing.html>`_.
   * Take a look at other roles ``shell> ansible-galaxy search --author=vbotka``
