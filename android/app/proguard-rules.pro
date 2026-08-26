# ==============================================================================
# Flutter ProGuard / R8 Rules for ClassTrack
# ==============================================================================

# Keep line numbers and source file attributes for actionable crash stack traces
-keepattributes SourceFile,LineNumberTable,*Annotation*,Signature,InnerClasses,EnclosingMethod

# Flutter Engine & Wrapper bindings
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Flutter JNI native method entries
-keepclasseswithmembernames class * {
    native <methods>;
}

# Flutter embedding v2
-keep class * implements io.flutter.embedding.engine.plugins.FlutterPlugin { *; }
-keep class * implements io.flutter.embedding.engine.plugins.activity.ActivityAware { *; }
-dontwarn com.google.android.play.core.**

# ------------------------------------------------------------------------------
# SQFlite & Database Rules
# ------------------------------------------------------------------------------
-keep class com.tekartik.sqflite.** { *; }
-dontwarn com.tekartik.sqflite.**

# ------------------------------------------------------------------------------
# Flutter Local Notifications & Alarm Receivers
# ------------------------------------------------------------------------------
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver { *; }
-keep class com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver { *; }
-dontwarn com.dexterous.flutterlocalnotifications.**

# ------------------------------------------------------------------------------
# Share Plus, File Picker & Path Provider
# ------------------------------------------------------------------------------
-keep class dev.fluttercommunity.plus.share.** { *; }
-keep class com.mr.flutter.plugin.filepicker.** { *; }
-keep class io.flutter.plugins.pathprovider.** { *; }
-dontwarn dev.fluttercommunity.plus.share.**
-dontwarn com.mr.flutter.plugin.filepicker.**
-dontwarn io.flutter.plugins.pathprovider.**

# ------------------------------------------------------------------------------
# Java Desugaring & Time API Rules
# ------------------------------------------------------------------------------
-keep class j$.time.** { *; }
-keep class java.time.** { *; }
-dontwarn j$.**
-dontwarn java.time.**

# ------------------------------------------------------------------------------
# General Serialization & Reflection Safeguards
# ------------------------------------------------------------------------------
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

-dontnote **
