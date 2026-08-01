import java.util.Properties

plugins {
    id("com.android.application")
    // Firebase: applies google-services.json at build time.
    id("com.google.gms.google-services")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing (v1.28.0). Loaded from android/key.properties, which is
// git-ignored and points at a keystore stored OUTSIDE the repo. When
// key.properties is absent (local dev / CI without secrets), release builds
// fall back to the debug key so `flutter build ... --release` still produces
// output — but those artifacts are NOT valid for Play Store upload.
// See docs/play-store/production-signing.md.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
val hasReleaseKeystore = keystorePropertiesFile.exists()
if (hasReleaseKeystore) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}

android {
    namespace = "com.gurukula.gurukula_ai"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // Permanent once published to Play — do not change casually.
        applicationId = "com.gurukula.gurukula_ai"
        // Firebase Auth needs minSdk 23; ML Kit GenAI (Phase 16A on-device AI
        // availability check) needs minSdk 26. Keep Flutter's default if higher.
        minSdk = maxOf(26, flutter.minSdkVersion)
        // compile/target SDK track the installed Flutter (Play-compatible).
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        // Populated only when android/key.properties exists. All four fields
        // are required; a missing one fails the build clearly.
        create("release") {
            if (hasReleaseKeystore) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // Real upload key when configured; debug key otherwise so release
            // builds still run locally (those outputs can't be uploaded to Play).
            signingConfig = if (hasReleaseKeystore) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            // Enable R8 so the ML Kit ProGuard rules (Phase 14B) apply and the
            // optional non-Latin text recognizers are stripped from the release.
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    // ML Kit GenAI (Gemini Nano via AICore). Phase 16A uses only the
    // availability check (checkFeatureStatus); generation stays on the mock.
    implementation("com.google.mlkit:genai-summarization:1.0.0-beta1")
}
