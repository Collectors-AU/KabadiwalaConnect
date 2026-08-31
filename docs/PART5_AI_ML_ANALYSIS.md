# Part 5: AI/ML component analysis

## Reality check before we start

The team has zero labeled e-waste images, zero transaction history outside seeded demo data, zero real users, and a hackathon timeline. Every recommendation below is filtered through that reality. A model that would be amazing with 50,000 labeled images is worthless when you have none.

The current system is honest about what it does. The demo classifier is keyword matching. The price engine is statistics. The recycler matcher is weighted scoring. The anomaly detector is threshold comparison. These all work fine for their purpose. The question is which of them would genuinely benefit from ML, and which are better left as deterministic logic.

---

## Component 1: E-waste image classification

**What problem does it solve?** A collector photographs scrap material. The system identifies what it is (PCB, cable, battery, etc.) so the rest of the pipeline can price it and match recyclers. Currently faked with keyword matching on filenames.

**Is ML actually necessary?** Yes. This is the one feature where ML has an irreplaceable role. No lookup table or rule set can extract material category from a photograph. Humans do this through visual pattern recognition, and ML replicates that.

**Could rules/API/database logic solve it?** No. You can't classify an arbitrary image of e-waste scrap with if/else statements.

**What training data is required?** Labeled images of e-waste in 8 categories. Needs to handle messy, informal collection contexts: scrap piles, mixed lighting, dirty material, plastic bags, hands in frame.

**How much data is realistically available?** Near zero for Indian informal e-waste. No public dataset exists for this specific domain. General e-waste datasets exist but don't match the visual conditions of a kabadiwala's collection. You'd need to photograph material at actual collection points. Realistically 50-200 images from team fieldwork, maybe 500-1000 with web scraping and creative augmentation.

**Can a student team build it?** Yes, with transfer learning. Fine-tuning MobileNetV2 or EfficientNet-Lite on even a small dataset (100-200 images per class) can produce usable accuracy for a demo. The training pipeline is well-documented. The challenge is data collection, not model architecture.

**Can it run on-device?** Yes. TensorFlow Lite and ONNX Runtime both support mobile inference. MobileNetV2 is literally designed for this. Model size would be 5-15MB.

**Can it work offline?** Yes. On-device inference needs no network connection. This is a major selling point.

**How difficult is evaluation?** Easy in principle: accuracy, precision, recall per class, confusion matrix. Hard in practice because test data suffers the same scarcity as training data, and the categories are sometimes genuinely ambiguous (a motor with cables and plastic casing touches 3 categories).

**What is its MVP value?** High. It's the entry point of the entire user flow. Without it, the collector manually selects the material category, which still works but isn't impressive.

**What is its hackathon/demo value?** Very high. "Point your phone at scrap, it identifies the material" is the most visually impressive capability you can demo. Demo judges will remember this.

**What is its long-term business value?** High. Accurate automatic classification reduces errors in pricing, improves recycler matching, and enables quality assessment over time.

| Criterion | Score (1-5) |
|-----------|-------------|
| Impact | 5 |
| Feasibility | 3 |
| Data availability | 2 |
| Differentiation | 5 |
| MVP usefulness | 4 |

**Weighted priority = (5*0.25 + 3*0.25 + 2*0.2 + 5*0.15 + 4*0.15) = 1.25 + 0.75 + 0.4 + 0.75 + 0.6 = 3.75**

---

## Component 2: Object detection (multi-object in frame)

**What problem does it solve?** A collector has a pile of mixed scrap. Instead of photographing each item, detect and label multiple objects in a single image. Draw bounding boxes around the PCB, cables, battery, etc.

**Is ML actually necessary?** Yes. Multi-object detection in unstructured scenes requires ML.

**Could rules/API/database logic solve it?** No.

**What training data is required?** Images with bounding box annotations for each object. Annotation is 5-10x more expensive than classification labels because each image needs multiple boxes drawn precisely.

**How much data is realistically available?** Effectively zero. Bounding box annotation for e-waste scrap piles? The team would need to annotate hundreds of images by hand with a tool like LabelImg. For a hackathon timeline, this is a non-starter.

**Can a student team build it?** Not well. YOLOv8 nano exists and is fine-tunable, but the annotation burden makes this impractical.

**Can it run on-device?** Yes, but inference is slower than classification.

**Can it work offline?** Yes.

**How difficult is evaluation?** Hard. mAP evaluation needs a properly annotated test set. The team won't have one.

**What is its MVP value?** Low. Most collectors will photograph individual items or small groups. Single-class classification covers 90% of cases. Object detection is a "nice to have" that doesn't unlock new functionality.

**What is its hackathon/demo value?** Medium. Bounding boxes look cool but the effort-to-payoff ratio is bad.

**What is its long-term business value?** Medium. Useful for inventory management and mixed-lot assessment at scale, but classification comes first.

| Criterion | Score (1-5) |
|-----------|-------------|
| Impact | 3 |
| Feasibility | 2 |
| Data availability | 1 |
| Differentiation | 3 |
| MVP usefulness | 2 |

**Weighted priority = (3*0.25 + 2*0.25 + 1*0.2 + 3*0.15 + 2*0.15) = 0.75 + 0.5 + 0.2 + 0.45 + 0.3 = 2.20**

---

## Component 3: OCR (text extraction from labels/serial numbers)

**What problem does it solve?** Read serial numbers, brand names, model numbers, or hazard labels from e-waste. Could help with product identification and traceability.

**Is ML actually necessary?** Sort of, but you don't train it yourself. Off-the-shelf OCR works fine.

**Could rules/API/database logic solve it?** Use Google ML Kit, Apple Vision framework, or Tesseract. All are free, offline-capable, and battle-tested. No custom ML needed.

**What training data is required?** None for off-the-shelf OCR. Custom fine-tuning (for worn/dirty labels) would need annotated text images from the field.

**How much data is realistically available?** Not relevant since you'd use a pretrained OCR engine.

**Can a student team build it?** Yes, trivially, by integrating an existing library.

**Can it run on-device?** Yes. Google ML Kit and Apple Vision are on-device.

**Can it work offline?** Yes.

**How difficult is evaluation?** Easy. Character accuracy and field extraction accuracy on test images.

**What is its MVP value?** Low. The current 8-category system doesn't need serial numbers. OCR would be useful for tracking specific products, but that's a secondary feature.

**What is its hackathon/demo value?** Low. "It can read text" isn't impressive in 2025. Everyone's phone can do this.

**What is its long-term business value?** Medium. Serial number tracking enables product-level traceability and could connect to manufacturer take-back programs.

| Criterion | Score (1-5) |
|-----------|-------------|
| Impact | 2 |
| Feasibility | 5 |
| Data availability | 5 |
| Differentiation | 1 |
| MVP usefulness | 2 |

**Weighted priority = (2*0.25 + 5*0.25 + 5*0.2 + 1*0.15 + 2*0.15) = 0.5 + 1.25 + 1.0 + 0.15 + 0.3 = 3.20**

---

## Component 4: Material sub-classification (beyond 8 categories)

**What problem does it solve?** Distinguish between types within a category. For example: FR-4 PCB vs aluminum PCB, lithium-ion vs lead-acid battery, copper cable vs aluminum cable. Different sub-types have very different recycling values.

**Is ML actually necessary?** Partially. Some sub-classification can be done with visual inspection + user input (dropdown after classification). Full automation would need ML, but there's a middle ground.

**Could rules/API/database logic solve it?** Partially. After identifying "battery," show a quick picker: "Lithium-ion, Lead-acid, or NiCd?" Most collectors know this because it affects their pricing. A few guided questions replaces complex ML.

**What training data is required?** Fine-grained labeled images distinguishing sub-types. Much harder than the 8-category problem because visual differences between PCB sub-types are subtle.

**How much data is realistically available?** Near zero. Sub-type labeling requires domain expertise.

**Can a student team build it?** Not reliably.

**Can it run on-device?** Yes, if built.

**Can it work offline?** Yes.

**How difficult is evaluation?** Hard. Fine-grained classification evaluation needs expert labels.

**What is its MVP value?** Low. The 8 categories are sufficient for MVP pricing and matching.

**What is its hackathon/demo value?** Low. Adds complexity without proportional demo impact.

**What is its long-term business value?** High. Sub-type pricing differences can be 2-5x. This matters for fair pricing at scale.

| Criterion | Score (1-5) |
|-----------|-------------|
| Impact | 3 |
| Feasibility | 2 |
| Data availability | 1 |
| Differentiation | 3 |
| MVP usefulness | 1 |

**Weighted priority = (3*0.25 + 2*0.25 + 1*0.2 + 3*0.15 + 1*0.15) = 0.75 + 0.5 + 0.2 + 0.45 + 0.15 = 2.05**

---

## Component 5: Scrap quality/condition assessment from images

**What problem does it solve?** Determine whether scrap is in GOOD, FAIR, POOR, or MIXED condition from a photo. Currently the collector manually selects condition.

**Is ML actually necessary?** Debatable. "Condition" for scrap is complex and subjective. A PCB with corroded solder points looks different from a clean one, but what constitutes "FAIR" vs "POOR" is a judgment call that varies by recycler.

**Could rules/API/database logic solve it?** Partially. A simple UI with visual examples ("Does your material look more like Photo A, B, or C?") might be more reliable than a model trained on ambiguous labels.

**What training data is required?** Images labeled with expert-assessed condition grades. This labeling requires recycling industry knowledge.

**How much data is realistically available?** Zero. You'd need recyclers to rate photos, and you don't have recycler partnerships yet.

**Can a student team build it?** Probably not to useful accuracy.

**Can it run on-device?** Yes.

**Can it work offline?** Yes.

**How difficult is evaluation?** Hard. Inter-annotator agreement on condition grades is likely low.

**What is its MVP value?** Very low. Manual condition selection works fine and might be more accurate than a weak model.

**What is its hackathon/demo value?** Low. Hard to demo convincingly because the "correct" answer is arguable.

**What is its long-term business value?** Medium. Automated condition assessment could reduce disputes between collectors and recyclers about pricing.

| Criterion | Score (1-5) |
|-----------|-------------|
| Impact | 2 |
| Feasibility | 2 |
| Data availability | 1 |
| Differentiation | 2 |
| MVP usefulness | 1 |

**Weighted priority = (2*0.25 + 2*0.25 + 1*0.2 + 2*0.15 + 1*0.15) = 0.5 + 0.5 + 0.2 + 0.3 + 0.15 = 1.65**

---

## Component 6: Weight estimation from images

**What problem does it solve?** Estimate the weight of scrap from a photo instead of requiring manual entry or a scale. Reduces friction in the listing flow.

**Is ML actually necessary?** Yes. Estimating weight from a 2D image requires understanding scale, density, and material type. This is an active research problem even for simpler domains.

**Could rules/API/database logic solve it?** No. Weight estimation from images is fundamentally a perception problem.

**What training data is required?** Images of scrap paired with actual weighed values. You'd need a known reference object in frame for scale, plus material-specific density models.

**How much data is realistically available?** Zero. You'd need to systematically photograph and weigh hundreds of scrap lots. This is a field study.

**Can a student team build it?** No. This is a research-level problem. Even well-funded companies haven't solved it well for irregular objects.

**Can it run on-device?** If it existed, yes.

**Can it work offline?** If it existed, yes.

**How difficult is evaluation?** Very hard. Weight estimation accuracy for irregular scrap piles? You'd need a test set with ground-truth weights, and the variance would be enormous.

**What is its MVP value?** Very low. Manual weight entry works fine. Collectors often have approximate weights from experience, and final weight is verified at handover anyway.

**What is its hackathon/demo value?** Low. Hard to demo convincingly because the estimate would likely be wildly wrong.

**What is its long-term business value?** Low. The handover process already involves weighing. Pre-estimate is just a convenience.

| Criterion | Score (1-5) |
|-----------|-------------|
| Impact | 2 |
| Feasibility | 1 |
| Data availability | 1 |
| Differentiation | 3 |
| MVP usefulness | 1 |

**Weighted priority = (2*0.25 + 1*0.25 + 1*0.2 + 3*0.15 + 1*0.15) = 0.5 + 0.25 + 0.2 + 0.45 + 0.15 = 1.55**

---

## Component 7: Price prediction (ML-based)

**What problem does it solve?** Predict fair market price for a material type at a given location and time, using historical transaction data. Go beyond the current statistical median.

**Is ML actually necessary?** Not yet. The current statistical approach (median of observations, condition adjustment, weight bonus) is sound and interpretable. ML price prediction needs enough transaction data to learn patterns that simple statistics miss: seasonal trends, regional variation, supply shocks.

**Could rules/API/database logic solve it?** Yes, and it already does, effectively. The current engine uses percentiles, trend detection, and condition factors. This is good enough.

**What training data is required?** Hundreds to thousands of real transactions per material category, spanning multiple months, with location and condition data.

**How much data is realistically available?** Currently: seeded demo data only. In production: you'd need 6-12 months of real transactions before ML adds value over simple statistics. The platform doesn't exist yet.

**Can a student team build it?** Yes, technically. Gradient-boosted trees (XGBoost) on tabular data is straightforward. But the model would be worse than the current statistics until you have enough data.

**Can it run on-device?** Not necessary. Price calculation happens server-side or from cached data.

**Can it work offline?** Use cached prices. The prediction model doesn't need to run offline.

**How difficult is evaluation?** Easy in principle: MAE, MAPE against held-out transactions. But you need enough transactions to have a meaningful test set.

**What is its MVP value?** Zero. The current statistical engine works better with sparse data.

**What is its hackathon/demo value?** Low. The output looks the same to the user. Nobody can tell if the number came from a median calculation or a gradient boosted tree.

**What is its long-term business value?** High. With enough data, ML can capture supply/demand dynamics, seasonal patterns, and regional price arbitrage that simple statistics miss.

| Criterion | Score (1-5) |
|-----------|-------------|
| Impact | 3 |
| Feasibility | 3 |
| Data availability | 1 |
| Differentiation | 2 |
| MVP usefulness | 1 |

**Weighted priority = (3*0.25 + 3*0.25 + 1*0.2 + 2*0.15 + 1*0.15) = 0.75 + 0.75 + 0.2 + 0.3 + 0.15 = 2.15**

---

## Component 8: Recycler recommendation (ML-based)

**What problem does it solve?** Replace the weighted scoring formula with a learned model that predicts which recycler a collector would prefer, based on past choices.

**Is ML actually necessary?** No. The current weighted scoring works well and is interpretable. ML recommendation requires user interaction history. Without it, a learned model would be worse than the handcrafted formula.

**Could rules/API/database logic solve it?** Already does. The weighted scoring formula (material 30%, auth 25%, price 20%, distance 15%, pickup 10%) produces reasonable rankings. The weights could be tuned based on data, but that's parameter optimization, not ML.

**What training data is required?** Completed transactions showing which recycler each collector chose from their options. Implicit feedback from skipped offers. Hundreds of transactions minimum.

**How much data is realistically available?** Zero. No real transactions exist.

**Can a student team build it?** The model yes. Getting the data no.

**Can it run on-device?** Not needed. Server-side feature.

**Can it work offline?** Cached recycler list + client-side scoring is sufficient.

**How difficult is evaluation?** Moderate. NDCG or hit-rate against held-out choices.

**What is its MVP value?** Zero. The current formula is fine.

**What is its hackathon/demo value?** Zero. The ranking looks the same to the user.

**What is its long-term business value?** Medium. Personalized recommendations could increase match rates, but the current formula would need to fail first to justify the switch.

| Criterion | Score (1-5) |
|-----------|-------------|
| Impact | 2 |
| Feasibility | 3 |
| Data availability | 1 |
| Differentiation | 1 |
| MVP usefulness | 1 |

**Weighted priority = (2*0.25 + 3*0.25 + 1*0.2 + 1*0.15 + 1*0.15) = 0.5 + 0.75 + 0.2 + 0.15 + 0.15 = 1.75**

---

## Component 9: Route optimization

**What problem does it solve?** Optimize pickup routes when a recycler needs to collect from multiple collectors. Minimize distance or travel time.

**Is ML actually necessary?** No. This is the Traveling Salesman Problem / Vehicle Routing Problem. It's a well-solved optimization problem, not an ML problem. Use Google OR-Tools, OSRM, or Google Directions API.

**Could rules/API/database logic solve it?** Yes. OR-Tools handles VRP with time windows, capacity constraints, and multi-vehicle routing out of the box.

**What training data is required?** None. This is optimization, not learning.

**How much data is realistically available?** Not relevant. You need locations and road networks, which mapping APIs provide.

**Can a student team build it?** Yes, using existing optimization libraries. OR-Tools has Python bindings and good documentation.

**Can it run on-device?** Small instances yes. Larger problems should run server-side.

**Can it work offline?** Not well. Needs road network data.

**How difficult is evaluation?** Easy. Total distance/time compared to naive routing.

**What is its MVP value?** Low. With 5 demo recyclers and small service areas, manual routing is fine.

**What is its hackathon/demo value?** Medium. A map showing an optimized route looks good in a presentation, but it's not AI.

**What is its long-term business value?** Medium. Real value kicks in when recyclers handle 10+ pickups per day across a metro area.

| Criterion | Score (1-5) |
|-----------|-------------|
| Impact | 2 |
| Feasibility | 4 |
| Data availability | 5 |
| Differentiation | 1 |
| MVP usefulness | 1 |

**Weighted priority = (2*0.25 + 4*0.25 + 5*0.2 + 1*0.15 + 1*0.15) = 0.5 + 1.0 + 1.0 + 0.15 + 0.15 = 2.80**

---

## Component 10: Fraud/anomaly detection (ML-based)

**What problem does it solve?** Detect fraudulent transactions, price manipulation, fake listings, or systematic underpayment patterns. Go beyond the current threshold-based checks.

**Is ML actually necessary?** Not yet. The current threshold detector (price <70% avg, weight discrepancy >20%, speed <10min) catches the obvious cases. ML anomaly detection (isolation forests, autoencoders) would catch subtler patterns, but those patterns don't exist in a system with zero real transactions.

**Could rules/API/database logic solve it?** Already does, adequately. Add more thresholds as new fraud patterns emerge. That's cheaper and more explainable than an ML model.

**What training data is required?** Transaction data with labeled fraud cases. Fraud labels are extremely rare and expensive to obtain. Most anomaly detection systems start with unsupervised methods, which need thousands of "normal" transactions to define what normal looks like.

**How much data is realistically available?** Zero real transactions. No fraud cases to learn from.

**Can a student team build it?** The unsupervised approach, yes. Isolation Forest from scikit-learn is a few lines of code. But it would learn from demo data, which is meaningless.

**Can it run on-device?** Not needed. Server-side analysis.

**Can it work offline?** Not relevant.

**How difficult is evaluation?** Very hard. Fraud detection evaluation without real fraud data is impossible.

**What is its MVP value?** Zero. The threshold detector works.

**What is its hackathon/demo value?** Low. "Our system detects fraud" sounds good in a pitch, but the current thresholds already accomplish that for the demo.

**What is its long-term business value?** High. Real platforms need real fraud detection. But you build it after you have real fraud to detect.

| Criterion | Score (1-5) |
|-----------|-------------|
| Impact | 3 |
| Feasibility | 3 |
| Data availability | 1 |
| Differentiation | 2 |
| MVP usefulness | 1 |

**Weighted priority = (3*0.25 + 3*0.25 + 1*0.2 + 2*0.15 + 1*0.15) = 0.75 + 0.75 + 0.2 + 0.3 + 0.15 = 2.15**

---

## Component 11: Demand prediction / price forecasting

**What problem does it solve?** Predict future demand for specific materials or forecast price movements. Help collectors decide when to sell and recyclers plan purchasing.

**Is ML actually necessary?** Sort of. Time series forecasting benefits from ML once you have enough data. But the simplest approach (moving average, exponential smoothing) is statistical, not ML.

**Could rules/API/database logic solve it?** The current trend indicator (comparing recent 30d avg vs prior 30d avg) is a form of this. It works with limited data and is easy to understand.

**What training data is required?** 12+ months of daily price data per material per region. Demand data from actual recycler purchasing patterns.

**How much data is realistically available?** Seeded demo data spanning 90 days. Not enough for meaningful forecasting.

**Can a student team build it?** Applying Prophet or ARIMA to time series is technically straightforward. The problem is garbage-in-garbage-out with demo data.

**Can it run on-device?** Not needed. Server-side batch job.

**Can it work offline?** Show cached forecasts. Computation is server-side.

**How difficult is evaluation?** Moderate. MAPE on held-out time periods. But the time series is too short to evaluate.

**What is its MVP value?** Zero. The trend indicator is sufficient.

**What is its hackathon/demo value?** Low. A forecast chart looks nice but adds no user value.

**What is its long-term business value?** Medium. Price forecasting helps collectors time their sales. But the platform needs critical mass first.

| Criterion | Score (1-5) |
|-----------|-------------|
| Impact | 2 |
| Feasibility | 3 |
| Data availability | 1 |
| Differentiation | 2 |
| MVP usefulness | 1 |

**Weighted priority = (2*0.25 + 3*0.25 + 1*0.2 + 2*0.15 + 1*0.15) = 0.5 + 0.75 + 0.2 + 0.3 + 0.15 = 1.90**

---

## Component 12: Voice recognition / speech-to-text

**What problem does it solve?** Let collectors speak instead of type. Many informal recyclers have low literacy. Voice input for material descriptions, search queries, or commands.

**Is ML actually necessary?** You don't build this. Use the device's built-in speech recognition (Android SpeechRecognizer, iOS SFSpeechRecognizer). These support Hindi and Marathi.

**Could rules/API/database logic solve it?** Yes. Platform API. No custom ML.

**What training data is required?** None for platform APIs. A custom model for e-waste vocabulary would need thousands of hours of domain-specific speech, which is absurd.

**How much data is realistically available?** Not relevant.

**Can a student team build it?** Yes, by integrating platform APIs. Expo has `expo-speech` for TTS and community packages for STT.

**Can it run on-device?** Yes. Built-in speech recognition runs on-device on modern phones.

**Can it work offline?** Partial. On-device speech recognition works offline on Android 13+ and iOS. Older devices may need network.

**How difficult is evaluation?** Not relevant since you're using platform APIs.

**What is its MVP value?** Medium. The app already uses TTS for safety guides and price readouts. Adding STT for input would help low-literacy users.

**What is its hackathon/demo value?** Medium. "Speak to the app in Hindi" is easy to demo and resonates with the social impact angle.

**What is its long-term business value?** High. Voice is the primary interface for many users in this demographic.

| Criterion | Score (1-5) |
|-----------|-------------|
| Impact | 3 |
| Feasibility | 5 |
| Data availability | 5 |
| Differentiation | 2 |
| MVP usefulness | 3 |

**Weighted priority = (3*0.25 + 5*0.25 + 5*0.2 + 2*0.15 + 3*0.15) = 0.75 + 1.25 + 1.0 + 0.3 + 0.45 = 3.75**

---

## Component 13: Text-to-speech

**What problem does it solve?** Read prices, material names, safety instructions, and transaction summaries aloud. Helps collectors who can't read well.

**Is ML actually necessary?** No. Use platform TTS (Android TextToSpeech, iOS AVSpeechSynthesizer). The app already does this.

**Could rules/API/database logic solve it?** Already implemented. Platform TTS supports multiple languages.

**What training data is required?** None.

**How much data is realistically available?** N/A.

**Can a student team build it?** Already built.

**Can it run on-device?** Yes.

**Can it work offline?** Yes, with downloaded voice packs.

**How difficult is evaluation?** Not applicable.

**What is its MVP value?** Already included in MVP.

**What is its hackathon/demo value?** Already included.

**What is its long-term business value?** Already included.

| Criterion | Score (1-5) |
|-----------|-------------|
| Impact | 3 |
| Feasibility | 5 |
| Data availability | 5 |
| Differentiation | 1 |
| MVP usefulness | 5 |

**Weighted priority = (3*0.25 + 5*0.25 + 5*0.2 + 1*0.15 + 5*0.15) = 0.75 + 1.25 + 1.0 + 0.15 + 0.75 = 3.90**

*Already implemented. No additional work needed.*

---

## Component 14: Multilingual NLP

**What problem does it solve?** Understand user input in Hindi, Marathi, or English for search, descriptions, and commands. Maybe translate between languages.

**Is ML actually necessary?** Depends on the feature. Simple translation: use Google Translate API. Intent recognition: the app's fixed UI flows don't need NLP. A chatbot-style interface would need it, but the app isn't a chatbot.

**Could rules/API/database logic solve it?** Yes. The app uses static translation files (i18n) for all UI text. User-generated text (lot descriptions) can stay in the original language. If translation is needed, use an API.

**What training data is required?** For a custom NLP model: domain-specific text in Hindi/Marathi with intent labels. For API-based translation: nothing.

**How much data is realistically available?** Zero domain-specific NLP training data.

**Can a student team build it?** API integration yes. Custom NLP no.

**Can it run on-device?** Platform APIs and offline translation packs exist.

**Can it work offline?** With downloaded language packs, partially.

**How difficult is evaluation?** Not relevant for API-based approach.

**What is its MVP value?** Low. i18n translation files already cover the UI.

**What is its hackathon/demo value?** Low. The app already works in three languages.

**What is its long-term business value?** Medium. NLP would be useful for a chatbot or voice assistant, but that's a future feature.

| Criterion | Score (1-5) |
|-----------|-------------|
| Impact | 2 |
| Feasibility | 4 |
| Data availability | 3 |
| Differentiation | 1 |
| MVP usefulness | 1 |

**Weighted priority = (2*0.25 + 4*0.25 + 3*0.2 + 1*0.15 + 1*0.15) = 0.5 + 1.0 + 0.6 + 0.15 + 0.15 = 2.40**

---

## Component 15: Collector/recycler matching (collaborative filtering)

**What problem does it solve?** Learn collector preferences over time. "Collectors who sold PCBs to Recycler A also preferred Recycler B for batteries." Collaborative filtering for marketplace matching.

**Is ML actually necessary?** Not at current scale. With 3 collectors and 5 recyclers in the demo, there's nothing to learn. Collaborative filtering needs hundreds of users with overlapping preferences.

**Could rules/API/database logic solve it?** The weighted scoring formula already handles matching. It just doesn't learn from past behavior.

**What training data is required?** User-item interaction matrix: which collectors transacted with which recyclers, for which materials, and the outcomes.

**How much data is realistically available?** Zero.

**Can a student team build it?** Technically yes (surprise library, basic matrix factorization). Meaningfully no.

**Can it run on-device?** Inference yes. Training no.

**Can it work offline?** With cached recommendations.

**How difficult is evaluation?** Impossible without real interaction data.

**What is its MVP value?** Zero.

**What is its hackathon/demo value?** Zero. You can't demo collaborative filtering with 3 users.

**What is its long-term business value?** Medium. At scale (1000+ users), this could improve match quality. But the weighted formula would still be the baseline.

| Criterion | Score (1-5) |
|-----------|-------------|
| Impact | 2 |
| Feasibility | 2 |
| Data availability | 1 |
| Differentiation | 2 |
| MVP usefulness | 1 |

**Weighted priority = (2*0.25 + 2*0.25 + 1*0.2 + 2*0.15 + 1*0.15) = 0.5 + 0.5 + 0.2 + 0.3 + 0.15 = 1.65**

---

## Component 16: Reputation scoring

**What problem does it solve?** Build trust scores for collectors and recyclers based on transaction history, dispute rates, payment timeliness, and rating patterns.

**Is ML actually necessary?** No. A weighted formula based on concrete metrics (% on-time payments, dispute rate, transaction count, average rating) works perfectly. This is arithmetic, not prediction.

**Could rules/API/database logic solve it?** Yes. Calculate:
- `score = (completion_rate * 0.3) + (payment_rate * 0.3) + (rating_avg/5 * 0.2) + min(1, txn_count/20) * 0.2`
- Apply decay for old transactions.

This is straightforward and transparent.

**What training data is required?** None for a formula. An ML approach would need labeled "trustworthy" vs "untrustworthy" users, which you don't have.

**How much data is realistically available?** N/A.

**Can a student team build it?** The formula, yes.

**Can it run on-device?** Not needed. Server-side calculation.

**Can it work offline?** Cache the score.

**How difficult is evaluation?** Hard to evaluate a trust score without real fraud/dispute outcomes.

**What is its MVP value?** Low. With demo data, reputation scores are meaningless.

**What is its hackathon/demo value?** Low. Show the formula in the architecture doc. Don't build a model for it.

**What is its long-term business value?** High. Trust is everything in informal marketplaces. But the formula approach handles this.

| Criterion | Score (1-5) |
|-----------|-------------|
| Impact | 3 |
| Feasibility | 5 |
| Data availability | 2 |
| Differentiation | 1 |
| MVP usefulness | 1 |

**Weighted priority = (3*0.25 + 5*0.25 + 2*0.2 + 1*0.15 + 1*0.15) = 0.75 + 1.25 + 0.4 + 0.15 + 0.15 = 2.70**

*Should be built as a formula, not as ML.*

---

## Component 17: Chatbot / conversational assistant

**What problem does it solve?** Let users ask questions in natural language. "What's the price of copper cable?" or "Who buys batteries near me?"

**Is ML actually necessary?** For true natural language understanding, yes. But you don't build it, you integrate an LLM API (GPT, Gemini, Claude). A cheap alternative: keyword-based intent matching for a fixed set of questions.

**Could rules/API/database logic solve it?** For a small fixed set of questions, yes. Map keywords to intents: "price" -> show price screen, "buyer" -> show recycler list. This handles 80% of cases.

**What training data is required?** None for API-based LLM. None for keyword matching.

**How much data is realistically available?** N/A.

**Can a student team build it?** Keyword matching: yes. LLM integration: yes, if budget allows API costs.

**Can it run on-device?** Keyword matching yes. LLM no (requires API call).

**Can it work offline?** Keyword matching yes. LLM no.

**How difficult is evaluation?** Moderate. Test a fixed set of queries.

**What is its MVP value?** Low. The app has a clear UI with fixed navigation. A chatbot adds a parallel interaction mode that's harder to maintain.

**What is its hackathon/demo value?** Medium. "Ask the app in Hindi" sounds good, but demo judges know chatbots are API wrappers.

**What is its long-term business value?** Medium. Could help onboard low-literacy users, but voice UI covers that use case better.

| Criterion | Score (1-5) |
|-----------|-------------|
| Impact | 2 |
| Feasibility | 4 |
| Data availability | 4 |
| Differentiation | 2 |
| MVP usefulness | 2 |

**Weighted priority = (2*0.25 + 4*0.25 + 4*0.2 + 2*0.15 + 2*0.15) = 0.5 + 1.0 + 0.8 + 0.3 + 0.3 = 2.90**

---

## Component 18: Smart aggregation optimization

**What problem does it solve?** Optimize which lots to group together for maximum price benefit. Consider material compatibility, geographic proximity, weight combinations, and timing.

**Is ML actually necessary?** No. This is a constrained optimization problem, not a prediction problem. Find lots where: same material, nearby location, combined weight hits the next volume tier. That's a database query plus arithmetic.

**Could rules/API/database logic solve it?** Already does. The current aggregation service finds forming groups and calculates volume bonuses. The logic is simple and correct.

**What training data is required?** None.

**How much data is realistically available?** N/A.

**Can a student team build it?** Already built.

**Can it run on-device?** Server-side feature.

**Can it work offline?** Not needed.

**How difficult is evaluation?** Easy. Compare group price to individual prices.

**What is its MVP value?** Already included.

**What is its hackathon/demo value?** Already included.

**What is its long-term business value?** Already included. Could be improved with demand-side signals but doesn't need ML.

| Criterion | Score (1-5) |
|-----------|-------------|
| Impact | 3 |
| Feasibility | 5 |
| Data availability | 5 |
| Differentiation | 2 |
| MVP usefulness | 4 |

**Weighted priority = (3*0.25 + 5*0.25 + 5*0.2 + 2*0.15 + 4*0.15) = 0.75 + 1.25 + 1.0 + 0.3 + 0.6 = 3.90**

*Already implemented. ML not needed.*

---

## Component 19: Document/license verification (authorization checking)

**What problem does it solve?** Verify recycler authorization documents. Check if a scanned certificate is valid, extract details, match against government databases.

**Is ML actually necessary?** For document classification and OCR extraction, partially. For verification against external databases, no, that's an API call.

**Could rules/API/database logic solve it?** OCR extraction + regex for certificate numbers + API call to verification database. No custom ML needed. The hard part is getting access to the government database, not building a model.

**What training data is required?** For custom document understanding: labeled authorization documents. For OCR + regex: template knowledge of document formats.

**How much data is realistically available?** A few sample authorization certificates, maybe.

**Can a student team build it?** The OCR + regex approach yes. Government API integration may be blocked by access restrictions.

**Can it run on-device?** OCR yes.

**Can it work offline?** OCR extraction yes. Verification no.

**How difficult is evaluation?** Moderate. Extraction accuracy on test documents.

**What is its MVP value?** Low. Authorization is currently a manual status field.

**What is its hackathon/demo value?** Low. Without a real government API, you're scanning a certificate and reading text from it.

**What is its long-term business value?** High. Automated authorization verification is a regulatory compliance feature. But it depends on external API availability.

| Criterion | Score (1-5) |
|-----------|-------------|
| Impact | 2 |
| Feasibility | 3 |
| Data availability | 2 |
| Differentiation | 2 |
| MVP usefulness | 1 |

**Weighted priority = (2*0.25 + 3*0.25 + 2*0.2 + 2*0.15 + 1*0.15) = 0.5 + 0.75 + 0.4 + 0.3 + 0.15 = 2.10**

---

## Priority ranking summary

| Rank | Component | Weighted score | Verdict |
|------|-----------|---------------|---------|
| 1 | TTS (Component 13) | 3.90 | Already built. Keep it. |
| 2 | Smart aggregation (Component 18) | 3.90 | Already built. No ML needed. |
| 3 | Image classification (Component 1) | 3.75 | **BUILD THIS. Only real ML candidate.** |
| 4 | Voice/STT (Component 12) | 3.75 | Use platform API. Not custom ML. |
| 5 | OCR (Component 3) | 3.20 | Use existing library. Not custom ML. |
| 6 | Chatbot (Component 17) | 2.90 | Optional, use LLM API if at all. |
| 7 | Route optimization (Component 9) | 2.80 | Use OR-Tools. Not ML. |
| 8 | Reputation (Component 16) | 2.70 | Use a formula. Not ML. |
| 9 | Multilingual NLP (Component 14) | 2.40 | Use i18n + API. Not ML. |
| 10 | Object detection (Component 2) | 2.20 | Too hard for current team. |
| 11 | Price prediction (Component 7) | 2.15 | No data. Keep statistics. |
| 12 | Fraud detection (Component 10) | 2.15 | No data. Keep thresholds. |
| 13 | Doc verification (Component 19) | 2.10 | Depends on external APIs. |
| 14 | Material sub-class (Component 4) | 2.05 | User picker is better. |
| 15 | Demand forecasting (Component 11) | 1.90 | No data. Keep trends. |
| 16 | Recycler rec/CF (Component 8) | 1.75 | No data. Keep formula. |
| 17 | Quality assessment (Component 5) | 1.65 | Manual input is better. |
| 18 | Collaborative filter (Component 15) | 1.65 | No users. Meaningless. |
| 19 | Weight estimation (Component 6) | 1.55 | Research problem. Don't. |

