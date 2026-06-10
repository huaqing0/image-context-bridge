# Image Context Bridge

[English](README.md)

**一个 Skill，自动检测模型有没有视觉能力——没有就自动把图片转成文字。**

---

## 这个 Skill 做什么

当你给纯文本模型（比如 DeepSeek 或本地大模型）发图片时，这个 Skill 会自动：

1. **检测**模型有没有视觉能力
2. 有——原图直传
3. 没有——自动 OCR 提取文字，打包成结构化证据

模型收到的是一份可读的文本，包含提取内容、置信度、文件信息，
以及清晰的边界标记——确保它不会编造不存在的视觉细节。

OCR 在本地运行，用的是操作系统的自带引擎。不需要上传云端，
不需要 API Key，没有调用次数限制。Linux 上会自动安装 PaddleOCR。

---

## 示例

```
输入：一张截图，显示「Error: connection refused on port 3000」
输出：证据包，包含：
      - 「Error: connection refused on port 3000」（置信度 1.000）
      - 文件名、格式、尺寸
      - 确认的事实、局限性、回答指引
结果：模型读到了报错文本，给出修复建议——从头到尾没「看」过图片
```

---

## 安装

```bash
bash install.sh
```

| 平台 | OCR 引擎 | 需要装什么 |
|------|---------|-----------|
| macOS | Apple Vision | Pillow |
| Windows | Windows 原生 OCR | Pillow |
| Linux | PaddleOCR | Pillow + PaddleOCR |

```bash
# 可选：任何平台都可以加装 PaddleOCR 获得更高精度
bash install.sh --with-paddleocr
```

## 使用

```bash
# 基本用法
image2context screenshot.png

# 带上你的问题
image2context error.png --question "为什么构建失败了？"

# JSON 输出
image2context screenshot.png --json

# Hook：自动判断是否需要转换
echo '{"message":"看看 ./error.png","model_supports_images":false}' | auto-image-fallback
```

---

## 许可

MIT
