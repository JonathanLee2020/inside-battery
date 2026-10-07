.PHONY: build test app run install clean

build:
	swift build

test: build
	"$$(swift build --show-bin-path)/InsideBattery" --self-test
	swift test

app:
	sh scripts/build-app.sh

run: app
	open "dist/Inside Battery.app"

install: app
	mkdir -p "$(HOME)/Applications"
	ditto "dist/Inside Battery.app" "$(HOME)/Applications/Inside Battery.app"
	open "$(HOME)/Applications/Inside Battery.app"

clean:
	swift package clean
	rm -rf dist
