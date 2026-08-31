# AI and ML evaluation for KabadiwalaConnect

## Part 5. AI and ML component analysis

Here are the potential AI features a team might consider for this platform.

### E-waste image classification
This model lets users skip typing and just snap a photo of their junk. Rules cannot parse pixels into categories, so machine learning is absolutely necessary here. You need thousands of labeled photos of specific electronics to make it work. A student team can easily pull this off using transfer learning on an existing vision model. It runs well on cheap devices and works completely offline. Evaluation is dead simple using basic F1 scores. 
Impact 4, Feasibility 4, Data 3, Differentiation 3, MVP 4. The hackathon demo value is massive, though the long term business value is moderate.

### Price prediction regression
Users want immediate quotes for their items, but machine learning is the wrong tool for this. Market rates are rigid and weight based. A simple database lookup works infinitely better. Building an AI for this requires historical pricing data mapped to exact scrap conditions across different regions. That data does not exist publicly. The evaluation is messy because scrap value is highly subjective. 
Impact 4, Feasibility 1, Data 1, Differentiation 4, MVP 1. It might look okay in a fake demo but fails immediately against real math.

### Weight estimation from photos
Users do not own weighing scales at home, and rules cannot solve this alone. But estimating mass from a flat image without depth sensors is a massive research problem. You would need paired images and strictly measured weights of weird, irregular e-waste piles. A student team stands zero chance of building this in a weekend. 
Impact 3, Feasibility 1, Data 1, Differentiation 5, MVP 1. Faking it for a hackathon might win points, but actually attempting to build it is a trap.

### Anomaly detection for fraud
Collectors manipulate scales or log fake pickups. Routine statistical thresholds can flag strange weights easily, making machine learning completely unnecessary for a prototype. Real models require logs of thousands of verified transactions that a fresh startup lacks. It runs in the backend, meaning it requires server infrastructure rather than working offline. 
Impact 2, Feasibility 4, Data 2, Differentiation 2, MVP 1. It is a backend feature nobody will notice during a pitch. The feature matters eventually, but not today.

### Dynamic pickup routing
Collectors waste fuel driving inefficient routes. AI is the wrong solution. Standard routing heuristics and mapping APIs already handle this perfectly using live traffic nodes and GPS coordinates. Rolling a custom model here wastes precious hackathon time on a solved problem. 
Impact 5, Feasibility 2, Data 2, Differentiation 3, MVP 1. Map APIs exist for a reason.

## Part 6. First AI model decision

The team must build the e-waste image classifier first. Leave the rest alone.

The task is straightforward. The model takes a standard picture from a cheap smartphone camera and categorizes it into one of 10 common e-waste buckets like phones, cables, circuit boards, or mixed plastics. The output is a simple probability distribution across those categories.

I recommend MobileNet or EfficientNet Lite for the architecture. Speed matters more than perfect accuracy.

This model comes first because it kills user friction. Asking people to scroll through dropdown menus to classify old wires guarantees they will close the app. Snapping a photo makes the platform feel magical. It also proves to hackathon judges that the team can ship a real machine learning pipeline.

For a minimum dataset, developers can scrape 500 images per category from public sources. They must apply heavy data augmentation like rotations and contrast shifts to make it robust. The ideal dataset contains thousands of images crowdsourced from real Indian homes. Real e-waste sits in bad lighting on patterned bedsheets. Training on clean stock photos ruins the model in production.

The training approach is simple transfer learning. Take a pre-trained model, freeze the early layers, and train the final classification head to recognize these specific garbage categories.

Use the macro F1 score for evaluation. Pure accuracy lies. If a dataset is mostly cables, a model that guesses cables every single time will report high accuracy but remain completely useless.

Run the inference entirely on the device using TensorFlow Lite. This makes offline classification completely reliable. The model sits in the app payload and needs no network call to guess a category. One smart student can build, train, and deploy a decent version of this in half a day.

The other concepts wait. Price prediction requires proprietary local data that students do not have. Weight estimation from pictures is physically impossible without depth data. Routing is already solved by standard mapping software. Fraud detection belongs in year two of the startup.

## Part 7. What not to build in AI

Do not throw machine learning at every problem. A student team must use deterministic tech where it actually works better.

Avoid AI for scrap pricing. Do not train a model to guess prices. Scrap markets run on strict kiloton rates that shift steadily based on global metal indices. Use a standard database table and update the rates weekly manually.

Skip predictive models for travel time entirely. Do not use AI to estimate how long a pickup takes or how far away a house is. The Google Maps Distance Matrix API already has the traffic data and all the routing math built in.

Ignore fake user detection models. Do not build a classifier to spot spam accounts. A weekend prototype has no real user data to train on anyway. Stick to standard email links and typical SMS verification to block most issues.

Forget weight calculation from images. Do not attempt to guess mass from a picture. A photo cannot reveal if a desktop computer tower is empty or packed with dense metal parts. Ask the user for an estimate during onboarding and tell the collector to bring a physical digital scale to the house.

Ban customer support chatbots. Do not inject a generative text prompt to answer basic recycling questions. These tools remain slow and prone to hallucination. Users just want to get rid of their waste and get paid. They do not want to chat. Build a clean static text page for frequently asked questions.