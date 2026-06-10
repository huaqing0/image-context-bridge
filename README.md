# Image Context Bridge

[中文](README.zh-CN.md)

**A skill that auto-detects whether a model has vision — if not, converts images to text automatically.**

---

## What this skill does

When you send an image to a text-only model (like DeepSeek or a local LLM),
this skill automatically:

1. **Detects** whether the model can see images
2. If yes — passes the image through
3. If no — runs OCR, extracts all visible text, and packages it as a structured
   evidence packet

The model receives readable text with extracted content, confidence scores,
file metadata, and clear boundaries — so it doesn't invent visual details
that aren't actually there.

OCR runs locally using your operating system's built-in engine. No cloud
upload, no API key, no quota. On Linux, PaddleOCR is installed automatically.

---

## Example

```
Input:  a screenshot showing "Error: connection refused on port 3000"
Output: evidence packet including:
        - "Error: connection refused on port 3000" (confidence: 1.000)
        - filename, format, dimensions
        - confirmed facts, limitations, answering instructions
Result: the model reads the error text and suggests a fix — without ever
        seeing the actual image
```

---

## Install

```bash
bash install.sh
```

| Platform | OCR engine | What's installed |
|----------|-----------|-----------------|
| macOS | Apple Vision | Pillow |
| Windows | Windows OCR | Pillow |
| Linux | PaddleOCR | Pillow + PaddleOCR |

```bash
# Optional: higher accuracy on any platform
bash install.sh --with-paddleocr
```

## Use

```bash
# Basic
image2context screenshot.png

# Include your question for context
image2context error.png --question "Why did the build fail?"

# JSON output
image2context screenshot.png --json

# Hook: auto-decide whether conversion is needed
echo '{"message":"Check ./error.png","model_supports_images":false}' | auto-image-fallback
```

---

## License

MIT
