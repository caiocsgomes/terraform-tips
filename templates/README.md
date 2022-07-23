# Templates in Terraform

We use the `template_file` data source to make templates in terraform. First we define the template in any extension, like json, sh, etc. Then in the template file we set the variables in *${my_var}*. These variables will be replaced then using the data source.

```terraform
data "template_file" "task" {
  template = file(format("%s/task-definition.json", path.module))
  vars     = {
    container_name = var.task_container_name
    image          = var.task_container_image
    task_cpu       = var.task_cpu
    task_memory    = var.task_memory
    essential      = true
    container_port = var.task_container_port
  }
}
```

```json
[
    {
        "name": "${container_name}",
        "image": "${image}",
        "portMappings": [
            {
                "containerPort": "${container_port}",
                "hostPort": "${container_port}"
            }
        ],
        "cpu": "${task_cpu}",
        "memory": "${task_memory}",
        "networkMode": "awsvpc",
        "essential": true,
        "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
                "awslogs-group": "${log_group}",
                "awslogs-region": "${region}",
                "awslogs-stream-prefix": "${container_name}"
            }
        },
        "environment": [
            {
                "name": "PORT",
                "value": "${container_port}"
            }
        ]
    }
]
```

Then to use the template rendered in another resource we use the `rendered` attribute from the `template_file` data source.

```terraform
resource "aws_ecs_task_definition" "ecs_task" {
  family                   = var.task_name
  network_mode             = "awsvpc"
  runtime_platform         = "LINUX"
  requires_compatibilities = ["FARGATE"]
  container_definitions    = data.template_file.task.rendered
}
```

#### Resources

https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file