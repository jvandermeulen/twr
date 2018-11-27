#!/bin/bash

# Bootstrap script voor Ansible Tower Appliance
#
#https://releases.ansible.com/ansible-tower/rpm/epel-7-x86_64/

red=$(tput setaf 1)
green=$(tput setaf 2)
blue=$(tput setaf 4)
bold=$(tput bold)
reset=$(tput sgr0)

git_repo_basename=twr 		# tower-appliance
git_org_name=jvandermeulen	# xforce-redhat



RHSM_STATUS=$(subscription-manager status | awk '/^Overall Status/ {print $3}')
case ${RHSM_STATUS} in
  Current)
    echo "${green}System is properly subscribed.${reset} Trying to enable Ansible channel..."
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

cd ~
echo -n "${blue}Continue...${reset} Check for local copy of github repository ${git_repo_basename}..."
if [ -d ~/${git_repo_basename} ]
then
	echo "${blue}Directory ${git_repo_basename} already exists. SKIP downloading.${reset}"
else
	git clone https://github.com/${git_org_name}/${git_repo_basename}.git
fi

ansible-playbook ${git_repo_basename}/playbooks/banner.yml

