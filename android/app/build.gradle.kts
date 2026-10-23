plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

val releaseStore = System.getenv("FARO_KEYSTORE_PATH")
val productionSigning = !releaseStore.isNullOrBlank()
val requireProductionSigning = System.getenv("FARO_REQUIRE_RELEASE_SIGNING") == "true"
if (requireProductionSigning && !productionSigning) {
    throw GradleException("Falta la firma de producción. Configura los secretos APK_KEYSTORE_* en GitHub Actions.")
}

android {
    namespace = "dev.enpareja.el_faro_de_los_dos"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "dev.enpareja.el_faro_de_los_dos"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (productionSigning) {
            create("production") {
                storeType = "PKCS12"
                storeFile = file(releaseStore!!)
                storePassword = System.getenv("FARO_KEYSTORE_PASSWORD")
                    ?: throw GradleException("Falta FARO_KEYSTORE_PASSWORD")
                keyAlias = System.getenv("FARO_KEY_ALIAS")
                    ?: throw GradleException("Falta FARO_KEY_ALIAS")
                keyPassword = System.getenv("FARO_KEY_PASSWORD")
                    ?: throw GradleException("Falta FARO_KEY_PASSWORD")
            }
        }
    }
    buildTypes {
        release {
            // CI exige la firma estable. El modo local sigue permitiendo APKs de prueba.
            signingConfig = signingConfigs.getByName(if (productionSigning) "production" else "debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter { source = "../.." }
