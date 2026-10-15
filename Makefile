.PHONY: help setup run generate format analyze test test-feature check clean

FEATURE ?= website

help:
	@echo "setup         Fetch dependencies and generate Injectable code"
	@echo "run           Run the Flutter app"
	@echo "generate      Regenerate generated Dart files"
	@echo "format        Format source and test files"
	@echo "analyze       Run static analysis"
	@echo "test          Run all unit and widget tests"
	@echo "test-feature  Run tests for FEATURE (default: website)"
	@echo "check         Format-check, analyze, and test"
	@echo "clean         Remove generated Flutter build output"

setup:
	flutter pub get
	dart run build_runner build --delete-conflicting-outputs

run:
	flutter run

generate:
	dart run build_runner build --delete-conflicting-outputs

format:
	dart format lib test integration_test

analyze:
	flutter analyze

test:
	flutter test

test-feature:
	flutter test test/features/$(FEATURE)

check:
	dart format --output=none --set-exit-if-changed lib test integration_test
	flutter analyze
	flutter test

clean:
	flutter clean
