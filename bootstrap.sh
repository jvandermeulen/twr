#!/bin/bash

# Bootstrap script voor Ansible Tower Appliance
#
#https://releases.ansible.com/ansible-tower/rpm/epel-7-x86_64/

red=$(tput setaf 1)
green=$(tput setaf 2)
blue=$(tput setaf 4)
bold=$(tput bold)
reset=$(tput sgr0)

RHSM_STATUS=$(subscription-manager status | awk '/^Overall Status/ {print $3}')
case ${RHSM_STATUS} in
  Current)
    echo ${green}System is properly subscribed.${reset} Trying to enable Ansible channel..
    subscription-manager repos --enable rhel-7-server-ansible-2-rpms || echo ${red}Failed${reset}
    ;;

  Unknown|*)
    echo -e "${red}system not yet registered using Red Hat Subscription Manager. ${reset}\n\nPlease type Red Hat Login (user):"
    read RHUSER
    #echo -e "Please type Red Hat Login password:" && read RHPASS
    echo -e "\n${bold}Trying to register system. Please provide password when asked for..${reset}\n\n"
    subscription-manager register --auto-attach  --username ${RHUSER}  || echo ${red}Registration failed ${reset}
    subscription-manager repos --enable rhel-7-server-ansible-2-rpms && yum -y install ansible git
    ;;
esac


#git clone https://github.com/xforce-redhat/tower-appliance.git
git clone https://github.com/jvandermeulen/twr.git

cd /root
ansible-playbook playbooks/banner.yml
