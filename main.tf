// DOC utilizada como referência: https://registry.terraform.io/providers/-/aws/latest/docs/resources/instance

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "this" {
  for_each      = var.instances
  ami           = data.aws_ami.ubuntu.id
  instance_type = each.value["instance_type"]

  dynamic "ebs_block_device" {
    for_each = var.extras_volumes
    content {
      device_name = ebs_block_device.value["device_name"]
      volume_size = ebs_block_device.value["volume_size"]
    }
  }

  tags = {
    Name     = each.value["tag_name"]
    Product  = each.key
  }

  // DOC utilizada como referência: https://developer.hashicorp.com/terraform/language/meta-arguments/lifecycle
  /*
  Esse bloco permite alterar três aspectos fundamentais do comportamento do Terraform durante a gestão daquele recurso:
  - `create_before_destroy`: por padrão, quando o Terraform precisa substituir um recurso, ele primeiro destrói o recurso existente e depois cria o novo, podendo causar uma janela de indisponibilidade; ao definir essa opção com `true`, a lógica é invertida
    - Essa opção pode não funcionar com todos os tipos de recursos, especialmente aqueles que possuem restrições de unicidade - por exemplo, nomes de bucket S3
  - `prevent_destroy`: mecanismo de defesa que impede a exclusão do recurso se a opção for definida como `true`
  - `ignore_changes`: permite especificar uma lista de atributos cujas alterações na configuração devem ser ignoradas pelo Terraform após a criação inicial; isso é útil quando um atributo é gerenciado externamente (por exemplo - por outro time, por um operador humano ou por um processo automático) e você não quer que o Terraform tente redefini-lo
  - `replace_triggered_by`: força a substituição do recurso quando determinados atributos de outros recursos forem modificados
  */
  // Nesse exemplo, como definimos um data source para buscar a AMI mais recente, uma nova AMI pode ser lançada a qualquer momento; consequentemente, ao aplicar o código Terraform novamente, uma nova AMI pode ser detectada e a instância poderá ser recriada - o bloco abaixo impede esse tipo de situação
  lifecycle {
    ignore_changes = [
      ami
    ]
  }
}