CLUSTERNAME := $(shell cat terraform.tfvars | grep cluster_name | sed 's/^.*= //' | sed 's/"//g')

run:
	terraform plan -out planfile
	terraform apply "planfile"

plan:
	terraform plan -out planfile

clean:
	terraform destroy -auto-approve
	ssh-keygen -R 192.168.180.119 -f /root/.ssh/known_hosts
	ssh-keygen -R 192.168.180.120 -f /root/.ssh/known_hosts
	ssh-keygen -R 192.168.180.121 -f /root/.ssh/known_hosts
	ssh-keygen -R 192.168.180.122 -f /root/.ssh/known_hosts
	ssh-keygen -R 192.168.180.123 -f /root/.ssh/known_hosts
	ssh-keygen -R 192.168.180.124 -f /root/.ssh/known_hosts
	ssh-keygen -R 192.168.180.125 -f /root/.ssh/known_hosts
	ssh-keygen -R 192.168.180.126 -f /root/.ssh/known_hosts

stop:
	virsh shutdown $(CLUSTERNAME)_Worker1
	virsh shutdown $(CLUSTERNAME)_Worker2
	virsh shutdown $(CLUSTERNAME)_Worker3
	virsh shutdown $(CLUSTERNAME)_Worker4
	virsh shutdown $(CLUSTERNAME)_Master1
	virsh shutdown $(CLUSTERNAME)_Master2
	virsh shutdown $(CLUSTERNAME)_Master3
	virsh shutdown $(CLUSTERNAME)_LoadBalancer
	virsh shutdown $(CLUSTERNAME)_Workstation

startup:
	virsh start $(CLUSTERNAME)_Worker1
	virsh start $(CLUSTERNAME)_Worker2
	virsh start $(CLUSTERNAME)_Worker3
	virsh start $(CLUSTERNAME)_Worker4
	virsh start $(CLUSTERNAME)_Master1
	virsh start $(CLUSTERNAME)_Master2
	virsh start $(CLUSTERNAME)_Master3
	virsh start $(CLUSTERNAME)_LoadBalancer
	virsh start $(CLUSTERNAME)_Workstation

print_clustername:
	@echo MY_VAR IS $(CLUSTERNAME)

pack:
	rm example.tar.gz || true
	tar cvf example.tar.gz \
		--exclude=modules/loadbalancer/lb_disk \
		--exclude=*/*.qcow2 \
		--exclude=.git \
		--exclude=.gitignore \
		--exclude=*/.terraform \
		--exclude=./*terraform.* \
		--exclude=Makefile .
