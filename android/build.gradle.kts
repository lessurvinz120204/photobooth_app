buildscript {
    ext.kotlin_version = '1.7.10'
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
    
    // Fix namespace for plugins without namespace
    afterEvaluate {
        if (it.hasProperty('android')) {
            it.android {
                if (!it.android.namespace) {
                    it.android.namespace = "com.example.${project.name}"
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}