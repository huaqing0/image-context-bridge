# Install Options

The README keeps common install commands. This file lists additional install options.

## Windows

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/huaqing0/image-context-bridge/main/install-remote.ps1 | iex"
```

Install the Skill wrapper for Claude Code on Windows:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command '$env:IMAGE_CONTEXT_BRIDGE_TARGET="claude"; irm https://raw.githubusercontent.com/huaqing0/image-context-bridge/main/install-remote.ps1 | iex'
```

## Other Skill Targets

Install into the generic agents Skill directory:

```bash
curl -fsSL https://raw.githubusercontent.com/huaqing0/image-context-bridge/main/install-remote.sh | bash -s -- --target agents
```

Install all known Skill targets:

```bash
curl -fsSL https://raw.githubusercontent.com/huaqing0/image-context-bridge/main/install-remote.sh | bash -s -- --target all
```

## Custom Paths

```bash
curl -fsSL https://raw.githubusercontent.com/huaqing0/image-context-bridge/main/install-remote.sh | bash -s -- --app-dir "$HOME/Tools/image-context-bridge" --bin-dir "$HOME/bin"
```

Use a custom Skill root. The installer creates `<skill-root>/image-context`:

```bash
curl -fsSL https://raw.githubusercontent.com/huaqing0/image-context-bridge/main/install-remote.sh | bash -s -- --skill-dir "$HOME/.claude/skills"
```

## PaddleOCR

```bash
curl -fsSL https://raw.githubusercontent.com/huaqing0/image-context-bridge/main/install-remote.sh | bash -s -- --with-paddleocr
```

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command '$env:IMAGE_CONTEXT_BRIDGE_WITH_PADDLEOCR="1"; irm https://raw.githubusercontent.com/huaqing0/image-context-bridge/main/install-remote.ps1 | iex'
```

Skip PaddleOCR on Linux for metadata/SVG extraction only, or when managing the OCR backend separately:

```bash
curl -fsSL https://raw.githubusercontent.com/huaqing0/image-context-bridge/main/install-remote.sh | bash -s -- --no-paddleocr
```

## Manual Clone

```bash
git clone https://github.com/huaqing0/image-context-bridge.git
cd image-context-bridge
bash install.sh
```

```powershell
git clone https://github.com/huaqing0/image-context-bridge.git
cd image-context-bridge
.\install.ps1
```

## Hook Check

This simulates a model that does not support images. If `action` is `replace_with_context`, the hook is replacing the image with a text evidence packet:

```bash
echo '{"message":"Please analyze ~/.image-context-bridge/testdata/sample.svg","model_supports_images":false}' | auto-image-fallback
```

```json
{"action":"replace_with_context","contexts":["..."]}
```
