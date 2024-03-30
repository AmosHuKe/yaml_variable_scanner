📓 Language: English | [中文](README-ZH.md)  
💡 See the [Migration Guide][] to learn how to migrate between breaking changes.  

<br/><br/>

<h1 align="center">YAML Variable Scanner</h1>

<p align="center">
  <a href="https://pub.dev/packages/yaml_variable_scanner"><img src="https://img.shields.io/pub/v/yaml_variable_scanner?color=3e4663&label=stable&logo=flutter" alt="stable package" /></a>
  <a href="https://pub.dev/packages/yaml_variable_scanner"><img src="https://img.shields.io/pub/v/yaml_variable_scanner?color=3e4663&label=dev&logo=flutter&include_prereleases" alt="dev package" /></a>
  <a href="https://pub.dev/packages/yaml_variable_scanner/score"><img src="https://img.shields.io/pub/points/yaml_variable_scanner?color=2E8B57&logo=flutter" alt="pub points" /></a>
  <a href="https://pub.dev/packages/yaml_variable_scanner"><img src="https://img.shields.io/github/languages/top/AmosHuKe/yaml_variable_scanner?color=00B4AB" alt="top language" /></a>
</p>

<p align="center">
  <strong>YAML Variable Scanner, used to scan multiple files for text that can use YAML variables.</strong>
</p>

<br/>

<div align="center">
<!-- -->
</div>

<br/>

## Table of contents 🪄

<sub>

- [Features](#features-)

- [Example](#example-)

- [Install](#install-)

- [Simple usage](#simple-usage-)

  - [Run checks (config file)](#run-checks-config-file)

  - [yaml_variable_scanner config file](#yaml_variable_scanner-config-file)

- [Usage](#usage-)

  - [YamlVariableScanner.run() parameters](#yamlvariablescannerrun-parameters-)

- [License](#license-)

</sub>


## Features ✨  

> [!IMPORTANT]  
> Currently, only the following variables support checking:  
> - `{{ x.xx.xxx }}`  

- 📂 Multiple files can be specified (Glob syntax)
- 🗑️ Ignore checks can be specified
  - Ignore files (Glob syntax)
  - Ignore YAML variables, text paragraphs (RegExp syntax)
- 🔍 Support for checking existing YAML variables in text
- 🔦 Detailed console printout (with statistics)


## Example 💡

Use the following command to run the check in the [example][]:

```sh
$ dart run example --help

$ dart run example check
```


## Install 🎯
### Versions compatibility 🐦  

| Flutter / Dart               | 3.19.0+ / 3.3.0+   |  
| ---                          | :----------------: |  
| yaml_variable_scanner 0.0.1+ | ✅                 |  


### Add package 📦  

Run this command with Flutter,  

```sh
$ dart pub add yaml_variable_scanner
```

or add `yaml_variable_scanner` to `pubspec.yaml` dependencies manually.  

```yaml
dependencies:
  yaml_variable_scanner: ^latest_version
```


## Simple usage 📖 
### Run checks (config file)

```dart
import 'dart:io';
import 'package:yaml_variable_scanner/yaml_variable_scanner.dart';

YamlVariableScanner.run(
  /// yaml_variable_scanner config file
  './yaml_variable_scanner.yaml',
  stdout,
  /// 'site.$yamlKey' -> 'site.x.xxx'
  prefix: (yamlKey) => 'site.$yamlKey',
);
```


### yaml_variable_scanner config file

1. Create the [yaml_variable_scanner.yaml][] file.  
2. Complete the [yaml_variable_scanner.yaml][] configuration.  

```yaml
yaml_variable_scanner:

  # File path for YAML variables
  #
  # (Glob Syntax)
  yamlFilePath:
    - "test/*.yaml"

  # Ignore YAML file path
  #
  # (Glob Syntax)
  ignoreYamlFilePath:
    - "test/test.yaml"

  # Ignore YAML Key
  #
  # e.g. "^a.bb$"
  #
  # (RegExp Syntax)
  ignoreYamlKey:
    - ^description$
  
  # File path for check file contents
  #
  # (Glob Syntax)
  checkFilePath:
    - "test/**/*.md"

  # Ignore file paths to check
  #
  # (Glob Syntax)
  ignoreCheckFilePath:
    - "test/content/**.md"

  # Ignore text that doesn't need to match
  #
  # e.g. 
  # - `r"^---([\s\S]*?)---$"`
  # - `r"^{%\s*comment\s*%}([\s\S]*?){%\s*endcomment\s*%}$"`
  #
  # (RegExp Syntax)
  ignoreCheckText:
    # --- 
    # xxx
    # ---
    - ^---([\s\S]*?)---$

    # {% comment %}
    #   xxx
    # {% endcomment %}
    - ^{%\s*comment\s*%}([\s\S]*?){%\s*endcomment\s*%}$
```


## Usage 📖  
### `YamlVariableScanner.run()` parameters 🤖  

| Parameter | Type | Default | Description |  
| --- | --- | --- | --- |
| configPath <sup>`required`</sup> | `String` | - | [yaml_variable_scanner.yaml][] config file path. |  
| stdout <sup>`required`</sup> | `Stdout` | - | stdout from dart:io |  
| prefix | `PrefixFunction?` | null | Prefix used for YAML variables. <br/> e.g. <br/> `(yamlKey) => 'site.$yamlKey'` <br/> It is possible to check for variables in the text that are used in the manner of `{{ site.x.xx }}`. |  
| enablePrint | `bool` | true | Enable console printing of results. |  


## License 📄  

[![MIT License](https://img.shields.io/badge/license-MIT-green)](https://github.com/AmosHuKe/yaml_variable_scanner/blob/main/LICENSE)  
Open sourced under the MIT license.  

© AmosHuKe


[Migration Guide]: https://github.com/AmosHuKe/yaml_variable_scanner/blob/main/guides/migration_guide.md
[yaml_variable_scanner.yaml]: https://github.com/AmosHuKe/yaml_variable_scanner/blob/main/yaml_variable_scanner.yaml
[example]: https://github.com/AmosHuKe/yaml_variable_scanner/tree/main/example