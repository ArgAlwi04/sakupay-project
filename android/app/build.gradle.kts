// Import ini mungkin diperlukan di bagian paling atas
import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

fun localProperties(key: String, file: java.io.File = rootProject.file("local.properties")): String {
    val properties = Properties()
    if (file.exists()) {
        properties.load(FileInputStream(file))
    }
    return properties.getProperty(key) ?: ""
}

android {
    namespace = "com.sakupay.app"
    compileSdk = 35 // <-- INI YANG AKAN MEMPERBAIKI ERROR

    sourceSets {
        getByName("main").java.srcDirs("src/main/kotlin")
    }

    defaultConfig {
        applicationId = "com.sakupay.app"
        minSdk = 23
        targetSdk = 34
        versionCode = 1
        versionName = "1.0.0"
        multiDexEnabled = true
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }
    kotlinOptions {
        jvmTarget = "1.8"
    }
}