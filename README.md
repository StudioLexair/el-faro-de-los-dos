# El Faro de los Dos

[![Android · Pruebas, APK y web](https://github.com/StudioLexair/el-faro-de-los-dos/actions/workflows/release.yml/badge.svg)](https://github.com/StudioLexair/el-faro-de-los-dos/actions/workflows/release.yml)

**Una aventura cooperativa en Flutter para dos personas que comparten un móvil Android.**

Tres salas, seis notas, símbolos, navegación y un último mecanismo de luz. No hay reloj, anuncios, cuentas ni compras. La partida se guarda automáticamente en el dispositivo y el APK funciona sin internet.

## Web oficial y descarga

La web está alojada en **Vercel**. Su dirección de producción figura en el apartado **About / Website** del repositorio y en el resumen del workflow.

**El botón de descarga entrega el APK desde el mismo dominio de la web.** No abre GitHub Releases, otra página ni una pestaña. El archivo se sirve con `Content-Disposition: attachment` y el cliente utiliza una descarga nativa del navegador. El sistema puede pedir confirmación para descargar o instalar; una web no debe ni puede suprimir esas protecciones.

Compatibilidad: Android 7.0+ (API 24), ARM de 32 y 64 bits.

## Todo el proceso se ejecuta en GitHub Actions

Un `push` a `main` ejecuta `.github/workflows/release.yml`:

1. **Pruebas Flutter:** formato, análisis y las pruebas de reglas, guardado y recorrido de interfaz.
2. **APK Android:** instala el SDK fijado, compila release con firma estable, verifica la firma y comprueba que no se añadan permisos sensibles o internet.
3. **Publicación:** recupera el APK de los artefactos, publica una copia en GitHub Releases, genera la web con ese mismo archivo, versión, tamaño y SHA-256, y despliega el resultado precompilado en Vercel.

Las pull requests ejecutan solo las pruebas: no reciben la firma ni el token de Vercel.

**Vercel no compila Flutter.** Recibe un despliegue estático ya preparado mediante Build Output API. No hay despliegue automático por integración Git; la autoridad de publicación es el workflow de GitHub Actions. La web, el APK y los datos de versión se actualizan juntos de forma atómica.

Las dependencias de Actions están fijadas a commits y el SDK a **Flutter 3.47.8 / revisión 737ba8f885dc774b53b442759999a312c9461e4e**. Se usan Java 21, Android SDK 36 y Vercel CLI 65.2.0.

## Publicar una actualización

1. Modifica el código en `lib/` o la web en `site/`.
2. Si cambia la app, aumenta `version` y el número de compilación en `pubspec.yaml` (por ejemplo, `1.0.2+3`).
3. Haz `push` a `main` y espera a que los tres trabajos de Actions estén verdes.
4. La página oficial ofrecerá el nuevo APK automáticamente. No hay que cambiar enlaces ni subir el archivo a mano.

También puedes iniciar el proceso desde **Actions → Android · Pruebas, APK y web → Run workflow**.

## Firma y credenciales

La firma privada y la credencial de despliegue están en **Settings → Secrets and variables → Actions**, no en el código:

| Tipo | Nombre | Uso |
|---|---|---|
| Secret | `APK_KEYSTORE_BASE64` | Almacén de firma PKCS12, codificado como base64 |
| Secret | `APK_KEYSTORE_PASSWORD` | Contraseña del almacén |
| Secret | `APK_KEY_PASSWORD` | Contraseña de la clave |
| Secret | `APK_KEY_ALIAS` | Alias de firma |
| Secret | `VERCEL_TOKEN` | Publicar en el proyecto de Vercel |
| Variable | `VERCEL_ORG_ID` | Equipo propietario del proyecto |
| Variable | `VERCEL_PROJECT_ID` | Proyecto de Vercel |

El token personal de GitHub usado para crear/configurar el repositorio **no se guarda ni se utiliza en los workflows**. Actions utiliza su propio `GITHUB_TOKEN` para los releases.

No cambies la firma entre versiones: Android exige la misma identidad para actualizar una instalación. Conserva una copia privada de la firma fuera del repositorio. No subas claves, contraseñas, tokens, `.env` ni copias privadas de configuración.

Si instalaste el APK de desarrollo anterior, firmado con una clave de prueba, puede ser necesario desinstalarlo una vez antes de instalar el primer APK oficial. Esa desinstalación borra el progreso local. Las siguientes versiones oficiales conservarán la firma estable.

Para rotar un token de Vercel, actualiza primero `VERCEL_TOKEN` en Actions y después revoca el anterior. Usa una credencial de alcance mínimo. Más detalles en [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md).

## Desarrollo

```sh
flutter pub get
flutter analyze
flutter test
flutter run
```

El APK local puede firmarse con una clave de desarrollo; CI exige la firma estable mediante `FARO_REQUIRE_RELEASE_SIGNING=true`. No distribuyas compilaciones de desarrollo como actualizaciones oficiales.

Para empaquetar la web necesitas un APK ya compilado; este comando no compila Flutter:

```sh
python3 scripts/prepare-site.py --apk ruta/al/APK.apk
```

Produce `.vercel/output/`, que Vercel recibe con `vercel deploy --prebuilt --prod`.

## Código y contenido

- `lib/game_state.dart`: reglas, validación y guardado local.
- `lib/content.dart`: historia, notas y ayudas.
- `lib/faro_widgets.dart`: componentes de interfaz y controles.
- `lib/screens.dart`: portada, exploración, mapa, cuaderno y final.
- `site/`: página oficial, sin dependencias externas ni rastreadores añadidos.
- `scripts/`: instalación del SDK fijado y empaquetado de la entrega web.
- `.github/workflows/release.yml`: pruebas, compilación y publicación.
- `test/`: pruebas automáticas del juego.

Las cuatro ilustraciones ambientales se generaron con IA para este proyecto. Las capturas de la web muestran el juego Flutter real. Cormorant Garamond y Manrope se incluyen localmente con sus licencias SIL Open Font License en `assets/fonts/` y `site/licenses/`.

Las soluciones están en `SOLUCIONES.md` y en las ayudas del juego: evita abrir el archivo si no quieres spoilers.

## Privacidad y alcance

El APK no solicita internet, cámara, micrófono, ubicación ni contactos. Solo guarda la partida localmente; no sincroniza entre dispositivos. La web sirve archivos estáticos desde Vercel y no añade cookies de analítica. El proveedor de alojamiento puede registrar accesos técnicos.

Es un primer capítulo con puzles fijos y desenlace completo, no una campaña infinita ni un juego por red. Las pruebas automáticas y la compilación no sustituyen las pruebas en dispositivos: **el APK todavía no ha sido probado en un teléfono Android físico ni en un emulador**.
