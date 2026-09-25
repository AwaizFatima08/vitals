# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Firebase / Firestore
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.firebase.** { *; }

# flutter_local_notifications serialises scheduled notifications with Gson;
# R8 must not strip/rename the generic type info it relies on.
-keep class com.dexterous.** { *; }
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken

# Play Core split-install: only used by Flutter's deferred-components
# feature, which this app doesn't use.
-dontwarn com.google.android.play.core.**
