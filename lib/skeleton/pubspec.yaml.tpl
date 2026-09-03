name: {{ name }}
description: A Maat application.
version: 0.1.0
publish_to: none
environment:
  sdk: ^3.12.0
dependencies:
  maat: {{ maat_dependency }}
  seshat_maat: {{ seshat_maat_dependency }}
  amarna: {{ amarna_dependency }}{{ view_dependency }}
dev_dependencies:
  lints: ^6.1.0
  test: ^1.31.2
{{ dependency_overrides }}
