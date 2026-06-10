---
name: image-context
description: Use this skill when an image is sent to a text-only or image-unsupported model. Convert the image into OCR/text evidence before answering.
---

# Image Context Bridge

Use this skill when the current model cannot directly process images, or when image input fails.

## Trigger rules

Use this skill when:
- The user provides an image path or image file.
- The target model cannot process images.
- Image input fails with an unsupported-image/media error.
- The model's image capability is unknown and the image cannot be passed directly.

Do not use this skill when:
- The active model clearly supports native image understanding and successfully received the image.
- The user only asks for image file metadata.

## Required action

Before answering image-related questions for a text-only model, run:

```bash
image2context <image_path>
```

If the user asked a specific question about the image, include it:

```bash
image2context <image_path> --question "<user question>"
```

## OCR backend policy

`image2context` chooses the OCR backend automatically:

- macOS: Apple Vision OCR by default.
- Windows: Windows native OCR by default.
- Linux or systems without native OCR: PaddleOCR by default when installed by the installer.
- PaddleOCR can also be installed as an optional high-accuracy backend on macOS/Windows.
- SVG files are parsed directly as XML/text without OCR.

## Answering rules

- Do not guess image contents.
- Use extracted text and file information as evidence.
- Clearly separate:
  - confirmed OCR/text information
  - reasonable inference
  - unknown or unconfirmed visual details
- If OCR extracts little or no text, say the image was processed but cannot be reliably understood by OCR alone.
- Do not invent non-text visual details.

## Expected tool output

The `image2context` tool returns:
- file information
- extraction backend used
- extracted text
- confidence/box data when available
- confirmed facts
- uncertainties
- context for text-only models

Use `context_for_text_model` as the main source.
