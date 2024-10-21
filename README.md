# ansible runner

![](https://i.imgur.com/waxVImv.png)
### [View all Roadmaps](https://github.com/nholuongut/all-roadmaps) &nbsp;&middot;&nbsp; [Best Practices](https://github.com/nholuongut/all-roadmaps/blob/main/public/best-practices/) &nbsp;&middot;&nbsp; [Questions](https://www.linkedin.com/in/nholuong/)
<br/>

## Supported platforms

This role has been developed and tested with
* [Ubuntu Supported Releases](http://releases.ubuntu.com/)
* [FreeBSD Supported Production Releases](https://www.freebsd.org/releases/)

This may be different from the platforms in Ansible Galaxy which does not offer all
released versions in time and would report an error. For example:
`IMPORTER101: Invalid platform: "FreeBSD-11.3", skipping.`


## Requirements and dependencies

### Roles

* nholuong.ansible_lib

### Collections

* community.general


## Role Variables

- See default variables in *defaults/main.yml*
- See OS specific default varaibles in *vars/defaults/*
- See examples in *vars/main.yml.samples*
- Put OS specific custom variables into the directory *vars/*
- See the precedence of the variables in */tasks/vars.yml*


### Variables

- By default the OS specific packages will be installed

```
ar_install: true
```

- By default use *pip* to install *ansible-runner* on Ubuntu and RH

```
ar_pip_install: true
```

- Use packages, or ports to install *ansible-runner* on FreeBSD

```
ar_pip_install: false
```

- Set variable *ar_owner* to the user who will own the packages installed by pip

```
ar_owner: admin
```

By default

```
ar_owner: "{{ ansible_user_id }}"
```

The *pip* installation task will run

```
become_user: "{{ ar_owner }}"
become: true
pip:
  name: ...
```

See *tasks/packages.yml*


## Examples

1) [Repeat play until succeeds](https://github.com/nholuong/ansible-runner/blob/master/contrib/repeat_play_until_succeeds.bash)


## References

- [Ansible Runner - readthedoc](https://ansible-runner.readthedocs.io/en/latest/)
- [Ansible Runner - github](https://github.com/ansible/ansible-runner/)


# 🚀 I'm are always open to your feedback.  Please contact as bellow information:
### [Contact ]
* [Name: nho Luong]
* [Skype](luongutnho_skype)
* [Github](https://github.com/nholuongut/)
* [Linkedin](https://www.linkedin.com/in/nholuong/)
* [Email Address](luongutnho@hotmail.com)

![](https://i.imgur.com/waxVImv.png)
![](Donate.png)
[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/nholuong)

# License
* Nho Luong (c). All Rights Reserved.🌟