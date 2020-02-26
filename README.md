## gcp-nomad-demo

### References

- [Terraform Curriculum - HashiCorp Learn](https://learn.hashicorp.com/terraform)
- [Nomad Curriculum - HashiCorp Learn](https://learn.hashicorp.com/nomad)

### How to use

#### Install terraform and nomad

```
$ brew install terraform nomad
```

#### Apply terraform

```
$ cp variables.tf.sample variables.tf
$ vi variables.tf
$ terraform init
$ terraform apply
```

#### Apply ansible

```
$ virtualenv venv
$ source venv/bin/activate
$ pip install -r requirements.txt
$ rehash
$ ansible-playbook -i hosts site.yml
```

#### Submit nomad jobs

```
$ nomad run traefik.nomad
$ nomad run webapp.nomad
```
