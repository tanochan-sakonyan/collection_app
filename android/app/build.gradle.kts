import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "app.web.mr_collection"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }
    
    packagingOptions {
        pickFirst("**/libc++_shared.so")
        pickFirst("**/libjsc.so")
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "app.web.mr_collection"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 25
        targetSdk = 35
        versionCode = 240
        versionName = "2.4.0"
    }

    fun requireProp(p: Properties, key: String): String =
        p.getProperty(key) ?: error("Missing '$key' in key.properties")

    signingConfigs {
        if (!keystorePropertiesFile.exists()) {
            error("key.properties not found at: ${keystorePropertiesFile.absolutePath}")
        }
        create("release") {
            keyAlias = requireProp(keystoreProperties, "keyAlias")
            keyPassword = requireProp(keystoreProperties, "keyPassword")
            storeFile = file(requireProp(keystoreProperties, "storeFile"))
            storePassword = requireProp(keystoreProperties, "storePassword")
        }
    }

    buildTypes {
        release {
            if (keystorePropertiesFile.exists()) {
                signingConfig = signingConfigs.getByName("release")
            } else {
                // ファイルが無ければデバッグ鍵で署名 or 未設定（CI 用にエラーにしたい場合は throw でもOK）
                signingConfig = signingConfigs.getByName("debug")
            }
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}