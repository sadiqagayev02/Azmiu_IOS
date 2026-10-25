# ===========================================
# Tink kriptoqrafiya kitabxanası üçün
# (flutter_secure_storage istifadə edir)
# ===========================================
-keep class com.google.crypto.tink.** { *; }
-keep class com.google.errorprone.annotations.** { *; }
-keep class javax.annotation.** { *; }
-keep class javax.annotation.concurrent.** { *; }

# ===========================================
# Flutter Secure Storage üçün
# ===========================================
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# ===========================================
# WebView üçün
# ===========================================
-keep class android.webkit.** { *; }
-keep class androidx.webkit.** { *; }

# ===========================================
# Dio / OkHttp üçün
# ===========================================
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**

# ===========================================
# Ümumi
# ===========================================
-dontwarn com.google.errorprone.annotations.**