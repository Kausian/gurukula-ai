# R8/ProGuard rules for the release build.

# Google ML Kit text recognition (Phase 14B): we bundle only the Latin script
# recognizer. The ML Kit SDK references the optional non-Latin recognizer option
# classes (Chinese, Devanagari, Japanese, Korean) which we deliberately do NOT
# include, so R8 must be told to ignore them rather than failing the build or
# pulling in extra OCR language dependencies.
-keep class com.google.mlkit.vision.text.** { *; }
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
