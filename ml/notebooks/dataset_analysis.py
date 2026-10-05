from pathlib import Path
from PIL import Image

dataset_path = Path(__file__).resolve().parent.parent / "dataset" / "raw"

print("=" * 60)
print("PoultryGuard Dataset Analysis")
print("=" * 60)

total_images = 0

for folder in sorted(dataset_path.iterdir()):

    if not folder.is_dir():
        continue

    image_count = 0

    widths = []
    heights = []

    corrupted = 0

    for image_path in folder.glob("*"):

        try:
            image = Image.open(image_path)

            widths.append(image.width)
            heights.append(image.height)

            image_count += 1

        except Exception:
            corrupted += 1

    total_images += image_count

    print(f"\nClass: {folder.name}")

    print(f"Images: {image_count}")

    print(f"Corrupted: {corrupted}")

    print(f"Average Width : {sum(widths)//len(widths)}")

    print(f"Average Height: {sum(heights)//len(heights)}")

print("\nTotal Images:", total_images)