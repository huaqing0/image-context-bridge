# Image Context Bridge

[中文](README.zh-CN.md)

Image Context Bridge is a small local workflow for text-only or image-unsupported AI models. It converts an image file into a structured text evidence packet, then asks the model to reason only from extracted text, metadata, and stated limitations.

It is useful when you want to use models such as DeepSeek, local LLMs, or other text-only agents on screenshots, error dialogs, SVGs, and image files without asking the model to invent visual details it cannot actually see.

## What It Includes

- `image2context`: a CLI that reads an image path and outputs Markdown or JSON evidence.
- `auto-image-fallback`: a hook helper that decides whether to pass an image through or replace it with text context.
- `skills/image-context`: a Skill wrapper for agents such as Claude Code, Codex, and other skill-aware tools.

The Skill is only a workflow wrapper. The actual extraction is done by the local `image2context` command.

## How It Works

1. You provide an image path, or an agent detects one in a message.
2. If the active model can handle images, the image can be passed through directly.
3. If the model is text-only or image input fails, `image2context` extracts OCR/SVG text locally.
4. The output packet includes file metadata, extracted text, confidence values when available, confirmed facts, limitations, and an instruction not to invent non-text visual details.

Example:

```text
Input image:
  A screenshot showing "Error: connection refused on port 3000"

Evidence packet:
  - extracted text: "Error: connection refused on port 3000"
  - filename, format, size, dimensions
  - confirmed facts
  - limitations and answering instruction

Result:
  A text-only model can reason from the error text without pretending it saw the image.
```

## Privacy

OCR runs locally. This project does not upload image files, call a cloud OCR API, require an API key, or use a quota.

If you use a separate agent that first sends the original image to a cloud model, that behavior is controlled by that agent, not by Image Context Bridge. To avoid that, call `image2context` directly or configure your agent to use the fallback workflow first.

## Supported Inputs

Raster images:

- `.png`
- `.jpg` / `.jpeg`
- `.webp`
- `.bmp`
- `.tiff` / `.tif`
- `.gif`

Vector/text images:

- `.svg` files are parsed directly as XML/text without OCR.

## OCR Backends

| Platform | Default backend | Notes |
| --- | --- | --- |
| macOS | Apple Vision OCR | Uses the built-in Vision framework through Swift. |
| Windows | Windows OCR | Uses the built-in Windows OCR APIs through PowerShell. |
| Linux | PaddleOCR | Installed by the Linux installer path because there is no built-in OS OCR. |
| Any platform | Tesseract | Used as a fallback if installed and selected/available. |
| Any platform | PaddleOCR | Optional high-accuracy backend. |

SVG text extraction is handled separately and does not use an OCR backend.

## Install

Clone the repository, then run the installer from the project directory.

macOS or Linux:

```bash
bash install.sh
```

Windows PowerShell:

```powershell
.\install.ps1
```

Optional PaddleOCR install:

```bash
bash install.sh --with-paddleocr
```

```powershell
.\install.ps1 -WithPaddleOCR
```

Skip PaddleOCR on Linux if you only want metadata/SVG extraction or another manually installed backend:

```bash
bash install.sh --no-paddleocr
```

The installer creates:

- `~/.image-context-bridge/` for the local app files and Python virtual environment.
- `~/.local/bin/image2context`
- `~/.local/bin/auto-image-fallback`
- `~/.agents/skills/image-context/`
- `~/.claude/skills/image-context/`
- `~/.codex/skills/image-context/`

Make sure `~/.local/bin` is in your `PATH`. Restart Claude Code, Codex, or your agent app after installation so it can reload the Skill.

## Quick Verification

```bash
image2context testdata/sample.svg --json
```

Expected extracted text includes:

```text
WebSocket handshake timeout
Reconnecting...
```

Check the fallback hook:

```bash
echo '{"message":"Please analyze ./testdata/sample.svg","model_supports_images":false}' | auto-image-fallback
```

Expected action:

```json
{"action":"replace_with_context", "...":"..."}
```

## CLI Usage

```bash
# Basic Markdown evidence packet
image2context screenshot.png

# Include the user question in the packet
image2context error.png --question "Why did the build fail?"

# JSON only
image2context screenshot.png --json

# Disable OCR and return metadata/limitations only
image2context screenshot.png --ocr-backend none

# Force a backend
image2context screenshot.png --ocr-backend native
image2context screenshot.png --ocr-backend apple_vision
image2context screenshot.png --ocr-backend windows_ocr
image2context screenshot.png --ocr-backend paddleocr
image2context screenshot.png --ocr-backend tesseract
```

Language hints:

```bash
image2context screenshot.png --vision-languages en-US,zh-Hans,ja-JP
image2context screenshot.png --windows-lang zh-Hans
image2context screenshot.png --tesseract-lang eng+chi_sim
```

## Skill Usage

After installation, skill-aware agents can load `image-context`.

For Claude Code or similar agents, use a prompt like:

```text
Use image-context to process ./testdata/sample.svg, then tell me what error text it contains.
```

For DeepSeek or another text-only model inside an agent, the useful behavior is:

1. The agent sees an image path.
2. The `image-context` Skill tells it to run `image2context <image_path>`.
3. The agent answers from `context_for_text_model`, not from imagined visual details.

If the agent does not trigger the Skill automatically, run the CLI yourself and paste the output into the model.

## Hook Usage

`auto-image-fallback` reads JSON from stdin and returns a JSON action.

Known image support:

```bash
echo '{"message":"Check ./error.png","model_supports_images":false}' | auto-image-fallback
```

Unknown image support:

```bash
echo '{"message":"Check ./error.png","model_supports_images":null}' | auto-image-fallback
```

When support is unknown, the hook returns `try_direct_first`. Call it again with `last_error` if direct image input fails:

```bash
echo '{"message":"Check ./error.png","model_supports_images":null,"last_error":"image input not supported"}' | auto-image-fallback
```

## Output Shape

JSON output contains:

- `file_info`: path, filename, extension, size, modified time, dimensions when available.
- `available_backends`: detected extraction backends.
- `requested_ocr_backend`: selected backend policy.
- `extraction_methods`: methods actually used.
- `extracted_text`: text items with source, confidence, and box when available.
- `confirmed_facts`: facts supported by extraction.
- `uncertainties`: limitations and things OCR cannot determine.
- `context_for_text_model`: the main text block to give to a text-only model.
- `backend_errors`: backend failures, if fallback attempts failed.

## Limitations

- This is OCR and SVG text extraction, not full visual understanding.
- Non-text objects, layout meaning, charts, handwriting, UI state, colors, emotion, and visual style may be missed.
- OCR accuracy depends on image quality, language support, fonts, orientation, and backend.
- The Skill wrapper does not force every agent to use the workflow. Some tools require a restart or explicit prompt.
- On Windows, native OCR availability depends on installed language packs and Windows OCR support.

## Troubleshooting

`image2context: command not found`

Add `~/.local/bin` to your `PATH`, then restart your shell or agent app.

```bash
export PATH="$HOME/.local/bin:$PATH"
```

Skill does not trigger in Claude Code/Codex

- Restart the agent app after installation.
- Confirm the Skill files exist under `~/.claude/skills/image-context/` or `~/.codex/skills/image-context/`.
- Ask explicitly: `Use image-context to process <image_path>`.

OCR returns no text

- Try a clearer image or crop around the text.
- Try PaddleOCR: `bash install.sh --with-paddleocr`, then `image2context image.png --ocr-backend paddleocr`.
- For SVGs, make sure the text is real SVG text, not converted outlines.

macOS says Swift is missing

Install Xcode Command Line Tools:

```bash
xcode-select --install
```

Windows OCR fails

- Run PowerShell as a normal user, not from a restricted environment.
- Check that Windows OCR and the relevant language pack are available.
- Try `.\install.ps1 -WithPaddleOCR` and then force PaddleOCR.

## Development

Install development dependencies:

```bash
python3 -m venv .venv
. .venv/bin/activate
python -m pip install -r requirements-dev.txt
```

Run tests:

```bash
python -m pytest -q
python -m py_compile scripts/image2context.py hooks/auto_image_fallback.py
```

Run a local smoke test:

```bash
python scripts/image2context.py testdata/sample.svg --json
```

## License

MIT
