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

    project.plugins.withId("com.android.library") {
        val android = project.extensions.getByType(com.android.build.gradle.LibraryExtension::class.java)
        val knownNamespaces = mapOf(
            "isar_flutter_libs" to "dev.isar.isar_flutter_libs",
            "geocoding_android" to "com.baseflow.geocoding",
            "geolocator_android" to "com.baseflow.geolocator"
        )
        if (android.namespace == null) {
            android.namespace = knownNamespaces[project.name]
                ?: ("com.example." + project.name.replace("-", "_").replace(".", "_"))
        }
        if (android.compileSdk == null || android.compileSdk!! < 36) {
            android.compileSdk = 36
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
