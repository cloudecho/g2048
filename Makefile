VER?=0.1.3

ver:
	sed -iE "s/kVersion = '.*'/kVersion = '$(VER)'/g"  lib/src/version.dart

tag: ver
	git add .
	git commit -m "ver $(VER)"
	git tag $(VER)
	git push
	git push origin $(VER)
