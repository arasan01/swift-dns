build:
	swift build

release:
	swift build -c release

test:
	swift test

format:
	swift format --in-place --recursive Sources Tests Package.swift
