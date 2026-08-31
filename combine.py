import os

files = [
    "PRODUCT_ANALYSIS.md",
    "PART3_USER_PROBLEM_VALIDATION.md",
    "PART4_FEATURE_VALUE_ANALYSIS.md",
    "PART_5_6_7_AI_ML.md",
    "PART_8_9_10_DATA_MVP.md",
    "PART_11_12_13_PLANNING.md",
    "PART_14_18_FINAL.md"
]

content = ""
for f in files:
    if os.path.exists(f):
        with open(f, 'r') as file:
            content += file.read() + "\n\n"
    else:
        print(f"Missing {f}")

with open("MASTER_ANALYSIS.md", "w") as out:
    out.write(content)

