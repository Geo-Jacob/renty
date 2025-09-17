plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.cia_renty"
    compileSdk = 35  // Updated to latest stable SDK
    ndkVersion = "26.3.11579264"  // Specify a specific NDK version

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.cia_renty"
        minSdk = 23  // Minimum SDK for current Firebase
        targetSdk = 34  // Latest stable SDK
        versionCode = 1
        versionName = "1.0.0"
        multiDexEnabled = true  // Enable multidex for large app
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = true
            isDebuggable = false
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
        getByName("debug") {
            isDebuggable = true
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }

    lint {
        disable += "InvalidPackage"
        checkReleaseBuilds = false
    }
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:34.2.0"))
    implementation("com.google.firebase:firebase-analytics")
    implementation("androidx.multidex:multidex:2.0.1")
    implementation("androidx.window:window:1.2.0")
    implementation("androidx.window:window-java:1.2.0")
}

flutter {
    source = "../.."
}
