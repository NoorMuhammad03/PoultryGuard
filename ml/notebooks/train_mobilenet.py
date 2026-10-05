from pathlib import Path

import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers


# ---------------------------------------------------------
# Configuration
# ---------------------------------------------------------

BASE_DIR = Path(__file__).resolve().parent.parent

TRAIN_DIR = BASE_DIR / "dataset" / "splits" / "train"
VAL_DIR = BASE_DIR / "dataset" / "splits" / "validation"

MODEL_DIR = BASE_DIR / "models"
CHECKPOINT_DIR = MODEL_DIR / "checkpoints"
FINAL_DIR = MODEL_DIR / "final"

CHECKPOINT_DIR.mkdir(parents=True, exist_ok=True)
FINAL_DIR.mkdir(parents=True, exist_ok=True)

IMAGE_SIZE = (224, 224)
BATCH_SIZE = 16
EPOCHS = 20
SEED = 42


# ---------------------------------------------------------
# Load datasets
# ---------------------------------------------------------

print("=" * 60)
print("PoultryGuard - MobileNetV2 Training")
print("=" * 60)

print("\nLoading training dataset...")

train_dataset = keras.utils.image_dataset_from_directory(
    TRAIN_DIR,
    image_size=IMAGE_SIZE,
    batch_size=BATCH_SIZE,
    label_mode="categorical",
    shuffle=True,
    seed=SEED,
)

print("\nLoading validation dataset...")

validation_dataset = keras.utils.image_dataset_from_directory(
    VAL_DIR,
    image_size=IMAGE_SIZE,
    batch_size=BATCH_SIZE,
    label_mode="categorical",
    shuffle=False,
)

class_names = train_dataset.class_names
num_classes = len(class_names)

print("\nClasses detected:")

for index, class_name in enumerate(class_names):
    print(f"{index}: {class_name}")


# ---------------------------------------------------------
# Improve input pipeline
# ---------------------------------------------------------

AUTOTUNE = tf.data.AUTOTUNE

train_dataset = train_dataset.prefetch(
    buffer_size=AUTOTUNE
)

validation_dataset = validation_dataset.prefetch(
    buffer_size=AUTOTUNE
)


# ---------------------------------------------------------
# Data augmentation
# ---------------------------------------------------------

data_augmentation = keras.Sequential(
    [
        layers.RandomFlip("horizontal"),
        layers.RandomRotation(0.08),
        layers.RandomZoom(0.10),
        layers.RandomContrast(0.10),
    ],
    name="data_augmentation",
)


# ---------------------------------------------------------
# MobileNetV2 base
# ---------------------------------------------------------

print("\nLoading pretrained MobileNetV2...")

base_model = keras.applications.MobileNetV2(
    input_shape=(224, 224, 3),
    include_top=False,
    weights="imagenet",
)

# Stage 1: freeze pretrained convolutional layers.
base_model.trainable = False


# ---------------------------------------------------------
# Build classifier
# ---------------------------------------------------------

inputs = keras.Input(
    shape=(224, 224, 3),
    name="image",
)

x = data_augmentation(inputs)

x = keras.applications.mobilenet_v2.preprocess_input(x)

x = base_model(
    x,
    training=False,
)

x = layers.GlobalAveragePooling2D()(x)

x = layers.Dropout(0.30)(x)

outputs = layers.Dense(
    num_classes,
    activation="softmax",
    name="predictions",
)(x)

model = keras.Model(
    inputs,
    outputs,
    name="poultryguard_mobilenet_v2",
)


# ---------------------------------------------------------
# Compile
# ---------------------------------------------------------

model.compile(
    optimizer=keras.optimizers.Adam(
        learning_rate=0.001,
    ),
    loss="categorical_crossentropy",
    metrics=["accuracy"],
)

model.summary()


# ---------------------------------------------------------
# Class weights
# ---------------------------------------------------------

# Training counts from our fixed 70/15/15 split:
#
# Coccidiosis       = 261
# Healthy           = 242
# Newcastle_Disease = 130
# Salmonellosis     = 244
#
# Newcastle Disease is underrepresented, so class weights
# reduce the tendency to ignore the smaller class.

training_counts = {
    "Coccidiosis": 261,
    "Healthy": 242,
    "Newcastle_Disease": 130,
    "Salmonellosis": 244,
}

total_training_images = sum(training_counts.values())

class_weight = {}

for index, class_name in enumerate(class_names):
    count = training_counts[class_name]

    class_weight[index] = (
        total_training_images
        / (num_classes * count)
    )

print("\nClass weights:")

for index, weight in class_weight.items():
    print(
        f"{class_names[index]}: "
        f"{weight:.3f}"
    )


# ---------------------------------------------------------
# Callbacks
# ---------------------------------------------------------

checkpoint_path = (
    CHECKPOINT_DIR
    / "mobilenet_v2_stage1_best.keras"
)

callbacks = [
    keras.callbacks.ModelCheckpoint(
        filepath=checkpoint_path,
        monitor="val_accuracy",
        save_best_only=True,
        mode="max",
        verbose=1,
    ),

    keras.callbacks.EarlyStopping(
        monitor="val_loss",
        patience=5,
        restore_best_weights=True,
        verbose=1,
    ),

    keras.callbacks.ReduceLROnPlateau(
        monitor="val_loss",
        factor=0.2,
        patience=2,
        min_lr=1e-6,
        verbose=1,
    ),
]


# ---------------------------------------------------------
# Train
# ---------------------------------------------------------

print("\nStarting Stage 1 training...\n")

history = model.fit(
    train_dataset,
    validation_data=validation_dataset,
    epochs=EPOCHS,
    class_weight=class_weight,
    callbacks=callbacks,
)


# ---------------------------------------------------------
# Save final Stage 1 model
# ---------------------------------------------------------

final_model_path = (
    FINAL_DIR
    / "mobilenet_v2_stage1.keras"
)

model.save(final_model_path)

print("\n" + "=" * 60)
print("Stage 1 training complete")
print("=" * 60)

print(
    f"\nBest checkpoint:\n"
    f"{checkpoint_path}"
)

print(
    f"\nFinal model:\n"
    f"{final_model_path}"
)