VER?=0.1.5

ver:
	sed -iE "s/kVersion = '.*'/kVersion = '$(VER)'/g"  lib/src/version.dart

tag: ver
	git add .
	git commit -m "ver $(VER)"
	git push

pushtag: tag
	git tag $(VER)
	git push origin $(VER)
