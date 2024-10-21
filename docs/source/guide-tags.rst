****
Tags
****

The tags provide the user with a very useful tool to run selected
tasks of the role. To see what tags are available list the tags of the
role with the command

.. include:: tags-list.rst

For example, display the list of the variables and their values with
the tag ``ar_debug`` (when the debug is enabled ``ar_debug: true``)

.. code-block:: sh
   :emphasize-lines: 1

    shell> ansible-playbook ansible-runner.yml -t ar_debug

If the packages listed in ``ar_packages`` are available for the
distribution enable it ``ar_pkg_install: true`` and see if the packages
can be installed

.. code-block:: sh
   :emphasize-lines: 1

    shell> ansible-playbook ansible-runner.yml -t ar_packages --check

Install the package and exit the play

.. code-block:: sh
   :emphasize-lines: 1

    shell> ansible-playbook ansible-runner.yml -t ar_packages
