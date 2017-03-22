#Refresh Grains
updategrains:
  module.run:
    - name: saltutil.refresh_modules

#Install required packages
coreutils:
  pkg.installed


#Create Kubernetes directory
/var/lib/kubernetes:
  file.directory:
    - user: user
    - group: user
    - dir_mode: 755
    - file_mode: 755
