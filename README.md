# Image Context Bridge

[中文](README.zh-CN.md)

> Let text-only models "see" images

**The problem:** When you send a screenshot to DeepSeek or any text-only model, it says "I can't process images." This tool converts the image into OCR-extracted text before it reaches the model, so the model sees words instead of pixels.

---

## How it works

Zero third-party OCR services. Uses what your OS already has:

| Platform | OCR Engine | Dependencies |
|----------|-----------|-------------|
| macOS | Apple Vision | None |
| Windows | Windows native OCR | None |
| Linux | PaddleOCR | Auto-installed |
| All platforms | SVG XML parsing | None |

PaddleOCR is available as an optional high-accuracy backend on macOS and Windows.

## Install

On macOS and Windows, only [Pillow](https://python-pillow.org/) is needed for reading image metadata. The OCR engine is built into your OS.

```bash
# macOS / Linux
bash install.sh

# With optional PaddleOCR for higher accuracy
bash install.sh --with-paddleocr
```

```powershell
# Windows
.\install.ps1

# Optional PaddleOCR
.\install.ps1 -WithPaddleOCR
```

## Usage

```bash
# Basic
image2context screenshot.png

# Include your question for richer context
image2context screenshot.png --question "What does this error mean?"

# Override the default OCR backend
image2context screenshot.png --ocr-backend paddleocr
image2context screenshot.png --ocr-backend native
```

Outputs structured Markdown you can paste directly to any model.

## Design principle

**Don't pretend to see what isn't there.**

OCR extracts text. It does not perform visual understanding. Every output packet explicitly separates:

- `confirmed_facts` — what OCR confirmed it found
- `extracted_text` — the text, with confidence scores
- `uncertainties` — limitations and unknowns

The final line is always: "Do not invent non-text visual details."

## Good for

- Forwarding screenshots, terminal errors, and code snippets to text-only models like DeepSeek
- Giving non-vision agents the ability to handle image-text mixed tasks
- Converting SVG diagrams, menus, and settings pages into searchable text
- Any situation where the model says "I can't see images"

## Not for

- Tasks requiring understanding of faces, emotions, scenes, colors, or composition
- Images with minimal text where visual content is what matters
- Models that already have native vision and received your image successfully

## License

MIT
