// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:ffigen/src/code_generator.dart';
import 'package:ffigen/src/header_parser.dart' as parser;
import 'package:ffigen/src/config_provider.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart' as yaml;
import 'package:ffigen/src/strings.dart' as strings;

import '../test_utils.dart';

late Library actual;
void main() {
  group('unnamed_enums_test', () {
    setUpAll(() {
      logWarnings(Level.SEVERE);
      actual = parser.parse(
        Config.fromYaml(yaml.loadYaml('''
${strings.name}: 'NativeLibrary'
${strings.description}: 'Unnamed Enums Test'
${strings.output}: 'unused'
${strings.headers}:
  ${strings.entryPoints}:
    - 'test/header_parser_tests/native_func_typedef.h'
        ''') as yaml.YamlMap),
      );
    });

    test('Remove deeply nested unsupported types', () {
      expect(() => actual.getBindingAsString('funcNestedUnimplemented'),
          throwsA(TypeMatcher<NotFoundException>()));
    });

    test('Expected bindings', () {
      final gen = actual.generate();
      // Writing to file for debug purpose.
      final file =
          File('test/debug_generated/native_func_typedef_test-output.dart');

      try {
        expect(gen, '''// AUTO GENERATED FILE, DO NOT EDIT.
// 
// Generated by `package:ffigen`.
import 'dart:ffi' as ffi;

/// Unnamed Enums Test
class NativeLibrary{
/// Holds the Dynamic library.
final ffi.DynamicLibrary _dylib;

/// The symbols are looked up in [dynamicLibrary].
NativeLibrary(ffi.DynamicLibrary dynamicLibrary): _dylib = dynamicLibrary;

void func(
  ffi.Pointer<ffi.NativeFunction<_typedefC_4>> unnamed1,
) {
_func ??= _dylib.lookupFunction<_c_func,_dart_func>('func');
  return _func(
    unnamed1,
  );
}
_dart_func _func;

void funcWithNativeFunc(
  ffi.Pointer<ffi.NativeFunction<withTypedefReturnType>> named,
) {
_funcWithNativeFunc ??= _dylib.lookupFunction<_c_funcWithNativeFunc,_dart_funcWithNativeFunc>('funcWithNativeFunc');
  return _funcWithNativeFunc(
    named,
  );
}
_dart_funcWithNativeFunc _funcWithNativeFunc;

}

class struc extends ffi.Struct{
  ffi.Pointer<ffi.NativeFunction<_typedefC_2>> unnamed1;

}

typedef _typedefC_3 = ffi.Void Function(
);

typedef _typedefC_4 = ffi.Void Function(
  ffi.Pointer<ffi.NativeFunction<_typedefC_3>> ,
);

typedef _c_func = ffi.Void Function(
  ffi.Pointer<ffi.NativeFunction<_typedefC_4>> unnamed1,
);

typedef _dart_func = void Function(
  ffi.Pointer<ffi.NativeFunction<_typedefC_4>> unnamed1,
);

typedef insideReturnType = ffi.Void Function(
);

typedef withTypedefReturnType = ffi.Pointer<ffi.NativeFunction<insideReturnType>> Function(
);

typedef _c_funcWithNativeFunc = ffi.Void Function(
  ffi.Pointer<ffi.NativeFunction<withTypedefReturnType>> named,
);

typedef _dart_funcWithNativeFunc = void Function(
  ffi.Pointer<ffi.NativeFunction<withTypedefReturnType>> named,
);

typedef _typedefC_1 = ffi.Void Function(
);

typedef _typedefC_2 = ffi.Void Function(
  ffi.Pointer<ffi.NativeFunction<_typedefC_1>> ,
);

''');
        if (file.existsSync()) {
          file.delete();
        }
      } catch (e) {
        file.writeAsStringSync(gen);
        print('Failed test, Debug output: ${file.absolute.path}');
        rethrow;
      }
    });
  });
}
