// Top-level build file where you can add configuration options common to all sub-projects/modules.

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Use a version compatible with your Gradle and Java version
        classpath("com.android.tools.build:gradle:8.3.0")
        // Add other classpaths if needed, e.g., for Kotlin, Firebase, etc.
        // classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.24")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Optional: change the root build directory
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// Make sure app is evaluated first (optional)
subprojects {
    project.evaluationDependsOn(":app")
}

// Register a clean task
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
