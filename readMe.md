# Refined Shape Detection

A MATLAB-based computer vision tool designed to identify, segment, and classify basic geometric shapes. This project utilizes classic image processing techniques, including **Watershed Transformation** and **Region Properties**, to differentiate between circles, squares, triangles, and rectangles.



## 🚀 Features

* **Adaptive Pre-processing:** Automatically detects image type (Grayscale vs. RGB) and applies HSV conversion and contrast adjustment for better feature visibility.
* **Watershed Segmentation:** Implements distance transforms and local minima suppression to accurately separate touching or overlapping objects.
* **Geometric Classification:** Employs RBC-inspired (Recognition-by-Components) metrics:
    * **Circularity:** Uses $\frac{P^2}{A}$ to identify circular objects.
    * **Extent:** Compares shape area to bounding box area to isolate triangles.
    * **Aspect Ratio:** Differentiates between squares and rectangles.
* **Interactive Visualization:** Displays a side-by-side comparison of the segmentation process and a final annotated output with red boundary outlines.

## 🛠 Prerequisites

* MATLAB (R2018b or newer)
* **Image Processing Toolbox**

## 📂 Usage

1.  **Download:** Save `refined_shape_detection.m` to your MATLAB directory.
2.  **Run:** Type the following in your Command Window:
    ```matlab
    refined_shape_detection
    ```
3.  **Select Image:** A file browser will appear. Select a `.jpg`, `.png`, or `.bmp` file.
4.  **View Results:** * **Figure 1:** Shows the original image vs. the segmented "label matrix" (colored by object).
    * **Figure 2:** Displays the final classification, area, perimeter, and aspect ratio for every detected shape.

## ⚙️ How It Works

The script follows a robust pipeline common in Mechatronics and robotic vision:

| Step | Method | Purpose |
| :--- | :--- | :--- |
| **1. Prep** | `imadjust` & `imbinarize` | Clean the signal and create a binary mask. |
| **2. Split** | `watershed` | Uses the Euclidean distance transform to find "peaks" in shapes and separate them. |
| **3. Extract** | `regionprops` | Measures physical properties like Centroid, Area, and BoundingBox. |
| **4. Classify** | Logical Thresholds | Assigns a shape name based on calculated geometric constants. |

## 📊 Classification Metrics

The code uses the following logic for identification:
* **Circle:** $\frac{Perimeter^2}{Area} \approx 4\pi$
* **Square:** Aspect Ratio $\approx 1.0$ and High Extent.
* **Triangle:** Low Extent (typically $< 0.65$).
* **Rectangle:** High Extent with Aspect Ratio $\neq 1.0$.

---
*Developed for Tech & Software applications in Mechatronics.*