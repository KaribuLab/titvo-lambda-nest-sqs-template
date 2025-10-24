# AWS Lambda SQS Template

Template para crear funciones AWS Lambda que consumen mensajes de SQS usando NestJS, Terragrunt y AWS CDK.

## 📋 Descripción

Este template proporciona una estructura base para desarrollar funciones Lambda que procesan mensajes desde colas SQS. Incluye:

- **NestJS**: Framework para estructurar la lógica de negocio
- **AWS Lambda**: Handler optimizado para eventos SQS
- **Terragrunt**: Infraestructura como código
- **AWS CDK Local**: Desarrollo y testing local con LocalStack
- **Rspack**: Bundling rápido y eficiente
- **Vitest**: Testing unitario
- **Turbowatch**: Hot reload para desarrollo

## 🚀 Uso con KLI

### Requisitos Previos

1. Instalar la CLI `kli` ([GitHub](https://github.com/KaribuLab/kli)):
```bash
# Clonar el repositorio de kli
git clone https://github.com/KaribuLab/kli.git
cd kli

# Compilar
go build -o bin/kli ./*.go

# Mover el binario a un directorio en el PATH
sudo mv bin/kli /usr/local/bin/
```

2. Tener instalado:
   - Go 1.21+ (para compilar kli)
   - Node.js 18+ y npm
   - AWS CLI configurado
   - Terraform y Terragrunt
   - Docker (para desarrollo local con LocalStack)

### Crear un Nuevo Proyecto

Para crear un nuevo proyecto Lambda SQS usando este template:

```bash
kli project https://github.com/KaribuLab/titvo-lambda-nest-sqs-template
```

O especificando un directorio de trabajo y rama:

```bash
# Crear en un directorio específico
kli project https://github.com/KaribuLab/titvo-lambda-nest-sqs-template -w mi-proyecto

# Usar una rama específica
kli project https://github.com/KaribuLab/titvo-lambda-nest-sqs-template -b develop
```

Durante la creación, `kli` te solicitará los siguientes parámetros de forma interactiva:

| Parámetro | Descripción | Ejemplo |
|-----------|-------------|---------|
| `module` | Nombre del módulo principal | `notificaciones` |
| `description` | Descripción del proyecto | `Lambda para procesar notificaciones` |
| `service_name` | Nombre del servicio AWS | `notificaciones-service` |
| `parameter_path` | Ruta para parámetros SSM | `/notificaciones/config` |
| `queue_name` | Nombre de la cola SQS | `notificaciones-queue` |
| `queue_arn_path` | Ruta del ARN de la cola (sin `/company/app/stage/infra/`) | `sqs/notificaciones` |

**Ejemplo de sesión interactiva:**
```bash
$ kli project https://github.com/KaribuLab/titvo-lambda-nest-sqs-template

> Project module: notificaciones
> Project description: Lambda para procesar notificaciones push
> Service name: notificaciones-service
> Parameter path: /notificaciones/config
> Queue name: notificaciones-queue
> Queue arn path (without /company/app/stage/infra/): sqs/notificaciones

✓ Generando archivos...
✓ Ejecutando: Install cdklocal dependencies
✓ Ejecutando: Install npm dependencies
✓ Proyecto creado exitosamente!
```

### Post-instalación Automática

El template ejecutará automáticamente:
1. Instalación de dependencias en `cdklocal/`
2. Instalación de dependencias en la raíz del proyecto

### Funciones de Transformación

KLI utiliza el motor de plantillas de Go. Los archivos del template pueden usar las siguientes funciones para transformar los valores de entrada:

- `{{.Inputs.module|toLowerCase}}` - Convierte a minúsculas
- `{{.Inputs.module|toUpperCase}}` - Convierte a mayúsculas
- `{{.Inputs.module|toPascalCase}}` - Convierte a PascalCase (ej: `MiModulo`)
- `{{.Inputs.module|toCamelCase}}` - Convierte a camelCase (ej: `miModulo`)

Ejemplo en un archivo template:
```typescript
// Si el usuario ingresa module = "user-notifications"
export class {{.Inputs.module|toPascalCase}}Service {
  // Genera: export class UserNotificationsService
}
```

## 📁 Estructura del Proyecto

```
.
├── aws/                          # Infraestructura Terragrunt
│   ├── cloudwatch/              # Configuración de CloudWatch
│   ├── lambda/                  # Configuración de Lambda
│   └── parameter/               # AWS Systems Manager Parameters
├── cdklocal/                    # Stack CDK para desarrollo local
│   ├── bin/                     # Entry point de CDK
│   ├── lib/                     # Definición del stack
│   └── package.json
├── src/                         # Código fuente generado
│   ├── {module}/               # Módulo de negocio
│   │   ├── {module}.service.ts
│   │   ├── {module}.module.ts
│   │   └── {module}.dto.ts
│   ├── app.module.ts           # Módulo raíz de NestJS
│   ├── configuration.ts        # Configuración de la aplicación
│   └── entrypoint.ts           # Handler de Lambda
├── template/                    # Archivos template (se elimina después)
├── package.json
├── rspack.config.cjs           # Configuración de Rspack
├── serverless.hcl              # Variables de Terragrunt
├── terragrunt.hcl              # Configuración base de Terragrunt
├── turbowatch.ts               # Configuración de hot reload
└── vitest.config.ts            # Configuración de testing
```

## 🛠️ Comandos Disponibles

### Desarrollo

```bash
# Instalar dependencias
npm install

# Modo desarrollo con hot reload
npm run dev

# Build para producción
npm run build

# Limpiar artefactos de build
npm run clean
```

### Testing

```bash
# Ejecutar tests
npm test

# Ejecutar tests en modo watch
npm run test:watch
```

### Desarrollo Local con CDK

```bash
cd cdklocal

# Desplegar stack local en LocalStack
npx cdklocal deploy

# Ver diferencias
npx cdklocal diff

# Destruir stack local
npx cdklocal destroy
```

## 🏗️ Infraestructura con Terragrunt

### Configuración

El archivo `serverless.hcl` contiene las variables principales:

```hcl
locals {
  region         = get_env("AWS_REGION")
  stage          = get_env("AWS_STAGE")
  service_name   = "nombre-del-servicio"
  parameter_path = "/ruta/parametros"
  log_retention  = 7
}
```

### Desplegar

```bash
# Configurar variables de entorno
export AWS_REGION=us-east-1
export AWS_STAGE=prod

# Desplegar CloudWatch
cd aws/cloudwatch
terragrunt apply

# Desplegar parámetros
cd ../parameter
terragrunt apply

# Desplegar Lambda
cd ../lambda
terragrunt apply
```

## 📝 Desarrollo de la Lógica de Negocio

El servicio principal se genera en `src/{module}/{module}.service.ts`:

```typescript
@Injectable()
export class MiModuloService {
  private readonly logger = new Logger(MiModuloService.name)
  
  constructor(
    private readonly configService: ConfigService,
  ) {}
  
  async process(input: MiModuloInputDto): Promise<MiModuloOutputDto> {
    // Implementa tu lógica aquí
    this.logger.log('Procesando mensaje...')
    return { resultado: 'success' }
  }
}
```

### Handler de Lambda

El handler en `src/entrypoint.ts` procesa automáticamente los mensajes SQS:

- Inicializa la aplicación NestJS
- Parsea los mensajes SQS
- Procesa cada mensaje en paralelo
- Maneja errores y logging

## 🔧 Configuración

### Variables de Entorno

Las variables se cargan desde AWS Systems Manager Parameter Store según la configuración en `src/configuration.ts`.

### Parámetros SSM

Define tus parámetros en `aws/parameter/terragrunt.hcl` y accede a ellos mediante `ConfigService`:

```typescript
const parametro = this.configService.get<string>('NOMBRE_PARAMETRO')
```

## 🐳 Desarrollo Local

### Requisitos

- Docker y Docker Compose
- LocalStack
- AWS CLI Local (awslocal)

### Configuración

1. Iniciar LocalStack:
```bash
docker run -d \
  --name localstack \
  -p 4566:4566 \
  -e SERVICES=lambda,sqs,logs \
  localstack/localstack
```

2. Desplegar con CDK Local:
```bash
cd cdklocal
npx cdklocal deploy
```

3. Ejecutar en modo desarrollo:
```bash
npm run dev
```

## 📦 Build y Despliegue

### Build

```bash
npm run build
```

Esto genera:
- `dist/index.js`: Bundle optimizado de la Lambda
- Tamaño reducido gracias a Rspack
- Listo para despliegue

### Despliegue a AWS

```bash
# 1. Hacer build
npm run build

# 2. Desplegar infraestructura con Terragrunt
cd aws/lambda
terragrunt apply
```

## 🧪 Testing

El proyecto incluye Vitest para testing:

```typescript
import { Test } from '@nestjs/testing'
import { MiModuloService } from './mi-modulo.service'

describe('MiModuloService', () => {
  let service: MiModuloService

  beforeEach(async () => {
    const module = await Test.createTestingModule({
      providers: [MiModuloService],
    }).compile()

    service = module.get<MiModuloService>(MiModuloService)
  })

  it('debe estar definido', () => {
    expect(service).toBeDefined()
  })
})
```

## 📄 Licencia

Apache-2.0

## 👤 Autor

Patricio Ascencio <patricio.ascencio@karibu.cl>

## 🏷️ Versionado con KLI

Si deseas versionar tu proyecto usando Semantic Versioning, KLI incluye un comando `semver`:

```bash
# Ver la versión actual basada en commits
kli semver

# Crear tags automáticamente
kli semver -t

# Modo detallado
kli semver -v

# Usar un patrón personalizado
kli semver -p "version-{major}.{minor}.{patch}"
```

El comando analiza los mensajes de commit siguiendo [Conventional Commits](https://www.conventionalcommits.org/):
- `fix:` incrementa el PATCH (0.0.X)
- `feat:` incrementa el MINOR (0.X.0)
- `!` o `BREAKING CHANGE` incrementa el MAJOR (X.0.0)

## 🤝 Contribuir

Las contribuciones son bienvenidas. Por favor:

1. Fork el repositorio
2. Crea una rama para tu feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit tus cambios (`git commit -m 'Agrega nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Abre un Pull Request

## 🔧 Personalizar el Template

Este template está configurado mediante el archivo `.kliproject.json`. Si deseas crear tus propias variaciones:

### Estructura de `.kliproject.json`

```json
{
  "templates": [
    {
      "rootDir": "template",
      "delete": true,
      "files": [
        {
          "source": "template/archivo.ts",
          "destination": "src/{{.Inputs.module}}/archivo.ts"
        }
      ]
    }
  ],
  "prompts": [
    {
      "name": "module",
      "description": "Nombre del módulo",
      "type": "string"
    }
  ],
  "posthooks": [
    {
      "name": "Instalar dependencias",
      "command": "npm install"
    }
  ]
}
```

**Campos principales:**

- `templates`: Array de conjuntos de archivos a procesar
  - `rootDir`: Directorio raíz que contiene los templates
  - `delete`: Si `true`, elimina el directorio después de procesar
  - `files`: Array de archivos a copiar/transformar
    - `source`: Ruta del archivo template
    - `destination`: Ruta destino (puede usar variables `{{.Inputs.nombreVariable}}`)

- `prompts`: Inputs que se solicitan al usuario
  - `name`: Nombre de la variable
  - `description`: Texto mostrado al usuario
  - `type`: Tipo de dato (`string`)

- `posthooks`: Comandos a ejecutar después de generar los archivos
  - `name`: Descripción del comando
  - `command`: Comando a ejecutar

## 📚 Recursos Adicionales

- [KLI - Karibu CLI](https://github.com/KaribuLab/kli)
- [Documentación de NestJS](https://docs.nestjs.com/)
- [AWS Lambda con SQS](https://docs.aws.amazon.com/lambda/latest/dg/with-sqs.html)
- [Terragrunt](https://terragrunt.gruntwork.io/)
- [AWS CDK](https://docs.aws.amazon.com/cdk/)
- [LocalStack](https://docs.localstack.cloud/)

## 🔍 Solución de Problemas

### Error al instalar dependencias

```bash
# Limpiar cache y reinstalar
rm -rf node_modules package-lock.json
rm -rf cdklocal/node_modules cdklocal/package-lock.json
npm install
cd cdklocal && npm install
```

### Lambda excede el tiempo de ejecución

- Revisa los logs en CloudWatch
- Considera aumentar el timeout en la configuración de Terragrunt
- Optimiza las consultas y operaciones asíncronas

### Errores en LocalStack

```bash
# Reiniciar LocalStack
docker restart localstack

# Ver logs
docker logs -f localstack
```

