# TensorFlow Lite - Keep core and GPU delegate classes
-keep class org.tensorflow.** { *; }
-dontwarn org.tensorflow.**

# Keep classes used by GPU delegates
-keep class org.tensorflow.lite.gpu.** { *; }

# Keep your app and plugin classes
-keep class com.example.** { *; }

# Optional: for Firebase & Google services
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**
