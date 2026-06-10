# Image Context Bridge

[English](README.md)

**一个 Skill，自动检测模型有没有视觉能力——没有就自动把图片转成文字。**

---

## 这个 Skill 做什么

当你给纯文本模型发图片时，这个 Skill 会自动：

1. **检测**模型有没有视觉能力
2. 有——原图直传
3. 没有——自动 OCR 提取文字，打包成结构化证据

模型收到的是一份可读的文本——包含提取内容、置信度、以及清晰的边界标记，
确保它不会编造不存在的视觉细节。

---

## 示例

```
输入：一张终端报错截图 「connection refused on port 3000」
输出：证据包，包含：
      - 「connection refused on port 3000」（置信度 1.000）
      - 文件名、格式、尺寸
      - 确认的事实、局限性、回答指引
结果：纯文本模型能读懂报错内容，给出修复建议
```

---

## 安装

```bash
bash install.sh
```

## 使用

```bash
image2context screenshot.png
image2context error.png --question "为什么构建失败了？"
```

---

## 许可

MIT
