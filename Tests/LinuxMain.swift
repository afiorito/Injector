import XCTest

import InjectorTests

var tests = [XCTestCaseEntry]()
tests += InjectorTests.__allTests()

XCTMain(tests)
