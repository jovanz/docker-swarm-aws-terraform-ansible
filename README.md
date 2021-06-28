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


## Enable CloudWatch agent on EC2 instance

First add in Identity and Access Management (IAM) dashboard new Roles with "CloudWatchFullAccess" policy.
After that attach your newly created role to selected EC2 instance.

On EC2 instance download and install debian package.
```bash
# download it
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
#install it
sudo dpkg -i -E ./amazon-cloudwatch-agent.deb
```

Add cwagent User to adm group
Next we are going to modify the linux user account that the installer created cwagent and add it to the adm group,
which will give it read permission to many of the default Ubuntu system logs.
```bash
sudo usermod -aG adm cwagent
```

Insert folowing configuration in /home/ubuntu/amazon-cloudwatch-agent.json file

```json
{
	"agent": {
		"metrics_collection_interval": 30,
		"run_as_user": "cwagent"
	},
	"metrics": {
		"metrics_collected": {
			"cpu": {
				"measurement": [
					"cpu_usage_idle",
					"cpu_usage_iowait",
					"cpu_usage_user",
					"cpu_usage_system"
				],
				"metrics_collection_interval": 30,
				"totalcpu": false
			},
			"disk": {
				"measurement": [
					"used_percent",
					"inodes_free"
				],
				"metrics_collection_interval": 30,
				"resources": [
					"*"
				]
			},
			"diskio": {
				"measurement": [
					"io_time",
					"write_bytes",
					"read_bytes",
					"writes",
					"reads"
				],
				"metrics_collection_interval": 30,
				"resources": [
					"*"
				]
			},
			"mem": {
				"measurement": [
					"mem_used_percent"
				],
				"metrics_collection_interval": 30
			},
			"netstat": {
				"measurement": [
					"tcp_established",
					"tcp_time_wait"
				],
				"metrics_collection_interval": 30
			},
			"swap": {
				"measurement": [
					"swap_used_percent"
				],
				"metrics_collection_interval": 30
			}
		}
	}
}
```

and run folowing command to start CloudWatch agent.
```bash
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/home/ubuntu/amazon-cloudwatch-agent.json
```
