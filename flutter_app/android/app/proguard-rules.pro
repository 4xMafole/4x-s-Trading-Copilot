# google_mlkit_text_recognition references optional language-specific recognizer
# classes that are only present when the corresponding ML Kit sub-packages are
# included. We only use latin script recognition, so these are genuinely absent
# at runtime but never called. Tell R8 to ignore them.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
