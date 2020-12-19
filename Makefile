include CONFIG.cfg

.PHONY: all, check, clean

OBJECTS = sorter

RESULTS_DIR = results

TEST_FILENAMES = 1 2 3 4 5 6 last
TMP_STDOUT_FILENAME = stdout.buf

TEST_SUCCESS_MESSAGE = TEST PASSED

$(BUILD_DIR)/%.o: $(SOURCE_DIR)/%.c
	$(CC) -c $< -o $@

$(BUILD_DIR)/$(NAME): $(foreach object_name, $(OBJECTS), $(BUILD_DIR)/$(object_name).o)
	$(CC) $^ -o $@

$(BUILD_DIR):
	mkdir $@

$(RESULTS_DIR):
	mkdir $@
	touch $@/$(TMP_STDOUT_FILENAME)

$(RESULTS_DIR)/%.txt: $(TEST_DIR)/%.in $(TEST_DIR)/%.out $(BUILD_DIR)/$(NAME)
	@echo "$@ checking..."; \
	$(BUILD_DIR)/$(NAME) $< > $(RESULTS_DIR)/$(TMP_STDOUT_FILENAME); \
	test_out_filename=$$( echo $< | sed 's/.in/.out/g'); \
	program_out_filename=$(RESULTS_DIR)/$(TMP_STDOUT_FILENAME); \
	cmp $$test_out_filename $$program_out_filename > $@; \
	if [ $$? = 0 ]; \
	then echo "$(TEST_SUCCESS_MESSAGE)" > $@; \
	else exit 1; \
	fi

all: $(BUILD_DIR) $(BUILD_DIR)/$(NAME)

check: $(RESULTS_DIR) all
	$(shell \
	echo "make"; \
	for filename in $(TEST_FILENAMES); \
	do echo " $(RESULTS_DIR)/$$filename.txt";\
	done)

clean:
	rm -rf $(BUILD_DIR)/*.o
	rm -rf $(RESULTS_DIR)