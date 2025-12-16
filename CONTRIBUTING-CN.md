# Flutter Graph View 贡献指南

感谢您有兴趣为 Flutter Graph View 做出贡献！本文档提供了参与本项目的指南和说明。

## 行为准则

参与本项目时，请尊重和体谅他人。我们欢迎所有人的贡献。

## 如何贡献

### 1. 报告问题

- 使用 GitHub issue 跟踪器报告错误或请求功能
- 创建新问题前请检查是否已存在
- 提供清晰的标题和描述
- 包含重现步骤（针对错误）
- 添加 Flutter 版本、设备信息和相关代码片段

### 2. 开发流程

#### 2.1 从项目主页进行 fork
#### 2.2 设置开发环境
```bash
# 复刻并克隆仓库
git clone https://github.com/YOUR_USERNAME/flutter_graph_view.git
cd flutter_graph_view

# 安装依赖
flutter pub get

# 运行样例
cd example
flutter create .
flutter run
```

#### 2.3 添加上你的创造力

- 新功能开发、Bug 修复、文档补充...
- 可以的话，尽可能在 example 当中，呈现改动后所带来的表现。

#### 2.4 让 `CHANGELOG.md` 听见你的声音

#### 2.5 到此一游

- 欢迎所有贡献者，不仅限于 PR，在 AUTHORS 文件中，添加到此一游信息。

#### 2.6 提交检查

- 运行 `dart format .`
- 提交
  - 提交的消息建议带有一定前缀，如：
    - feat
    - fix
    - doc
    - refac
    - chore
    - ...

#### 2.7 如果这些限制降低了你的热情，大胆忽略掉，请相信在创造面前，大家都是不拘小节的人。

### 3. 特别注意

当前仓库遵循宽松的 Apache License 2.0。
