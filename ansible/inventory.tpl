[dc]
DC01 ansible_host=${DC01_IP}

[ws]
WS01 ansible_host=${WS01_IP}

[all:vars]
ansible_user=${ANSIBLE_USER}
ansible_password=${ANSIBLE_PASSWORD}
ansible_connection=winrm
ansible_winrm_transport=basic
ansible_port=5985
