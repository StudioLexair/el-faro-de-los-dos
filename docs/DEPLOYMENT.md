# Operación de la web y el APK

## Flujo de publicación

`push main` → pruebas → Android release firmado → artefacto → GitHub Release → web precompilada en Vercel.

No hay compilaciones manuales para la entrega oficial ni una compilación de Flutter en Vercel. El mismo APK firmado que aparece en los artefactos y en el release se copia a `/downloads/El-Faro-de-los-Dos-Android.apk` en el despliegue web. `download.json` incluye versión, tamaño, SHA-256, commit y origen de la compilación.

Si fallan las pruebas o la firma, no se publica el siguiente trabajo. Si falla un despliegue, la última web de producción correcta permanece disponible. Revisa el trabajo rojo en Actions y vuelve a ejecutar después de corregirlo.

## Descarga sin salir de la página

Los botones ejecutan una descarga nativa con un enlace temporal que incluye el atributo `download`, sin `target`, `window.open`, navegación o redirecciones externas. El APK está en el mismo origen que la web. Vercel añade `Content-Disposition: attachment` y el tipo MIME de Android. El documento y el número de pestañas permanecen iguales en los navegadores compatibles.

Un navegador puede pedir confirmación, preguntar dónde guardar o permitir abrir el APK después de descargarlo. Android puede pedir autorización para instalar desde el navegador. Eso es una protección del sistema, no una página intermedia del juego; la web no la omite.

## Credenciales

Los únicos secretos persistentes de CI son la firma de Android y `VERCEL_TOKEN`, cifrados en GitHub Actions. Los IDs de Vercel se guardan como variables. No hay tokens en los archivos de la web ni en el repositorio.

El `GITHUB_TOKEN` para publicar releases lo genera GitHub para cada ejecución; el token personal usado en la configuración inicial ya no es necesario.

Para cambiar la credencial de Vercel:

1. Genera una nueva credencial con el menor alcance necesario para el proyecto.
2. Cambia el secreto `VERCEL_TOKEN` del repositorio.
3. Lanza una ejecución manual y confirma que publica correctamente.
4. Revoca la credencial antigua.

No expongas los secretos en `echo`, comandos con trazas (`set -x`) ni archivos de diagnóstico. Las copias temporales del almacén se crean en `RUNNER_TEMP` y se borran con un paso `always()`.

## Firma estable

El almacén es PKCS12. La clave se genera una sola vez y su copia codificada se conserva como secreto. No debe regenerarse en cada ejecución. Sin ella, una nueva app con el mismo identificador no podrá actualizar instalaciones anteriores.

Configura estas variables solo en el entorno de compilación cuando uses tu propia firma:

- `FARO_REQUIRE_RELEASE_SIGNING=true`
- `FARO_KEYSTORE_PATH`: ruta al almacén temporal.
- `FARO_KEYSTORE_PASSWORD`
- `FARO_KEY_ALIAS`
- `FARO_KEY_PASSWORD`

Los valores nunca se escriben en `build.gradle.kts` ni se suben al repositorio.

## Vercel

El proyecto se despliega con Build Output API v3: `.vercel/output/static` contiene la web y el APK; `.vercel/output/config.json` define cabeceras y rutas. No usa funciones ni un servidor de descargas.

`vercel.json` desactiva los despliegues por Git. Esto evita que Vercel publique una copia incompleta de `site/` antes de que GitHub Actions genere el APK y los datos de versión.

Si añades un dominio propio, configúralo en el mismo proyecto de Vercel. La descarga seguirá usando el mismo dominio, porque su ruta es relativa al origen. Comprueba que el dominio de producción sea público y no tenga una protección que obligue a los jugadores a iniciar sesión.

## Comprobar una publicación

- Los tres trabajos de Actions están verdes.
- La web muestra la misma versión que `pubspec.yaml`.
- `GET /download.json` devuelve `available: true` y `buildOrigin: "GitHub Actions"`.
- El APK tiene cabecera `Content-Disposition: attachment`.
- Pulsar Descargar no cambia la URL de la página ni crea otra pestaña.
- El SHA-256 del archivo descargado coincide con `download.json` y con el release.
- Tras instalar, Android muestra el nombre correcto y permite completar el juego sin conexión.

La última comprobación requiere un teléfono o emulador; no se ha realizado automáticamente aquí.
