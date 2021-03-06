include:
  - postgres

{% set version = salt['pillar.get']('python:version', '3') %}
{% set project_name = salt['pillar.get']('project:name', 'example') %}

/home/vagrant/.virtualenv:
  virtualenv.managed:
    - user: vagrant
    - no_chown: True
    - python: python{{ version }}
    - system_site_packages: False
    - requirements: /home/vagrant/{{ project_name }}/djangoapp/requirements/development.txt

/home/vagrant:
  file.recurse:
    - user: vagrant
    - name: /home/vagrant
    - source: salt://files/user/vagrant
    - include_empty: True
    - require:
      - virtualenv: /home/vagrant/.virtualenv

migrate:
  cmd.run:
    - user: vagrant
    - name: "source ~/.virtualenv/bin/activate && python ./djangoapp/manage.py migrate --noinput"
    - cwd: "/home/vagrant/{{ project_name }}"
    - require:
      - virtualenv: /home/vagrant/.virtualenv

createsuperuser:
  cmd.wait:
    - user: vagrant
    - name: "source ~/.virtualenv/bin/activate && echo \"from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.create_superuser('admin', 'admin@example.com', 'password')\" | python ./djangoapp/manage.py shell"
    - cwd: "/home/vagrant/{{ project_name }}"
    - watch:
      - cmd: migrate
 
