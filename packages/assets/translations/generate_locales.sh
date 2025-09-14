#!/bin/bash

# Thư mục chứa các tệp JSON
LANGUAGE_DIR="assets/translations"

# Hàm để gộp nội dung JSON trong một thư mục
merge_json_files() { jq -s 'reduce .[] as $item ({}; . * $item)' "$1"/*.json > "$2"; }

# Gộp JSON cho tiếng Anh
merge_json_files "$LANGUAGE_DIR/en" "$LANGUAGE_DIR/en.json"
# Gộp JSON cho tiếng Việt
merge_json_files "$LANGUAGE_DIR/vi" "$LANGUAGE_DIR/vi.json"
# Gộp JSON cho tiếng nhật 
merge_json_files "$LANGUAGE_DIR/ja" "$LANGUAGE_DIR/ja.json"

# get generate locales "$LANGUAGE_DIR"
# Đường dẫn file Dart generate_locales.dart
dart run $LANGUAGE_DIR/generate_locales.dart