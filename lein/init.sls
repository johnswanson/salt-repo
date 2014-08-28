https://github.com/technomancy/leiningen:
  git.latest:
    - rev: stable
    - target: /usr/lib/leiningen
    - force: True
    - force_checkout: True
    - always_fetch: True

/usr/lib/leiningen/bin/lein:
  file.sed:
    - before: .+
    - after: BIN_DIR="$(dirname /usr/bin/lein)"
    - limit: ^BIN_DIR=
    - require:
      - git: https://github.com/technomancy/leiningen

/usr/bin/lein:
  file.symlink:
    - target: /usr/lib/leiningen/bin/lein
    - require:
      - git: https://github.com/technomancy/leiningen
      - file: /usr/lib/leiningen/bin/lein
