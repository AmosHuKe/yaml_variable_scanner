📓 语言：[English](README.md) | 中文  
💡 查看：[迁移指南][] 了解如何从破坏性改动中迁移为可用代码  

<br/><br/>

<h1 align="center">YAML Variable Scanner</h1>

<p align="center">
  <a href="https://pub.dev/packages/yaml_variable_scanner"><img src="https://img.shields.io/pub/v/yaml_variable_scanner?color=3e4663&label=stable&logo=flutter" alt="stable package" /></a>
  <a href="https://pub.dev/packages/yaml_variable_scanner"><img src="https://img.shields.io/pub/v/yaml_variable_scanner?color=3e4663&label=dev&logo=flutter&include_prereleases" alt="dev package" /></a>
  <a href="https://pub.dev/packages/yaml_variable_scanner/score"><img src="https://img.shields.io/pub/points/yaml_variable_scanner?color=2E8B57&logo=flutter" alt="pub points" /></a>
  <a href="https://pub.dev/packages/yaml_variable_scanner"><img src="https://img.shields.io/github/languages/top/AmosHuKe/yaml_variable_scanner?color=00B4AB" alt="top language" /></a>
</p>

<p align="center">
  <strong>YAML 变量扫描器，用于扫描多个文件中可以使用 YAML 变量的文本。</strong>
</p>

<br/>

<div align="center">
  <img alt="example-video.gif" src="https://raw.githubusercontent.com/AmosHuKe/yaml_variable_scanner/main/README/example-video.gif" />

  [[example][]]

</div>

<br/>

## 目录 🪄

<sub>

- [特性](#特性-)

- [示例](#示例-)

- [安装](#安装-)

- [简单用法](#简单用法-)

  - [运行检查（配置文件）](#运行检查配置文件)

  - [yaml_variable_scanner 配置文件](#yaml_variable_scanner-配置文件)

- [使用](#使用-)

  - [YamlVariableScanner.run() 参数](#yamlvariablescannerrun-参数-)

- [许可证](#许可证-)

</sub>


## 特性 ✨

> [!IMPORTANT]  
> 目前仅适用于以下变量使用方式的检查：  
> - `{{ x.xx.xxx }}`  

- 📂 可指定多文件（Glob 语法）
- 🗑️ 可指定忽略检查
  - 忽略文件（Glob 语法）
  - 忽略 YAML 变量、文本段落（RegExp 语法）
- 🔍 支持文本中已有 YAML 变量的检查
- 🔦 详细的控制台打印（附带统计）


## 示例 💡

使用以下指令运行 [example][] 中的检查：

```sh
$ dart run example --help

$ dart run example check
```


## 安装 🎯
### 版本兼容 🐦  

| Flutter / Dart               | 3.19.0+ / 3.3.0+   |  
| ---                          | :----------------: |  
| yaml_variable_scanner 0.0.1+ | ✅                 |  


### 添加 yaml_variable_scanner 📦  

使用 Flutter 运行以下指令，  

```sh
$ dart pub add yaml_variable_scanner
```

或手动将 `yaml_variable_scanner` 添加到 `pubspec.yaml` 依赖项中。  

```yaml
dependencies:
  yaml_variable_scanner: ^latest_version
```


## 简单用法 📖  
### 运行检查（配置文件）

```dart
import 'dart:io';
import 'package:yaml_variable_scanner/yaml_variable_scanner.dart';

YamlVariableScanner.run(
  /// yaml_variable_scanner 配置文件
  './yaml_variable_scanner.yaml',
  stdout,
);
```


### yaml_variable_scanner 配置文件

1. 创建 [yaml_variable_scanner.yaml][] 文件。  
2. 完善 [yaml_variable_scanner.yaml][] 配置。  

```yaml
yaml_variable_scanner:

  # YAML 变量的文件路径
  yamlFilePath:
    - path: "test/siteA.yaml" # YAML 文件路径（Glob 语法）
      variablePrefix: "a." # 变量前缀。例如： `a.` -> `a.x.xx`
    - path: "test/siteB.yaml"
      variablePrefix: "b."

  # 忽略 YAML 文件的路径
  #
  # （Glob 语法）
  ignoreYamlFilePath:
    - "test/test.yaml"

  # 忽略 YAML Key
  #
  # 例如："^a.bb$"
  #
  # （RegExp 语法）
  ignoreYamlKey:
    - ^description$
  
  # 检查文件内容的路径
  #
  # （Glob 语法）
  checkFilePath:
    - "test/**/*.md"

  # 忽略需要检查的文件路径
  #
  # （Glob 语法）
  ignoreCheckFilePath:
    - "test/content/**.md"

  # 忽略不需要匹配检查的文本
  #
  # 例如： 
  # - `r"^\s*---([\s\S]*?)---$"`
  # - `r"^\s*{%-?\s*comment\s*-?%}([\s\S]*?){%-?\s*endcomment\s*-?%}$"`
  # - `r"^\s*<!---?\s*([\s\S]*?)\s*-?-->$"`
  #
  # （RegExp 语法）
  ignoreCheckText:
    # --- xxx ---
    - ^\s*---([\s\S]*?)---$

    # {%- comment %} xxx {% endcomment -%}
    - ^\s*{%-?\s*comment\s*-?%}([\s\S]*?){%-?\s*endcomment\s*-?%}$

    # <!-- xxx -->
    - ^\s*<!---?\s*([\s\S]*?)\s*-?-->$
```


## 使用 📖  
### `YamlVariableScanner.run()` 参数 🤖  

| 参数名 | 类型 | 默认值 | 描述 |  
| --- | --- | --- | --- |
| configPath <sup>`required`</sup> | `String` | - | [yaml_variable_scanner.yaml][] 配置文件路径。 |  
| stdout <sup>`required`</sup> | `Stdout` | - | 来自 dart:io 的 stdout |  
| enablePrint | `bool` | true | 是否开启控制台打印结果。 |  


## 许可证 📄  

[![MIT License](https://img.shields.io/badge/license-MIT-green)](https://github.com/AmosHuKe/yaml_variable_scanner/blob/main/LICENSE)  
根据 MIT 许可证开源。

© AmosHuKe


[迁移指南]: https://github.com/AmosHuKe/yaml_variable_scanner/blob/main/guides/migration_guide.md
[yaml_variable_scanner.yaml]: https://github.com/AmosHuKe/yaml_variable_scanner/blob/main/yaml_variable_scanner.yaml
[example]: https://github.com/AmosHuKe/yaml_variable_scanner/tree/main/example