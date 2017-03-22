pki_info:
  key_size: 2048
  ca_expire: 87600h
  key_expire: 87600h
  cert_country: US
  cert_province: MN
  cert_city: Minneapolis
  cert_org: Test Org
  cert_email: test@test.com
  cert_ou: Test
  cert_name: kubernetes
auth_logins:
  jonlangemak:
    uid: 1
    password: jonpass
  admin:
    uid: 2
    password: adminpass
auth_tokens:
  tokenofthejon:
    uid: 1
    username: jontoken
kube_nodes:
  ubuntu-1:
    type: master
    ipaddress: 10.20.30.71
    fqdn: ubuntu-1.interubernet.local
  ubuntu-2:
    type: minion
    ipaddress: 10.20.30.72
    fqdn: ubuntu-2.interubernet.local
  ubuntu-3:
    type: minion
    ipaddress: 10.20.30.73
    fqdn: ubuntu-3.interubernet.local
  ubuntu-4:
    type: minion
    ipaddress: 192.168.50.74
    fqdn: ubuntu-4.interubernet.local
  ubuntu-5:
    type: minion
    ipaddress: 192.168.50.75
    fqdn: ubuntu-5.interubernet.local
