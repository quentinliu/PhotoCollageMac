# PhotoCollageMac

macOS 照片拼图工具 - 将多张照片拼接成一张美丽的拼图。

## 功能特点

- 🎨 **多种网格布局**：支持 2×2、3×3、4×4 等多种网格布局
- 📷 **自由选择照片**：从相册选择最多 16 张照片
- 🎛️ **自定义设置**：
  - 调整照片间距（0-20 像素）
  - 设置圆角大小
  - 选择背景颜色或渐变
- 🖼️ **实时预览**：所见即所得的预览效果
- 📦 **高清导出**：支持 8K 分辨率导出
- 🇨🇳 **中文界面**：完整的中文本地化

## 系统要求

- macOS 13.0 或更高版本

## 安装

### 方法一：直接下载

1. 从 [Releases](https://github.com/quentinliu/PhotoCollageMac/releases) 下载最新版本
2. 解压并运行 `PhotoCollageMac.app`

### 方法二：从源码编译

```bash
# 克隆项目
git clone https://github.com/quentinliu/PhotoCollageMac.git
cd PhotoCollageMac

# 使用 XcodeGen 生成项目
# 确保已安装 XcodeGen: brew install xcodegen
xcodegen generate

# 用 Xcode 打开并编译
open PhotoCollageMac.xcodeproj
```

## 使用方法

1. **选择布局**：从左侧面板选择网格布局（如 2×2、3×3）
2. **添加照片**：点击"选择照片"按钮选择图片
3. **调整设置**：
   - 间距：拖动滑块调整照片之间的间距
   - 圆角：启用并调整照片圆角大小
   - 背景：选择纯色或渐变背景
4. **预览**：实时查看拼图效果
5. **导出**：点击"生成拼图"并保存

## 快捷键

- `⌘O`：打开照片选择器
- `⌘S`：保存拼图

## 项目结构

```
PhotoCollageMac/
├── Sources/
│   ├── App/
│   │   └── PhotoCollageMacApp.swift    # 应用入口
│   ├── Models/
│   │   └── PhotoCollageEngine.swift    # 拼图引擎
│   └── Views/
│       ├── ContentView.swift            # 主导航
│       ├── HomeView.swift               # 首页
│       ├── CreateView.swift             # 创建页面
│       └── TemplatesView.swift          # 模板页面
├── Resources/
│   ├── Info.plist
│   └── PhotoCollageMac.entitlements
└── project.yml                          # XcodeGen 配置
```

## 技术栈

- **SwiftUI** - 现代 UI 框架
- **AppKit** - 原生 macOS 图像处理
- **XcodeGen** - 项目生成工具

## 许可证

Apache License 2.0 - 查看 [LICENSE](LICENSE) 文件

## 贡献

欢迎提交 Issue 和 Pull Request！
