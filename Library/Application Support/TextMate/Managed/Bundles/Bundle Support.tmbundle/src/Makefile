DST=../Support/shared/bin/find_app

$(DST): find_app.cc
	xcrun g++ -Wall -Os -mmacosx-version-min=10.9 -framework ApplicationServices -o $@ $<

clean:
	rm $(DST)

.PHONY: clean
