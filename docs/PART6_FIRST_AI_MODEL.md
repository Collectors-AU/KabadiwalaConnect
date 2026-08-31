# Part 6: The first AI model

## The recommendation

**Build an e-waste image classifier using transfer learning on MobileNetV2.**

Everything else comes later or never.

---

## The full specification

### What exactly this model does

A collector photographs a pile of scrap with their phone camera. The model classifies the image into one of 8 material categories: CRT, LCD, PCB, CABLE, BATTERY, MOTOR, MAGNET_ASSEMBLY, MIXED_PLASTIC. It returns the top prediction with a confidence score, plus 2 alternative predictions ranked by likelihood.

This replaces the current demo classifier, which matches keywords in filenames and returns hardcoded confidence values.

### Model definition

| Field | Value |
|-------|-------|
| Task | Single-label image classification, 8 classes |
| Input | RGB image, resized to 224x224 pixels |
| Output | Probability distribution over 8 material categories |
| Architecture | MobileNetV2 with custom classification head |
| Pretrained base | MobileNetV2 trained on ImageNet (available in TensorFlow/Keras and PyTorch) |
| Custom head | GlobalAveragePooling2D -> Dropout(0.3) -> Dense(128, ReLU) -> Dropout(0.2) -> Dense(8, Softmax) |
| Framework | TensorFlow/Keras (for TFLite export compatibility) |
| Export format | TensorFlow Lite (.tflite) for on-device inference |

### Why this model first

1. **It replaces the weakest component.** The demo classifier is the only part of the system that admits it isn't doing what it claims. The price engine uses real statistics. The matcher uses a real scoring formula. The anomaly detector uses real thresholds. Only the classifier is faking it.

2. **It's the entry point of the user flow.** Everything downstream (pricing, matching, aggregation) depends on correct material identification. A wrong classification cascades errors through the entire pipeline.

3. **It's the most demonstrable feature.** In a hackathon demo, "point your phone at scrap and it identifies the material" is the showpiece moment. A working classifier makes the entire platform feel real.

4. **It works offline.** A TFLite model runs on-device without network connectivity. This matters for the app's offline-first story. A collector in a low-connectivity area can still classify material.

5. **It's achievable.** MobileNetV2 transfer learning is one of the best-documented ML workflows available. TensorFlow's official tutorials cover this exact pattern. A student team can follow the workflow.

6. **The interface already exists.** The `classifier.py` module has a clean interface. The mobile app has the camera/gallery flow. You're replacing guts, not building new UX.

7. **Every other ML component either doesn't need ML or doesn't have data.** That's the blunt truth. Image classification is the one place where (a) ML is genuinely required and (b) a small team can realistically build something.

### Why NOT other candidates

**Price prediction ML**: The statistical engine (median + condition + weight bonus) outperforms any model you could train on 30 observations. ML prediction needs thousands of transactions. Wait until you have them. The current engine is honest and sound.

**Fraud detection ML**: The threshold detector catches obvious anomalies. ML anomaly detection (isolation forest, autoencoder) needs a baseline of "normal" activity, which doesn't exist. You'd train on synthetic data and produce garbage.

**Recycler recommendation ML**: The weighted scoring formula is interpretable and works with zero training data. Collaborative filtering needs hundreds of user-recycler transactions. You have zero.

**Object detection (multi-item)**: Bounding box annotation is 5-10x more expensive than classification labels. YOLOv8 fine-tuning is feasible but the data investment is prohibitive. Classification in isolation gets you 90% of the value at 20% of the cost.

**Voice/STT**: Use the device's built-in speech recognition API. No custom model needed. This doesn't count as "building AI."

**Demand forecasting**: 90 days of seeded data cannot train a time series model. Keep the trend indicator.

---

## Data strategy

### Minimum viable dataset

**200 images total, 25 per class, collected from the field.**

This is the minimum for a hackathon demo. Transfer learning from ImageNet can produce reasonable accuracy with this little data when combined with aggressive augmentation. It won't be production-quality, but it'll be real.

Where to get 200 images:
- **Field collection (primary)**: Visit 2-3 kabadiwala shops. Photograph their stock. Each shop typically has sorted piles of cables, PCBs, batteries, motors, etc. One afternoon of fieldwork per shop yields 50-100 usable images.
- **Web scraping (secondary)**: Search Google Images, YouTube screenshots, and Alibaba/IndiaMart product listings for e-waste categories. Quality will be mixed because these show clean product photos, not messy scrap piles.
- **Team-generated**: If team members have old electronics at home, photograph them in various conditions and lighting.

### Ideal dataset (post-hackathon)

**2,000-5,000 images, 250-600+ per class, from diverse collection points.**

This means partnering with multiple kabadiwala cooperatives across different cities. Different material conditions, lighting, backgrounds, and phone cameras. This is a 2-3 month effort.

### Annotation requirements

**Simple.** Each image gets one label from the 8 categories. No bounding boxes, no segmentation masks, no pixel-level annotations. One image, one label. A team member who knows the categories can label 100 images per hour.

Annotation tool: a shared Google Sheet or a folder structure where each subfolder is a category. Drop images into folders. That's it.

The hard cases are "mixed" images (a pile with cables and PCBs and plastic casings). Labeling rule: use the dominant material. If there's no dominant material, label it MIXED_PLASTIC as a catch-all, or exclude it from training and add a "Mixed/Other" category later.

### Data quality requirements

- Minimum resolution: 640x480 (most phone cameras exceed this)
- Must include: different lighting conditions (indoor, outdoor, shade, direct sunlight)
- Must include: different angles (top-down, angled, close-up, medium distance)
- Must include: different backgrounds (ground, table, bag, scale, hand-held)
- Should include: dirty/worn material, not just clean samples
- Should include: small quantities and large piles

---

## Training approach

### Phase 1: Feature extraction (freeze base)

1. Load MobileNetV2 pretrained on ImageNet
2. Freeze all convolutional layers
3. Replace the top classification head with: GAP -> Dense(128) -> Dense(8)
4. Train only the new head for 20-30 epochs
5. Use Adam optimizer, learning rate 1e-3
6. Use categorical crossentropy loss
7. Apply data augmentation: random rotation (20 degrees), horizontal flip, brightness/contrast jitter, random zoom (10%), random crop

This phase teaches the new head to map ImageNet features to your 8 categories. It's fast (minutes on a laptop) and hard to overfit.

### Phase 2: Fine-tuning (partial unfreeze)

1. Unfreeze the last 20-30 layers of MobileNetV2
2. Lower learning rate to 1e-5 (important: fine-tuning with high LR destroys pretrained features)
3. Train for 10-20 more epochs
4. Monitor validation loss. Stop when it plateaus or increases.

This phase lets the model adapt its feature extraction to e-waste visual patterns. The earlier layers (edges, textures) stay frozen because they're general-purpose. The later layers learn domain-specific features.

### Phase 3: Export

1. Convert the Keras model to TFLite: `tf.lite.TFLiteConverter.from_keras_model(model)`
2. Apply post-training quantization (int8) to reduce model size: ~15MB -> ~4MB
3. Verify TFLite accuracy matches Keras model within 1-2%
4. Bundle the .tflite file with the mobile app

### Training infrastructure

A laptop with a GPU trains this in under an hour. Without a GPU, 2-4 hours. Google Colab (free tier) has a GPU and works fine. No cloud training infrastructure needed.

### Data split

- 70% training
- 15% validation (for monitoring during training)
- 15% test (held-out, never seen during training, used only for final evaluation)

With 200 images: 140 train, 30 validation, 30 test. This is thin for statistical significance, but it's what you have.

With stratified splitting: ensure each class appears proportionally in all three sets.

---

## Evaluation

### Metrics

| Metric | Purpose |
|--------|---------|
| Overall accuracy | What % of images are correctly classified? |
| Per-class precision | When the model says "PCB," how often is it right? |
| Per-class recall | Of all PCB images, how many does the model find? |
| Confusion matrix | Which classes get confused with each other? |
| Top-2 accuracy | Is the correct class in the model's top 2 predictions? |
| Confidence calibration | Does 0.8 confidence mean 80% of those predictions are correct? |

### Target accuracy for MVP

| Metric | Target | Acceptable | Unacceptable |
|--------|--------|------------|--------------|
| Top-1 accuracy | >75% | >65% | <50% |
| Top-2 accuracy | >90% | >80% | <65% |
| Per-class recall (min) | >60% | >50% | <40% |

**Why 75% is enough for MVP**: The app shows a confirmation screen ("Detected: PCB. Is this correct? YES / CHANGE"). If the model is right 75% of the time, 3 out of 4 users just tap YES. The other taps CHANGE and selects from a list. That's still massively better than always picking from a list manually, which is the current fallback.

**Why top-2 accuracy matters more at this stage**: If the correct answer is in the top 2, the user sees it prominently and taps it. 90% top-2 means the model is genuinely helpful even when it's not perfect.

### Known evaluation risks

- Small test set means accuracy has wide confidence intervals. 30 test images per class means each correct/incorrect prediction swings accuracy by 3+ percentage points.
- Classes with visual similarity (CABLE vs MOTOR, because motors contain wire coils) will likely show confusion.
- CRT is visually distinct (bulky, glass). BATTERY is visually distinct (cylindrical or rectangular, labeled). CABLE is long and thin. These will likely be the easy classes. PCB vs MIXED_PLASTIC will be harder.

---

## Inference

### On-device (primary)

- Runtime: TensorFlow Lite on React Native via `@tensorflow/tfjs-react-native` or `react-native-tflite`
- Model bundled with the app
- Inference time: <200ms on a mid-range phone
- No network required
- Preprocessing: resize to 224x224, normalize pixel values to [0,1] or [-1,1] depending on MobileNetV2 configuration

### Server-side (fallback/alternative)

- FastAPI endpoint that accepts an uploaded image
- Uses the full TensorFlow/Keras model
- Returns the same JSON format as the current demo classifier
- Useful when the mobile TFLite integration isn't ready yet

### Integration path

The current `classifier.py` already defines the interface:
```python
{
    "category": "PCB",
    "confidence": 0.85,
    "alternatives": [
        {"category": "CABLE", "confidence": 0.10},
        {"category": "MIXED_PLASTIC", "confidence": 0.05}
    ]
}
```

The real classifier returns the same structure. Replace the guts, keep the interface. Backend change is one function swap. Mobile needs TFLite integration, which is a 2-3 day task.

---

## Difficulty and timeline

| Phase | Effort | Dependencies |
|-------|--------|-------------|
| Data collection (field) | 2-3 days | Physical access to e-waste collection points |
| Data collection (web) | 1 day | Just internet |
| Data labeling | 0.5 day | Someone who knows the 8 categories |
| Training pipeline setup | 1 day | Python, TensorFlow, Colab |
| Training and evaluation | 1 day | GPU (Colab free tier) |
| TFLite export | 0.5 day | TensorFlow |
| Server integration | 0.5 day | Replace classifier.py |
| Mobile TFLite integration | 2-3 days | React Native TFLite bridge |
| Testing and tuning | 1-2 days | Field testing with real material |
| **Total** | **9-13 days** | One person working on this |

### Estimated difficulty: Moderate

The ML part is straightforward (transfer learning is well-documented). The hard parts are:
1. Getting enough diverse training images from actual collection points
2. Making TFLite work reliably in React Native (bridge libraries can be finicky with Expo)
3. Handling edge cases: blurry photos, mixed piles, extreme lighting

### What could go wrong

- **Expo compatibility**: TFLite inference might require a custom development build (not Expo Go). This adds a day of setup.
- **Low accuracy on certain classes**: If PCB and MIXED_PLASTIC are hard to distinguish, you might merge them or add visual guidance ("Show the green board side").
- **Deployment size**: The model adds 4-15MB to app size, depending on quantization. Acceptable for most phones but worth noting.
- **Inference latency**: On very old phones (Android 7, low RAM), TFLite inference might take 1-2 seconds. Still usable but feels slow.

---

## Improvement path

After the MVP model works:

1. **Collect more data from real users.** Every time a user corrects the model ("No, this is CABLE, not PCB"), log the image + correct label with consent. This creates a feedback loop.

2. **Active learning.** Prioritize images where the model is uncertain (confidence between 0.3-0.6) for human labeling. This is the most efficient way to improve accuracy.

3. **Expand categories.** Sub-types like "copper cable vs aluminum cable" or "lithium battery vs lead-acid battery" become feasible once you have 500+ images per class.

4. **Upgrade the base model.** EfficientNet-Lite is slightly better than MobileNetV2 at similar size. Try it after you have enough data to see the difference.

5. **Multi-label classification.** A pile with cables AND PCBs gets labeled as both. This requires changing the loss function and output layer, and annotating images with multiple labels.

