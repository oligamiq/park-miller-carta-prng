{
  "targets": [
    {
      "target_name": "addon",
      "include_dirs": ["<!@(node -p \"require('node-addon-api').include\")"],
      "dependencies": ["<!(node -p \"require('node-addon-api').gyp\")"],
      "defines": [ "NAPI_DISABLE_CPP_EXCEPTIONS" ],
      "sources": ["src/napi.cc"],
      'conditions': [
        ['OS=="mac"', {
          "libraries": ["<(module_root_dir)/target/release/libprng.dylib"]
        }],
        ['OS=="linux"', {
          "libraries": ["<(module_root_dir)/target/release/libprng.so"]
        }],
        ['OS=="win"', {
          "libraries": ["<(module_root_dir)/target/release/libprng.dll"]
        }]
      ]
    }
  ]
}