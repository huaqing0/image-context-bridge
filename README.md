# Image Context Bridge

A lightweight Skill package for Claude Code / Codex / text-only agents.

It converts images into text evidence packets so non-vision models can reason from extracted text instead of guessing.

## Backend policy

- macOS: Apple Vision OCR by default.
- Windows: Windows native OCR by default.
- Linux or systems without native OCR: PaddleOCR by default via installer.
- PaddleOCR can also be installed as an optional high-accuracy backend on macOS/Windows.
- SVG files are parsed directly as XML/text.

## Install

macOS:

```bash
bash install.sh
```

Linux default installs PaddleOCR because Linux has no built-in OS OCR:

```bash
bash install.sh
```

macOS with optional PaddleOCR:

```bash
bash install.sh --with-paddleocr
```

Windows:

```powershell
.\install.ps1
```

Windows with optional PaddleOCR:

```powershell
.\install.ps1 -WithPaddleOCR
```

## Usage

```bash
image2context screenshot.png
```

With a question:

```bash
image2context screenshot.png --question "What is the error?"
```

Force backend:

```bash
image2context screenshot.png --ocr-backend paddleocr
image2context screenshot.png --ocr-backend native
image2context screenshot.png --ocr-backend none
```

## Output philosophy

This tool does not claim full visual understanding. It outputs:

- file information
- extracted text
- confirmed facts
- uncertainties
- context for text-only models

The model should not invent non-text visual details.
