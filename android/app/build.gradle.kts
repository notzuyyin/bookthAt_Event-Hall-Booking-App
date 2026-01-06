plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")

    // 👇 Firebase Google Services plugin
    id("com.google.gms.google-services")
}

android {
    namespace = "com.syaidaiman.eventhall.event_hall_booking_system"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.syaidaiman.eventhall.event_hall_booking_system"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // 📌 Firebase Bill of Materials (controls versions for all Firebase libs)
    implementation(platform("com.google.firebase:firebase-bom:32.7.0"))

    // 📌 Basic Firebase service to confirm connection
    implementation("com.google.firebase:firebase-analytics")

    // ⚠️ We will add more later:
    // Auth:                implementation("com.google.firebase:firebase-auth")
    // Firestore Database:  implementation("com.google.firebase:firebase-firestore")
    // Storage (Images):    implementation("com.google.firebase:firebase-storage")
}
