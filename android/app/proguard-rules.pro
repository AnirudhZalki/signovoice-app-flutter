# R8/ProGuard rules for release builds.

# ONNX Runtime (flutter_onnxruntime) — required by the plugin docs.
-keep class ai.onnxruntime.** { *; }

# MediaPipe Tasks (hand_landmarker) and its protobuf/JNI bindings.
-keep class com.google.mediapipe.** { *; }
-keep class com.google.protobuf.** { *; }
-dontwarn com.google.mediapipe.**
-dontwarn com.google.auto.value.**
-dontwarn javax.lang.model.**

# LiveKit / WebRTC
-keep class org.webrtc.** { *; }
-keep class livekit.org.webrtc.** { *; }
-dontwarn org.webrtc.**
-dontwarn livekit.org.webrtc.**

# Google Play Billing
-keep class com.android.vending.billing.** { *; }

# Keep line numbers for readable crash reports (Crashlytics de-obfuscates with the mapping file).
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# Razorpay checkout (razorpay_flutter) — keep SDK classes and annotations used by its WebView bridge.
-keepattributes JavascriptInterface
-keepattributes *Annotation*
-dontwarn com.razorpay.**
-keep class com.razorpay.** {*;}
-optimizations !method/inlining/*
-keepclasseswithmembers class * {
  public void onPayment*(...);
}
-dontwarn proguard.annotation.**
