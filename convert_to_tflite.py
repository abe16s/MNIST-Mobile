import tensorflow as tf

# Load the Keras H5 model
h5_model_path = "blood_sweat_tears.h5"
model = tf.keras.models.load_model(h5_model_path)

# Convert the model to TensorFlow Lite format
converter = tf.lite.TFLiteConverter.from_keras_model(model)
tflite_model = converter.convert()

# Save the TensorFlow Lite model
tflite_model_path = "blood_sweat_tears.tflite"
with open(tflite_model_path, "wb") as f:
    f.write(tflite_model)

print(f"Model converted and saved to {tflite_model_path}")
