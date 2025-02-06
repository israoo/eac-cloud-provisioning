# EaC en AWS: Infraestructura, políticas y configuraciones

Este repositorio contiene la infraestructura (IaC), políticas de validación (PaC) y configuraciones (CaC) para el despliegue de un servidor de aplicaciones web en una instancia de EC2 en AWS, utilizando Terraform, OPA (Open Policy Agent) y Ansible.

La integración se realiza mediante scripts en Bash que coordinan la creación del plan de Terraform, la validación del mismo con OPA, la aplicación del plan y la configuración de la instancia con Ansible.

---

## Estructura del repositorio

```plaintext
.
├── ansible
│   ├── ansible.cfg                   # Configuración de Ansible
│   ├── ec2-instance.yml              # Playbook principal
│   ├── hosts                         # Inventario
│   ├── roles
│   │   ├── nginx-setup               # Rol para configurar Nginx
│   │   │   ├── handlers
│   │   │   │   └── main.yml          # Manejador para recargar Nginx
│   │   │   └── tasks
│   │   │       └── main.yml          # Tareas para instalar e iniciar Nginx
│   │   └── web-index                 # Rol para configurar la página de inicio
│   │       ├── tasks
│   │       │   └── main.yml          # Tarea para copiar la plantilla de la página de inicio
│   │       └── templates
│   │           └── index.html        # Plantilla de la página de inicio
│   ├── terraform_generated_key.pem   # Clave privada generada por Terraform
│   └── vars
│       └── ec2-instance.yml          # Variables para el playbook (IP y usuario de la instancia)
├── opa
│   └── policy.rego                  # Políticas Rego para validar el plan de Terraform
├── scripts
│   ├── apply_ansible.sh              # Script para ejecutar el playbook de Ansible
│   ├── apply_terraform.sh            # Script para inicializar y aplicar Terraform
│   ├── pipeline.sh                   # Script para coordinar la ejecución de Terraform, OPA y Ansible
│   └── validate_opa.sh               # Script para validar el plan de Terraform con OPA
└── terraform
    ├── 01-vpc.tf                     # Definición de la VPC y recursos de red
    ├── 02-ec2.tf                     # Definición de la instancia EC2, security group y key pair
    ├── outputs.tf                    # Salida de Terraform (ID e IP pública de la instancia)
    ├── providers.tf                  # Configuración del proveedor de AWS
    ├── variables.auto.tfvars         # Valores para variables de Terraform
    ├── variables.tf                  # Declaración de variables de Terraform
    └── versions.tf                   # Configuración de versión y proveedores de Terraform
```

---

## Requisitos

- [Terraform](https://developer.hashicorp.com/terraform/downloads) instalado.
- [Open Policy Agent (OPA)](https://www.openpolicyagent.org/docs/v0.11.0/get-started/) instalado.
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) instalado.
- [jq](https://jqlang.org/download/) instalado.
- Bash (o un intérprete compatible) para ejecutar los scripts.

Además, necesitarás tener una cuenta de AWS con permisos suficientes para crear los recursos necesarios y configurar tus credenciales en tu máquina. Puedes hacer esto ejecutando el siguiente comando:

```bash
aws configure
```

O configurando las variables de entorno `AWS_ACCESS_KEY_ID` y `AWS_SECRET_ACCESS_KEY`.

---

## Instrucciones de uso

1. Clona este repositorio en tu máquina:

    ```bash
    git clone https://github.com/israoo/eac-cloud-provisioning.git
    cd eac-cloud-provisioning
    ```

2. Ajusta los valores de las variables en el archivo `variables.auto.tfvars` según tus necesidades.
3. Configura los permisos de ejecución de los scripts:

    ```bash
    chmod +x scripts/*.sh
    ```

4. Ejecuta el script `./scripts/pipeline.sh` para coordinar la ejecución de Terraform, OPA y Ansible:

    ```bash
    ./scripts/pipeline.sh
    ```

    Este script realizará las siguientes acciones:

    - Inicializará Terraform.
    - Creará un plan de Terraform.
    - Convertirá el plan a formato JSON.
    - Validará el plan con OPA.
    - Solicitará confirmación para aplicar el plan.
    - Aplicará el plan de Terraform.
    - Ejecutará el playbook de Ansible para configurar la instancia.

5. Cuando termines de usar la infraestructura, puedes destruirla ejecutando el siguiente comando en el directorio `terraform`:

    ```bash
    terraform destroy
    ```

---

## Pruebas

Para probar la infraestructura, puedes acceder a la dirección IP pública de la instancia EC2 en tu navegador. Deberías ver una página de inicio con el mensaje "Welcome to Ansible".

---

## Notas adicionales

### Seguridad

El security group definido en Terraform permite el tráfico entrante en los puertos 22 (SSH) y 80 (HTTP) desde cualquier dirección IP. Esto es únicamente con fines de demostración y no se recomienda en un entorno de producción. Se recomienda restringir el tráfico a direcciones IP específicas y utilizar HTTPS en lugar de HTTP.

### Políticas OPA

El archivo `opa/policy.rego` contiene las políticas Rego utilizadas para validar el plan de Terraform. Puedes modificar estas políticas según tus necesidades.

### Variables de Ansible

El archivo `ansible/vars/ec2-instance.yml` se actualiza automáticamente con la dirección IP y el usuario de la instancia EC2 después de aplicar el plan de Terraform.

### Clave privada de Ansible

La clave privada generada por Terraform se guarda en el archivo `ansible/terraform_generated_key.pem`. Esta clave se utiliza para conectarse a la instancia EC2 mediante SSH.

---

## Tecnologías utilizadas

- **Terrafom**: Para la infraestructura como código.
- **Open Policy Agent (OPA)**: Para la validación de políticas.
- **Ansible**: Para la configuración de la instancia EC2.
- **Bash**: Para los scripts de automatización.
