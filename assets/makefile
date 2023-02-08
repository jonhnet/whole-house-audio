all: system-diagram.svg

%.svg: %.odg
	libreoffice \
		-env:UserInstallation=file:///tmp/LibreOffice_Conversion_$(USER) \
		--headless --convert-to svg:$@ --outdir $(PWD) $<
