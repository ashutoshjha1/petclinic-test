# petclinic-test

ssh-keygen -t rsa -b 4096 -C "CICD"
cat /home/ubuntu/.ssh/id_rsa.pub

sudo chmod 400 tf-test.pem

ssh ubuntu@ip_of_target -i tf-test.pem

ansible-playbook -i hosts petclinic-playbook.yaml
