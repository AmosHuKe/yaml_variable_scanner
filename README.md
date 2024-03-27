YamlVariableScanner.run(
  './yaml_variable_scanner.yaml',
  stdout,
  prefix: (yamlKey) => 'site.$yamlKey',
  enablePrint: true,
);