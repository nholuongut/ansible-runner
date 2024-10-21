.. code-block:: bash
   :emphasize-lines: 1,6-7

   shell> ansible-playbook ansible-runner.yml --list-tags
   
   playbook: ansible-runner.yml

   play #1 (srv.example.com): srv.example.com TAGS: []
      TASK TAGS: [always, ar_config, ar_debug, ar_links, ar_packages, ar_pip,
      ar_sanity, ar_vars]
