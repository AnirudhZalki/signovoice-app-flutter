// Firebase Gradle plugins are put on the classpath ONLY when the Firebase project's
// app/google-services.json exists (it is git-ignored). Builds without it — CI, first clone,
// guest-mode builds — never resolve these artifacts and cannot break because of them.
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        if (file("app/google-services.json").exists()) {
            classpath("com.google.gms:google-services:4.4.3")
            classpath("com.google.firebase:firebase-crashlytics-gradle:3.0.4")
        }
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
