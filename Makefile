SHELL := bash

COMPONENTS := $(shell ls ops2deb-*yml | cut -f2 -d "-" | cut -f1 -d ".")

OUTPUT_BASE_PATH := build

export OPS2DEB_REPOSITORY := http://deb.wakemeops.com/ stable

default:
	@echo -e 'Usage:'
	@echo -e '\nprerequisite                                                   '
	@echo '* install-wakemeops           add wakemeops repository              '
	@echo -e '\nops2deb                                                        '
	@echo '* generate-{component}        generate deb from yaml                '
	@echo '* build-{component}           build generated sources               '
	@echo '* update                      check binaries updates                '
	@echo -e '\nchecks                                                         '
	@echo '* install-packages            install generated packages            '
	@echo '* check-packages              check generated packages              '
	@echo -e '\naptly                                                          '
	@echo '* push-{component}            push to s3 repository                 '
	@echo '* publish                     publish to s3 repository              '
	@echo -e '\ndocumentation                                                  '
	@echo '* docs                        run mkdocs build                      '
	@echo '* docs-dev                    run mkdocs serve from wakemebot image '

install-wakemeops:
	curl https://gitlab.com/upciti/wakemeops/-/snippets/2189589/raw/main/install.sh | bash -s $(COMPONENTS)

generate-%:
	mkdir -p $(OUTPUT_BASE_PATH)/$*
	ops2deb generate -c ./ops2deb-$*.yml -w $(OUTPUT_BASE_PATH)/$*

build-%:
	ops2deb build -w $(OUTPUT_BASE_PATH)/$*

update:
	for component in $(COMPONENTS); do \
		ops2deb update \
		-c ops2deb-$${component}.yml \
		--output-file ops2deb-$${component}.log; \
	done

install-packages: install-wakemeops
	PACKAGE_PATH=$$(find $(OUTPUT_BASE_PATH) -name "*.deb"); \
		dpkg -i $$PACKAGE_PATH || true
	apt-get update -yq
	apt-get install -fy

check-packages:
	export PACKAGE_PATH=$$(find $(OUTPUT_BASE_PATH) -name "*.deb"); \
	for package in $$PACKAGE_PATH; do \
		n=$$(dpkg --info $$package | sed -n "s/ Package. \(.*\)/\1/p"); \
		dpkg -s $$n || exit 77; \
	done

push-%:
	if [ -d "build/$*" ]; then \
		wakemebot aptly push wakemeops-$* \
			$(OUTPUT_BASE_PATH)/$* \
			--server /host/data/aptly/aptly.sock; \
	fi

publish:
	curl -v -f -s -XPUT --unix-socket /host/data/aptly/aptly.sock \
	-H 'Content-Type: application/json' --data \
	"{\"ForceOverwrite\":true, \"Signing\" : \
	{\"GpgKey\":\"wakemebot-dev@upciti.com\", \"Batch\":true}}" \
	"http://_/api/publish/s3:wakemeops-eu-west-3:./stable"

docs:
	@mkdocs build -d public

docs-dev:
	@docker run --rm -it -p 8000:8000 -w /docs -v $$(pwd):/docs upciti/wakemebot:main mkdocs serve --dev-addr=0.0.0.0:8000

.PHONY: install-wakemeops install-packages check-packages publish docs docs-dev
