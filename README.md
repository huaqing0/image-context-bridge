# Image Context Bridge

[中文](README.zh-CN.md)

**A skill that auto-detects whether a model has vision — if not, converts images to text automatically.**

---

## What this skill does

When you send an image to a text-only model, this skill automatically:

1. **Detects** whether the model has vision capability
2. If yes — passes the image through untouched
3. If no — runs OCR, extracts all visible text from the image, and packages it
   as a structured text evidence packet

The model receives readable text with extracted content, confidence scores,
and clear boundaries — so it doesn't invent visual details that aren't there.

---

## Example

```
Input:  screenshot of a terminal error "connection refused on port 3000"
Output: evidence packet containing:
        - "connection refused on port 3000" (confidence: 1.000)
        - filename, format, dimensions
        - confirmed facts, limitations, answering instructions
Result: the text-only model can read the error and suggest a fix
```

---

## Install

```bash
bash install.sh
```

## Use

```bash
image2context screenshot.png
image2context error.png --question "Why did the build fail?"
```

---

## License

MIT
