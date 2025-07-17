// Root-level build.gradle.kts

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // ✅ Sesuaikan agar cocok dengan Gradle wrapper 8.14.3
        classpath("com.android.tools.build:gradle:8.4.0")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.23")
        classpath("com.google.gms:google-services:4.4.2")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// ✅ Bersihkan build directory saat menjalankan ./gradlew clean
tasks.register("clean", Delete::class) {
    delete(rootProject.buildDir)
}
