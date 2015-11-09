// Copyright (c) 2015, the Dart Team. All rights reserved. Use of this
// source code is governed by a BSD-style license that can be found in
// the LICENSE file.

// File being transformed by the reflectable transformer.
// Uses `invoke` on top level entities.

@myReflectable
library test_reflectable.test.libraries_test;

import 'package:reflectable/reflectable.dart';
import 'package:unittest/unittest.dart';

class MyReflectable extends Reflectable {
  const MyReflectable()
      : super(
            libraryCapability,
            const TopLevelInvokeCapability(r"^myFunction$"),
            declarationsCapability);
}

class MyReflectable2 extends Reflectable {
  const MyReflectable2()
      : super(declarationsCapability, libraryCapability,
            const TopLevelInvokeMetaCapability(Test));
}

class MyReflectable3 extends Reflectable {
  const MyReflectable3() : super(typeCapability);
}

const myReflectable = const MyReflectable();
const myReflectable2 = const MyReflectable2();
const myReflectable3 = const MyReflectable3();

@myReflectable2
class C {}

@myReflectable3
class D {}

myFunction() => "hello";

class Test {
  const Test();
}

@Test()
var p = 10;

@Test()
set setter(x) => p = x + 1;

@Test()
get getter => "10";

final throwsANoSuchCapabilityError =
    throwsA(const isInstanceOf<NoSuchCapabilityError>());

main() {
  test('invoke function, getter', () {
    LibraryMirror lm =
        myReflectable.findLibrary('test_reflectable.test.libraries_test');
    expect(lm.invoke('myFunction', []), 'hello');
    expect(Function.apply(lm.invokeGetter('myFunction'), []), 'hello');
    expect(() => lm.invokeGetter("getter"), throwsANoSuchCapabilityError);
    MethodMirror myFunctionMirror = lm.declarations["myFunction"];
    expect(myFunctionMirror.owner, lm);
  });
  test('owner, setter, TopLevelMetaInvokeCapability', () {
    LibraryMirror lm = myReflectable2.reflectType(C).owner;
    expect(lm.qualifiedName, "test_reflectable.test.libraries_test");
    expect(lm.simpleName, "test_reflectable.test.libraries_test");
    expect(lm.invokeSetter('setter=', 11), 11);
    expect(p, 12);
    expect(lm.invokeGetter("getter"), "10");
    VariableMirror pMirror = lm.declarations["p"];
    MethodMirror getterMirror = lm.declarations["getter"];
    MethodMirror setterMirror = lm.declarations["setter="];
    expect(pMirror.owner, lm);
    expect(getterMirror.owner, lm);
    expect(setterMirror.owner, lm);
  });
  test("No libraryCapability", () {
    expect(() => myReflectable3.reflectType(D).owner,
        throwsANoSuchCapabilityError);
    expect(
        () => myReflectable3
            .findLibrary("test_reflectable.test.libraries_test")
            .owner,
        throwsANoSuchCapabilityError);
  });
}
