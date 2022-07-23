data "template_file" "task" {
  template = file(format("%s/task-definitions/task.json", path.module))
  vars     = {
    container_name = var.task_container_name
    image          = var.task_container_image
    task_cpu       = var.task_cpu
    task_memory    = var.task_memory
    essential      = true
    container_port = var.task_container_port
  }
}

resource "aws_ecs_task_definition" "ecs_task" {
  family                   = var.task_name
  network_mode             = "awsvpc"
  runtime_platform         = "LINUX"
  requires_compatibilities = ["FARGATE"]
  container_definitions    = data.template_file.task.rendered
}