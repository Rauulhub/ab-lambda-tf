# LABORATORIO IMPLEMENTACION DE TERRAFORM Y GITHUB ACTIONS

## Descripción:

  Se implementa codigo en terraform para desplegar lambda y API GW.
  Se configura de modo que creemos una lambda modificable en su codigo, accesible desde un API GW donde si se accede al link /healtcheck envie un Ok con timestamp, y se se accede /convert
  se ejecutara una aplicacion NodeJS que esta en el repositorio (https://github.com/Rauulhub/app-lambda) para conversion de moneda USD y EUR, tambien se crea un S3 para guardar el tfstate.
  La relación de confianza entre github y AWS no debe ser con access-key y secret access-key, debe ser con roles de IAM y usando OIDC, para esto se debe configurar previamente en AWS un identity provider y 
  un rol con accesos dependiendo de la app... [guia para configurar OIDC en AWS] (https://aws.amazon.com/es/blogs/security/use-iam-roles-to-connect-github-actions-to-actions-in-aws/)

  el uso de Github actions se programo para que en diferentes fases:
  
    fase 1: pull request se haga la verificacion del `terraform init`,  `terraform validate`
    
    fase 2: push se valida el `terraform plan` y se despliega
    
    fase 3: se crea para hacer el eliminado manual con `terraform destroy`
