buildscript {
    // Update Kotlin version to 2.0.0 to match Firebase requirements
    extra["kotlin_version"] = "2.0.0"
    
    repositories {
        google()
        mavenCentral()
    }
    
    dependencies {
        classpath("com.google.gms:google-services:4.4.2")
        // Add Kotlin Gradle plugin with the updated version
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:2.0.0")
    }
}

// Add plugins block
plugins {
    // Add the dependency for the Google services Gradle plugin
    id("com.google.gms.google-services") version "4.4.2" apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
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
