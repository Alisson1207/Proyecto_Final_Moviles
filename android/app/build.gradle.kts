plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.proyecto_final"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

   defaultConfig {
    applicationId = "com.example.proyecto_final"
    minSdk = flutter.minSdkVersion
    targetSdk = 35        
    versionCode = flutter.versionCode
    versionName = flutter.versionName
}


    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
        packagingOptions {
        exclude("META-INF/*")
    }

}

flutter {
    source = "../.."
}
dependencies {
    implementation("androidx.core:core-ktx:1.9.0")
}

