import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Firebase (Google services + Crashlytics) is applied only when the Firebase project's
// google-services.json has been added (it is git-ignored). Without it the app still builds and
// runs in guest mode; account, sync and purchase-verification features report "not configured".
if (file("google-services.json").exists()) {
    apply(plugin = "com.google.gms.google-services")
    apply(plugin = "com.google.firebase.crashlytics")
}

// Release signing comes from android/key.properties (git-ignored), see docs/EXTERNAL_SETUP.md.
val keystoreProperties = Properties().apply {
    val f = rootProject.file("key.properties")
    if (f.exists()) f.inputStream().use { load(it) }
}
val hasReleaseKey = keystoreProperties.containsKey("storeFile")

android {
    namespace = "com.anirudhzalki.signovoice"
    // Flutter 3.47 defaults: compileSdk 36, targetSdk 36 (current Play requirement), minSdk 24
    // (MediaPipe tasks + ONNX Runtime need >= 24).
    compileSdk = 37
    ndkVersion = flutter.ndkVersion


    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // Required by flutter_local_notifications (java.time backport).
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        applicationId = "com.anirudhzalki.signovoice"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // versionName / versionCode come from pubspec.yaml `version: MAJOR.MINOR.PATCH+BUILD`
        // (semantic version + monotonically increasing Play versionCode).
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseKey) {
            create("release") {
                storeFile = rootProject.file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseKey) {
                signingConfigs.getByName("release")
            } else {
                logger.warn("android/key.properties not found: signing the release build with the DEBUG key. Not uploadable to Google Play.")
                signingConfigs.getByName("debug")
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}

flutter {
    source = "../.."
}
