# docker-swarm-aws-terraform-ansible
Create docker swarm cluster on AWS using terraform and ansible with one Manger and two Workers.

Create EFS and mount it EC2 instances

## Prerequest

Use environment variables to provide configuration options and credentials.
```bash
    $ export AWS_ACCESS_KEY_ID=
    $ export AWS_SECRET_ACCESS_KEY=
    $ export AWS_DEFAULT_REGION=eu-central-1
```
or use named profile in the shared configuration and credentials files.
```bash
    .aws/credentials
    [default]
    aws_access_key_id=
    aws_secret_access_key=

    .aws/config
    [default]
    region=eu-central-1
    output=json
```

## Terraform

Change directory to terraform, set up path to docker-key.pem for example can be use ~/.ssh/id_rsa.pub
and execute terraform apply command.
```bash
    cd terraform
    terraform init
    terraform apply
```

## Ansible

When EC2 instances are up and running, get IPs of instances an put in ansible/hosts file

First need to install docker with running:
```bash
    cd ansible
    ansible-playbook -i hosts --private-key ~/.ssh/id_rsa install-docker-playbook.yaml
```
and after that we set up docker swarm cluster.
```bash
    cd ansible
    ansible-playbook -i hosts --private-key ~/.ssh/id_rsa docker-swarm-init-playbook.yaml
```

To verify that docker swarm is up and running just connect to manager node and run
```bash
    ssh -i ~/.ssh/id_rsa ubuntu@manager_public_ip
    docker node ls
```

## Deploy service to Swarm

