base:
  '*':
    - base_install
{% if 'master' in salt['pillar.get']('kube_nodes:' ~ grains['host'] ~ ':type') %}
    - master_install
{% elif 'minion' in salt['pillar.get']('kube_nodes:' ~ grains['host'] ~ ':type') %}
    - minion_install
#    - pods
{% endif %}
