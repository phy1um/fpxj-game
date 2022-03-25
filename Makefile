
#ENGINE_HASH=13da806be9e8da1957c0e672cd938f2095af0ae3
#ENGINE_HASH=86f880ebec61f1bbbf8c35ec352838ef7eea036b
ENGINE_HAS=2d449765312acc4a277b9031889750549612fbd5
DOIN=$(cd engine && make )

.PHONY: get-engine
get-engine:
	git clone https://github.com/phy1um/ps2-homebrew-livestreams engine
	cd engine && git checkout $(ENGINE_HASH)

.PHONY: run
run: scripts assets
	cd engine && make run	

.PHONY: runlove
runlove: scripts assets
	cd engine && love .

.PHONY: docker-elf
docker-elf:
	make -C engine assets
	make -C engine docker-elf

.PHONY: clean
clean:
	make -C engine clean

.PHONY: runps2
runps2: scripts
	make -C engine runps2

.PHONY: resetps2
resetps2:
	make -C engine resetps2

.PHONY: scripts
scripts:
	cp -r script/* engine/script/
	cp main.lua engine/

.PHONY: assets
assets:
	cp -r asset/* engine/asset/
	make -C engine assets

.PHONY: lualint
lualint:
	luac5.1 -p script/*.lua
