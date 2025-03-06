CC = clang
CFLAGS = -Wall -Wextra -g -std=c99
LDFLAGS = -lm

SRC_DIR = .
DS_DIR = data_structures
ALGO_DIR = algorithms
BIN_DIR = bin
OBJ_DIR = obj
INCLUDE_DIR = include

$(shell mkdir -p $(BIN_DIR) $(OBJ_DIR) $(OBJ_DIR)/$(DS_DIR) $(OBJ_DIR)/$(ALGO_DIR))

DS_SOURCES = $(shell find $(DS_DIR) -name "*.c" ! -name "test_*.c" 2>/dev/null)
ALGO_SOURCES = $(shell find $(ALGO_DIR) -name "*.c" ! -name "test_*.c" 2>/dev/null)
ALL_SOURCES = $(DS_SOURCES) $(ALGO_SOURCES)

DS_OBJECTS = $(patsubst %.c,$(OBJ_DIR)/%.o,$(DS_SOURCES))
ALGO_OBJECTS = $(patsubst %.c,$(OBJ_DIR)/%.o,$(ALGO_SOURCES))
ALL_OBJECTS = $(DS_OBJECTS) $(ALGO_OBJECTS)

TEST_SOURCES = $(shell find . -name "test_*.c" 2>/dev/null)
TEST_BINS = $(patsubst %.c,$(BIN_DIR)/%,$(TEST_SOURCES))

all: data_structures algorithms tests

data_structures: $(DS_OBJECTS)
	@echo "Built data structures: $(DS_OBJECTS)"

algorithms: $(ALGO_OBJECTS)
	@echo "Built algorithms: $(ALGO_OBJECTS)"

tests: $(TEST_BINS)
	@echo "Built tests: $(TEST_BINS)"

$(OBJ_DIR)/%.o: %.c
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -I$(INCLUDE_DIR) -I$(SRC_DIR) -c $< -o $@

$(BIN_DIR)/%: %.c $(ALL_OBJECTS)
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -I$(INCLUDE_DIR) -I$(SRC_DIR) $< $(ALL_OBJECTS) $(LDFLAGS) -o $@

run_tests: tests
	@for test in $(TEST_BINS); do \
		echo "Running $$test..."; \
		$$test; \
		echo ""; \
	done

run:
ifdef DS
	@for test in $(shell find . -name "test_*$(DS)*.c" 2>/dev/null); do \
		test_bin=$(BIN_DIR)/$$(basename $$test .c); \
		mkdir -p $$(dirname $$test_bin); \
		$(CC) $(CFLAGS) -I$(INCLUDE_DIR) -I$(SRC_DIR) $$test $(ALL_OBJECTS) $(LDFLAGS) -o $$test_bin; \
		$$test_bin; \
	done
endif
ifdef ALGO
	@for test in $(shell find . -name "test_*$(ALGO)*.c" 2>/dev/null); do \
		test_bin=$(BIN_DIR)/$$(basename $$test .c); \
		mkdir -p $$(dirname $$test_bin); \
		$(CC) $(CFLAGS) -I$(INCLUDE_DIR) -I$(SRC_DIR) $$test $(ALL_OBJECTS) $(LDFLAGS) -o $$test_bin; \
		$$test_bin; \
	done
endif

clean:
	rm -rf $(OBJ_DIR)/* $(BIN_DIR)/*

distclean: clean
	rm -rf $(BIN_DIR) $(OBJ_DIR)

list:
	@echo "Data Structures:"
	@find $(DS_DIR) -name "*.c" ! -name "test_*.c" | sed 's|$(DS_DIR)/||g' | sed 's|/.*\.c||g' | sort | uniq
	@echo "Algorithms:"
	@find $(ALGO_DIR) -name "*.c" ! -name "test_*.c" | sed 's|$(ALGO_DIR)/||g' | sed 's|/.*\.c||g' | sort | uniq

help:
	@echo "Targets: all, data_structures, algorithms, tests, run_tests"
	@echo "         run DS=name, run ALGO=name, list, clean, distclean"

.PHONY: all data_structures algorithms tests run_tests run clean distclean list help
