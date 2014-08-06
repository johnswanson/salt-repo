include:
  - zsh
  - git
  - tmux
  - vim

jds:
  user.present:
    - home: /home/jds
    - shell: /bin/zsh
    - gid_from_name: True
    - require:
      - pkg: zsh

/home/jds/.tmux.conf:
  file.managed:
    - user: jds
    - group: jds
    - mode: 0600
    - source: salt://tmux/tmux.conf
    - require:
      - user: jds

/home/jds/.ssh:
  file.directory:
    - user: jds
    - group: jds
    - mode: 0700

/home/jds/.ssh/authorized_keys:
  file.managed:
    - user: jds
    - group: jds
    - mode: 0600
    - source: salt://users/jds.authorized_keys
    - require:
      - user: jds

/home/jds/.gitconfig:
  file.managed:
    - user: jds
    - group: jds
    - mode: 0600
    - source: salt://git/gitconfig
    - require:
      - user: jds

/home/jds/.zshrc:
  file.managed:
    - user: jds
    - group: jds
    - mode: 0600
    - source: salt://zsh/zshrc
    - require:
      - user: jds
      - pkg: git # for oh-my-zsh plugin

https://github.com/johnswanson/oh-my-zsh:
  git.latest:
    - rev: master
    - target: /home/jds/.oh-my-zsh
    - force: True

/home/jds/.vimrc:
  file.managed:
    - user: jds
    - group: jds
    - mode: 0600
    - source: salt://vim/vimrc
    - require:
      - user: jds
