from pathlib import Path
import random
import shutil

SEED = 42

TRAIN_RATIO = 0.70
VAL_RATIO = 0.15
TEST_RATIO = 0.15

CLASS_MAP = {
    "pcrhealthy": "Healthy",
    "pcrcocci": "Coccidiosis",
    "pcrncd": "Newcastle_Disease",
    "pcrsalmo": "Salmonellosis",
}

BASE_DIR = Path(__file__).resolve().parent.parent
RAW_DIR = BASE_DIR / "dataset" / "raw"
SPLIT_DIR = BASE_DIR / "dataset" / "splits"

random.seed(SEED)


def prepare_output_folders():
    if SPLIT_DIR.exists():
        shutil.rmtree(SPLIT_DIR)

    for split in ["train", "validation", "test"]:
        for class_name in CLASS_MAP.values():
            folder = SPLIT_DIR / split / class_name
            folder.mkdir(parents=True, exist_ok=True)


def copy_images():
    print("=" * 60)
    print("PoultryGuard Dataset Split")
    print("=" * 60)

    for source_folder_name, class_name in CLASS_MAP.items():
        source_folder = RAW_DIR / source_folder_name

        images = list(source_folder.glob("*.jpg"))

        random.shuffle(images)

        total = len(images)

        train_end = int(total * TRAIN_RATIO)
        val_end = train_end + int(total * VAL_RATIO)

        train_images = images[:train_end]
        val_images = images[train_end:val_end]
        test_images = images[val_end:]

        split_groups = {
            "train": train_images,
            "validation": val_images,
            "test": test_images,
        }

        print(f"\nClass: {class_name}")
        print(f"Total: {total}")

        for split_name, split_images in split_groups.items():
            destination_folder = (
                SPLIT_DIR
                / split_name
                / class_name
            )

            for image_path in split_images:
                shutil.copy2(
                    image_path,
                    destination_folder / image_path.name,
                )

            print(
                f"{split_name.capitalize()}: "
                f"{len(split_images)}"
            )


if __name__ == "__main__":
    prepare_output_folders()
    copy_images()

    print("\nDataset split completed successfully.")