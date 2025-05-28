import com.android.build.gradle.AppExtension

val android = project.extensions.getByType(AppExtension::class.java)

android.apply {
    flavorDimensions("flavor-type")

    productFlavors {
        create("user") {
            dimension = "flavor-type"
            applicationId = "com.example.astro.user"
            resValue(type = "string", name = "app_name", value = "User App")
        }
        create("instructor") {
            dimension = "flavor-type"
            applicationId = "com.example.astro.instructor"
            resValue(type = "string", name = "app_name", value = "Instructor App")
        }
        create("admin") {
            dimension = "flavor-type"
            applicationId = "com.example.astro.admin"
            resValue(type = "string", name = "app_name", value = "Admin App")
        }
    }
}