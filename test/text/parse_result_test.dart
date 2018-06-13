// Portions of this work are Copyright 2018 The Time Machine Authors. All rights reserved.
// Portions of this work are Copyright 2018 The Noda Time Authors. All rights reserved.
// Use of this source code is governed by the Apache License 2.0, as found in the LICENSE.txt file.
import 'dart:async';
import 'dart:math' as math;
import 'dart:mirrors';

import 'package:time_machine/time_machine.dart';
import 'package:time_machine/time_machine_calendars.dart';
import 'package:time_machine/time_machine_globalization.dart';
import 'package:time_machine/time_machine_patterns.dart';
import 'package:time_machine/time_machine_text.dart';
import 'package:time_machine/time_machine_utilities.dart';

import 'package:test/test.dart';
import 'package:matcher/matcher.dart';
import 'package:time_machine/time_machine_timezones.dart';

import '../time_machine_testing.dart';
import 'pattern_test_base.dart';
import 'pattern_test_data.dart';
import 'test_cultures.dart';
import 'text_cursor_test_base_tests.dart';

Future main() async {
  await runTests();
}

@private final ParseResult<int> FailureResult = ParseResult.forInvalidValue<int>(new ValueCursor("text"), "text");

@Test()
void Value_Success()
{
  ParseResult<int> result = ParseResult.forValue<int>(5);
  expect(5, result.value);
}

@Test()
void Value_Failure()
{
  expect(() => FailureResult.value.hashCode, willThrow<UnparsableValueError>());
}

@Test()
void Exception_Success()
{
  ParseResult<int> result = ParseResult.forValue<int>(5);
  expect(() => result.error.hashCode, throwsStateError);
}

@Test()
void Exception_Failure()
{
  // Assert.IsInstanceOf<UnparsableValueError>(FailureResult.Exception);
  expect(FailureResult.error, new isInstanceOf<UnparsableValueError>());
}

@Test()
void GetValueOrThrow_Success()
{
  ParseResult<int> result = ParseResult.forValue<int>(5);
  expect(5, result.getValueOrThrow());
}

@Test()
void GetValueOrThrow_Failure()
{
  expect(() => FailureResult.getValueOrThrow(), willThrow<UnparsableValueError>());
}

@Test()
void TryGetValue_Success() {
  ParseResult<int> result = ParseResult.forValue<int>(5);
  //expect(result.TryGetValue(-1, out int actual), isTrue);
  int actual;
  expect(actual = result.TryGetValue(-1), isNot(-1));
  expect(5, actual);
}

@Test()
void TryGetValue_Failure()
{
// expect(FailureResult.TryGetValue(-1, out int actual), isFalse);

  int actual;
  expect(actual = FailureResult.TryGetValue(-1), -1);
  expect(-1, actual);
}

@Test()
void Convert_ForFailureResult()
{
  ParseResult<String> converted = FailureResult.convert((x) => "xx${x}xx");
  expect(() => converted.getValueOrThrow(), willThrow<UnparsableValueError>());
}

@Test()
void Convert_ForSuccessResult()
{
  ParseResult<int> original = ParseResult.forValue<int>(10);
  ParseResult<String> converted = original.convert((x) => "xx${x}xx");
  expect("xx10xx", converted.value);
}

@Test()
void ConvertError_ForFailureResult()
{
  ParseResult<String> converted = FailureResult.convertError<String>();
  expect(() => converted.getValueOrThrow(), willThrow<UnparsableValueError>());
}

@Test()
void ConvertError_ForSuccessResult()
{
  ParseResult<int> original = ParseResult.forValue<int>(10);
expect(() => original.convertError<String>(), throwsStateError);
}

@Test()
void ForException() {
  Error e = new Error();
  ParseResult<int> result = ParseResult.forError<int>(() => e);
  expect(result.success, isFalse);
  expect(identical(e, result.error), isTrue);
}

