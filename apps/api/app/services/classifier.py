from typing import Optional

"""
Demo material classifier for e-waste.
This is NOT a real ML classifier. It uses keyword matching and deterministic
rules to simulate classification for demo/prototype purposes.
"""
import hashlib
import random

MATERIAL_KEYWORDS = {
    "PCB": ["circuit", "board", "pcb", "chip", "electronic", "motherboard", "green"],
    "CABLE": ["cable", "wire", "cord", "copper", "plug"],
    "BATTERY": ["battery", "cell", "lithium", "lead", "acid", "rechargeable"],
    "CRT": ["crt", "tube", "monitor", "cathode", "bulky", "heavy"],
    "LCD": ["lcd", "screen", "flat", "panel", "display", "thin"],
    "MOTOR": ["motor", "fan", "rotor", "coil", "appliance", "compressor"],
    "MAGNET_ASSEMBLY": ["magnet", "speaker", "assembly", "neodymium"],
    "MIXED_PLASTIC": ["plastic", "casing", "cover", "housing", "shell"],
}

def classify(image_data: Optional[str] = None, filename: Optional[str] = None) -> dict:
    """
    Classify material from image data or filename.
    
    Since this is a demo, it:
    1. Checks filename/image_data for keywords
    2. If no match, uses a hash of the input to deterministically pick a category
    3. Returns category, confidence, and alternatives
    """
    text_to_check = ""
    if filename:
        text_to_check += filename.lower()
    if image_data:
        text_to_check += image_data[:200].lower() if len(image_data) > 200 else image_data.lower()
    
    # Try keyword matching
    scores = {}
    for material, keywords in MATERIAL_KEYWORDS.items():
        score = sum(1 for kw in keywords if kw in text_to_check)
        if score > 0:
            scores[material] = score
    
    if scores:
        sorted_scores = sorted(scores.items(), key=lambda x: x[1], reverse=True)
        top = sorted_scores[0]
        total = sum(s for _, s in sorted_scores)
        confidence = min(0.95, 0.5 + (top[1] / total) * 0.45)
        
        alternatives = []
        for mat, sc in sorted_scores[1:3]:
            alternatives.append({
                "category": mat,
                "confidence": round(sc / total * 0.8, 2)
            })
        
        return {
            "category": top[0],
            "confidence": round(confidence, 2),
            "alternatives": alternatives
        }
    
    # Fallback: hash-based deterministic selection
    hash_input = (image_data or filename or "ewaste").encode()
    hash_val = int(hashlib.md5(hash_input).hexdigest(), 16)
    categories = list(MATERIAL_KEYWORDS.keys())
    selected = categories[hash_val % len(categories)]
    
    # Generate alternatives
    rng = random.Random(hash_val)
    alts = rng.sample([c for c in categories if c != selected], 2)
    
    return {
        "category": selected,
        "confidence": 0.65,
        "alternatives": [
            {"category": alts[0], "confidence": 0.20},
            {"category": alts[1], "confidence": 0.10},
        ]
    }
