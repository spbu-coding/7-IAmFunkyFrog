include CONFIG.cfg

.PHONY: all, check, clean

OBJECTS = sorter

RESULTS_DIR = results

TEST_FILENAMES = 1 2 3 4 5 6 last
TMP_STDOUT_FILENAME = stdout.buf

TEST_SUCCESS_MESSAGE = TEST PASSED

all: $(BUILD_DIR) $(BUILD_DIR)/$(NAME)

$(BUILD_DIR)/%.o: $(SOURCE_DIR)/%.c
	$(CC) -c $< -o $@

$(BUILD_DIR)/$(NAME): $(foreach object_name, $(OBJECTS), $(BUILD_DIR)/$(object_name).o)
	$(CC) $^ -o $@

$(BUILD_DIR):
	mkdir $@

$(RESULTS_DIR):
	mkdir $@

$(RESULTS_DIR)/%.txt: $(TEST_DIR)/%.in $(TEST_DIR)/%.out $(BUILD_DIR)/$(NAME)
	@$(BUILD_DIR)/$(NAME) $< > $(RESULTS_DIR)/$(TMP_STDOUT_FILENAME); \
	test_out_filename=$$( echo $< | sed 's/.in/.out/g'); \
	program_out_filename=$(RESULTS_DIR)/$(TMP_STDOUT_FILENAME); \
	cmp $$test_out_filename $$program_out_filename > $@; \
	if [ $$? = 0 ]; \
    	then echo $(TEST_SUCCESS_MESSAGE) > $@; \
    fi

check: $(RESULTS_DIR) $(foreach test_name, $(TEST_FILENAMES), $(RESULTS_DIR)/$(test_name).txt) all
	@test_failed=0; \
	for filename in $(TEST_FILENAMES); \
	do \
		echo "Test $$filename:"; \
		cat $(RESULTS_DIR)/$$filename.txt; \
		if [ "$$(cat $(RESULTS_DIR)/$${filename}.txt)" != "$(TEST_SUCCESS_MESSAGE)" ]; \
		then test_failed=$$(($$test_failed + 1)); \
		fi; \
	done; \
	if [ $$test_failed != 0 ]; \
	then exit 1; \
	fi; \

clean:
	rm -rf $(BUILD_DIR)/*
	rm -rf $(RESULTS_DIR)