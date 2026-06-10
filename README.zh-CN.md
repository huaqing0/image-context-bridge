# Image Context Bridge

[English](README.md)

> 让没有视觉能力的模型也能「看懂」图片

**解决的问题：** 给 DeepSeek 等纯文本模型发一张截图，它只会说「我无法处理图片」。这个工具在图片送到模型之前，先把图片转成 OCR 提取的文字 + 文件信息 + 置信度，模型看到的是文字而不是像素。

---

## 怎么做到的

不依赖任何第三方 OCR 服务。优先用操作系统自带的能力：

| 平台 | OCR 引擎 | 需要装什么 |
|------|---------|-----------|
| macOS | Apple Vision | 什么都不用装 |
| Windows | Windows 原生 OCR | 什么都不用装 |
| Linux | PaddleOCR | 安装脚本自动装 |
| 所有平台 | SVG 直接解析 XML | 零依赖 |

PaddleOCR 在 macOS/Windows 上也可以选装，作为高精度备选。

## 安装

macOS 和 Windows 上只需要装 [Pillow](https://python-pillow.org/) 读取图片元数据，OCR 引擎系统自带。

```bash
# macOS / Linux
bash install.sh

# 可选安装 PaddleOCR 获得更高精度
bash install.sh --with-paddleocr
```

```powershell
# Windows
.\install.ps1

# 可选 PaddleOCR
.\install.ps1 -WithPaddleOCR
```

## 使用

```bash
# 最简用法
image2context screenshot.png

# 带上你的问题，上下文更完整
image2context screenshot.png --question "这个报错是什么意思？"

# 手动指定 OCR 引擎
image2context screenshot.png --ocr-backend paddleocr
image2context screenshot.png --ocr-backend native
```

输出是结构化的 Markdown，可以直接贴给任何模型。

## 设计原则

**不假装看见了不存在的东西。**

OCR 只能提取文字，不能理解视觉内容。每个输出包里都明确区分了：

- `confirmed_facts` — OCR 确认提取到的内容
- `extracted_text` — 提取的文字 + 置信度
- `uncertainties` — 模型的局限和不确定之处

最后一行永远是：「不要编造非文字的视觉细节。」

## 适合

- 给 DeepSeek 等纯文本模型转发截图、终端报错、代码片段
- 让没有视觉能力的 Agent 处理图文混合任务
- 把 SVG 图表、菜单界面、设置页面转成可检索的文字
- 任何模型回复「我无法处理图片」的场景

## 不适合

- 需要理解人脸、表情、场景、配色、构图的任务
- 图片里没什么文字的情况
- 模型本身有视觉能力且正常接收到了图片

## 许可

MIT
