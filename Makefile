fresh: dartanalyze

clean:
	@echo "------------------------------"
	@echo "Flutter CLEAN"
	@flutter clean
	@if [ $$? -ne 0 ]; then \
        echo "Flutter CLEAN Failed"; \
        exit 1; \
    fi

pubget: clean
	@echo " "
	@echo "Flutter PUB GET"
	@flutter pub get
	@if [ $$? -ne 0 ]; then \
        echo "Flutter PUB GET Failed"; \
        exit 1; \
    fi

dartanalyze: pubget
	@echo " "
	@echo "Dart ANALYZE"
	@dart analyze
	@if [ $$? -ne 0 ]; then \
        echo "\n😱 Dart ANALYZE found some issues that needs to be resolved"; \
    fi
	@echo "------------------------------"

.PHONY: fresh clean pubget dartanalyze