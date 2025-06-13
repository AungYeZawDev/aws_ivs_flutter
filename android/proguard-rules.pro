# AWS IVS Player SDK ProGuard Rules
# Keep all AWS IVS Player SDK classes
-keep class com.amazonaws.ivs.player.** { *; }
-dontwarn com.amazonaws.ivs.player.**

# Keep Flutter embedding classes
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**

# Keep plugin classes
-keep class com.example.aws_ivs_flutter.** { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep annotations
-keepattributes *Annotation*

# Keep line numbers for debugging
-keepattributes SourceFile,LineNumberTable

# Keep generic signatures
-keepattributes Signature

# AWS SDK common rules
-keep class com.amazonaws.** { *; }
-dontwarn com.amazonaws.**

# Android media classes
-keep class android.media.** { *; }
-dontwarn android.media.**

# Keep surface view and texture view classes
-keep class android.view.SurfaceView { *; }
-keep class android.view.TextureView { *; }

# Keep OpenGL classes if used
-keep class android.opengl.** { *; }
-dontwarn android.opengl.**