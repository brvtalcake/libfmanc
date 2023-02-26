# Project informations
VERSION=1.0.0
MAJOR_VERSION=1
MINOR_VERSION=0
PATCH_VERSION=0
PROJECT_NAME=FManC
PROJECT_DESCRIPTION="File Management C Library"
PROJECT_AUTHOR="Axel PASCON"
PROJECT_AUTHOR_EMAIL="axlpascon@gmail.com"

# OS-dependant variables
DETECTED_OS=lin
PRINTED_OS=Linux
TEST_RES_FOLD=lin
## Another idea to detect OS could be to parse the output of gcc -print-multiarch
ifneq (,$(findstring Windows,$(OS)))
	TEST_RES_FOLD=win
	DETECTED_OS=win
	PRINTED_OS=$(OS)
	SHELL=cmd
else ifneq (,$(findstring windows,$(OS)))
	SHELL=cmd
	DETECTED_OS=win
	PRINTED_OS=$(OS)
	TEST_RES_FOLD=win
endif

# Project subdirectories
CPP_SRC_SUBDIRS=src/cpp/ src/cpp/FMC_dir/
C_SRC_SUBDIRS=src/ src/general/ src/general/preprocessor/ src/general/types/ src/general/utils/ src/files/ src/data_analyze/ src/data_analyze/encodings/ src/data_analyze/strings/ src/code_utils/
SRC_SUBDIRS=$(C_SRC_SUBDIRS) $(CPP_SRC_SUBDIRS)

VPATH=$(subst / ,/:,$(SRC_SUBDIRS))

# Project files
CPP_SRC_FILES=$(foreach dir,$(SRC_SUBDIRS),$(wildcard $(dir)/*.cpp))
HPP_SRC_FILES=$(foreach dir,$(SRC_SUBDIRS),$(wildcard $(dir)/*.hpp))
C_SRC_FILES=$(foreach dir,$(SRC_SUBDIRS),$(wildcard $(dir)/*.c))
H_SRC_FILES=$(foreach dir,$(SRC_SUBDIRS),$(wildcard $(dir)/*.h))
SRC_FILES=$(CPP_SRC_FILES) $(C_SRC_FILES) $(HPP_SRC_FILES) $(H_SRC_FILES)

TEST_SUITE_FILES=$(addprefix test/src_test/,test.c test1_2.c test2_2.c)


# Object files
O_LIN_STATIC_FILES=$(addprefix obj/lin/static/,$(notdir $(C_SRC_FILES:.c=.o))) $(addprefix obj/lin/static/,$(notdir $(CPP_SRC_FILES:.cpp=.o)))
O_LIN_SHARED_FILES=$(addprefix obj/lin/shared/,$(notdir $(C_SRC_FILES:.c=.o))) $(addprefix obj/lin/shared/,$(notdir $(CPP_SRC_FILES:.cpp=.o)))
O_WIN_STATIC_FILES=$(addprefix obj/win/static/,$(notdir $(C_SRC_FILES:.c=.o))) $(addprefix obj/win/static/,$(notdir $(CPP_SRC_FILES:.cpp=.o)))
O_WIN_SHARED_FILES=$(addprefix obj/win/shared/,$(notdir $(C_SRC_FILES:.c=.o))) $(addprefix obj/win/shared/,$(notdir $(CPP_SRC_FILES:.cpp=.o)))

O_LIN_TEST=$(addprefix test/obj/lin/,$(notdir $(C_SRC_FILES:.c=.o))) $(addprefix test/obj/lin/,$(notdir $(CPP_SRC_FILES:.cpp=.o)))
O_WIN_TEST=$(addprefix test/obj/win/,$(notdir $(C_SRC_FILES:.c=.o))) $(addprefix test/obj/win/,$(notdir $(CPP_SRC_FILES:.cpp=.o)))
GCNO_LIN_FILES=$(O_LIN_TEST:.o=.gcno)
GCDA_LIN_FILES=$(O_LIN_TEST:.o=.gcda)
GCNO_WIN_FILES=$(O_WIN_TEST:.o=.gcno)
GCDA_WIN_FILES=$(O_WIN_TEST:.o=.gcda)

COV_FILES=$(addsuffix .gcov,$(notdir $(SRC_FILES)))

# Library files
LIB_LIN_STATIC_FILES=lib/libFManC_linux_x86_64.a
LIB_LIN_SHARED_FILES=bin/libFManC_x86_64.so
LIB_WIN_STATIC_FILES=lib/libFManC_win_x86_64.a
LIB_WIN_SHARED_FILES=bin/libFManC_x86_64.dll lib/libFManC_x86_64.dll.a

LIB_LIN_TEST=test/$(LIB_LIN_STATIC_FILES)
LIB_WIN_TEST=test/$(LIB_WIN_STATIC_FILES)

# Compiler and friends
CC=gcc
CCXX=g++
AR=ar

# Compiler and archiver flags
AR_FLAGS=-rsc
CFLAGS=-O3 -Wall -Wextra -Werror -Wunsuffixed-float-constants -Wconversion -Wdouble-promotion -Wsuggest-attribute=cold -Wsuggest-attribute=const -Wsuggest-attribute=format -Wsuggest-attribute=malloc -Wsuggest-attribute=noreturn -Wsuggest-attribute=pure -Wstack-protector -Wredundant-decls -Wnull-dereference -Wfloat-equal -Wfloat-conversion -std=gnu17
CXX_FLAGS=-O3 -Wall -Wextra -Werror -Wconversion -Wdouble-promotion -Wsuggest-attribute=cold -Wsuggest-attribute=const -Wsuggest-attribute=format -Wsuggest-attribute=malloc -Wsuggest-attribute=noreturn -Wsuggest-attribute=pure -Wstack-protector -Wredundant-decls -Wnull-dereference -Wfloat-equal -Wfloat-conversion -std=gnu++17

C_DEBUG_FLAGS=-g3 -std=gnu17 -fprofile-arcs -ftest-coverage
CXX_DEBUG_FLAGS=-g3 -std=gnu++17 -fprofile-arcs -ftest-coverage

LD_FLAGS_DLL=-lstdc++ "-Wl,--out-implib=libFManC.dll.a,--export-all-symbols,--enable-auto-import"
LD_FLAGS_SO=-lstdc++ -Wl,-soname,

INC_FLAGS=-I./third_party_libs/metalang99/include/
# All target
ALL_TARGET=$(addsuffix _$(DETECTED_OS), all)
.PHONY : all

# Static library target
STAT_TARGET=$(addsuffix _$(DETECTED_OS), static)
.PHONY : static

# Shared library target
SHARED_TARGET=$(addsuffix _$(DETECTED_OS), shared)
.PHONY : shared

# Tests target
TEST_TARGET=$(addsuffix _$(DETECTED_OS), test)
.PHONY : test

# Clean target
CLEAN_TARGET=$(addsuffix _$(DETECTED_OS), clean)
.PHONY : clean

# Copy headers target
COPY_HEADERS_TARGET=$(addsuffix _$(DETECTED_OS), copy_headers)
.PHONY : copy_headers

# Documentation target
DOC_TARGET=$(addsuffix _$(DETECTED_OS), doc)
.PHONY : doc

COV_TARGET=$(addsuffix _$(DETECTED_OS), exp_cov)
.PHONY : exp_cov

exp_cov : $(COV_TARGET)

exp_cov_lin :
	./export_cov.sh $(COV_FILES)
	rm -f --verbose *.gcov

exp_cov_win :
	@export_cov $(COV_FILES)
	rm -f --verbose *.gcov

all : $(ALL_TARGET)

all_lin : static shared copy_headers doc test 
	@printf "\e[92mBuilt everything for $(PRINTED_OS)\n\e[0m"

all_win : static shared copy_headers doc test
	@printgreen Built everything for $(PRINTED_OS)

static : $(STAT_TARGET)

static_lin : $(LIB_LIN_STATIC_FILES) copy_headers 
	@printf "\e[92mBuilt static library for $(PRINTED_OS)\n\e[0m"

static_win : $(LIB_WIN_STATIC_FILES) copy_headers 
	@printgreen Built static library for $(PRINTED_OS)

shared : $(SHARED_TARGET)

shared_lin : $(LIB_LIN_SHARED_FILES) copy_headers
	@printf "\e[92mBuilt shared library for $(PRINTED_OS)\n\e[0m"

shared_win : $(LIB_WIN_SHARED_FILES) copy_headers
	@printgreen Built shared library for $(PRINTED_OS)

test : copy_headers $(TEST_TARGET) exp_cov

test_lin : $(LIB_LIN_TEST)
	$(CC) $(TEST_SUITE_FILES) -fprofile-arcs -ftest-coverage -std=gnu17 -o test/test_builds/$(TEST_RES_FOLD)/$@.out $(INC_FLAGS) -Ltest/lib/ -lFManC_linux_x86_64 -lstdc++
	@printf "\e[92mRunning tests for $(PRINTED_OS)\n\e[0m"
	@cd ./test/test_builds/$(TEST_RES_FOLD) && ./$@.out
	gcov $(GCNO_LIN_FILES)

test_win : $(LIB_WIN_TEST)
	$(CC) -D FMC_STATIC $(TEST_SUITE_FILES) -fprofile-arcs -ftest-coverage -std=gnu17 -o test/test_builds/$(TEST_RES_FOLD)/$@.exe $(INC_FLAGS) -Ltest/lib -lFManC_linux_x86_64 -lstdc++
	@printgreen Running tests for $(PRINTED_OS)
	@cd .\test\test_builds\$(TEST_RES_FOLD) && $@.exe
	gcov $(GCNO_LIN_FILES)

$(LIB_LIN_TEST) : $(O_LIN_TEST)
	$(AR) $(AR_FLAGS) $@ $^

test/obj/lin/%.o : %.c $(H_SRC_FILES) $(HPP_SRC_FILES)
	$(CC) -D BUILDING_FMANC $< $(C_DEBUG_FLAGS) -c -o $@ $(INC_FLAGS) -lstdc++

test/obj/lin/%.o : %.cpp $(H_SRC_FILES) $(HPP_SRC_FILES)
	$(CCXX) -D BUILDING_FMANC $< $(CXX_DEBUG_FLAGS) -c -o $@ $(INC_FLAGS) -lstdc++

$(LIB_WIN_TEST) : $(O_WIN_TEST)
	$(AR) $(AR_FLAGS) $@ $^

test/obj/win/%.o : %.c $(H_SRC_FILES) $(HPP_SRC_FILES)
	$(CC) -D FMC_STATIC -D BUILDING_FMANC $< $(C_DEBUG_FLAGS) -c -o $@ $(INC_FLAGS) -lstdc++

test/obj/win/%.o : %.cpp $(H_SRC_FILES) $(HPP_SRC_FILES)
	$(CCXX) -D FMC_STATIC -D BUILDING_FMANC $< $(CXX_DEBUG_FLAGS) -c -o $@ $(INC_FLAGS) -lstdc++

clean : $(CLEAN_TARGET)

clean_lin : 
	@rm -f --verbose $(O_LIN_STATIC_FILES) $(O_LIN_SHARED_FILES) $(LIB_LIN_STATIC_FILES) $(LIB_LIN_SHARED_FILES) $(O_LIN_TEST) $(LIB_LIN_TEST) test/obj/lin/*.gcda test/obj/lin/*.gcno *.gcov
	@printf "\e[92mCleaned everything for $(PRINTED_OS)\n\e[0m"

clean_win : 
	@rm -f --verbose $(subst /,\,$(O_WIN_STATIC_FILES) $(O_WIN_SHARED_FILES) $(LIB_WIN_STATIC_FILES) $(LIB_WIN_SHARED_FILES) $(O_WIN_TEST) $(LIB_WIN_TEST)) test/obj/win/*.gcda test/obj/win/*.gcno *.gcov
	@printgreen Cleaned everything for $(PRINTED_OS)
## TO DO : check if rm exists on windows

copy_headers : $(COPY_HEADERS_TARGET)

copy_headers_lin : $(subst src/,include/,$(H_SRC_FILES) $(HPP_SRC_FILES))
	@printf "\e[92mCopied headers for $(PRINTED_OS)\n\e[0m"

copy_headers_win : $(subst src/,include/,$(H_SRC_FILES) $(HPP_SRC_FILES))
	@printgreen Copied headers for $(PRINTED_OS)

doc : $(DOC_TARGET)

doc_lin : $(SRC_FILES)
	doxygen doxylin
	@cd man && make

doc_win : $(SRC_FILES)
	doxygen doxywin
	@cd man && make

include/%.h : src/%.h
	@cp -f -u -T $^ $@ 

include/%.hpp : src/%.hpp
	@cp -f -u -T $^ $@ 

lib/libFManC_linux_x86_64.a : $(O_LIN_STATIC_FILES)
	$(AR) $(AR_FLAGS) $@ $^
	@printf "\e[92mBuilt $@ sucessfully\n\n\e[0m"

lib/libFManC_win_x86_64.a : $(O_WIN_STATIC_FILES)
	$(AR) $(AR_FLAGS) $@ $^
	@printgreen Built $@ sucessfully

obj/lin/static/%.o : %.c $(H_SRC_FILES) $(HPP_SRC_FILES)
	$(CC) -D BUILDING_FMANC $< $(CFLAGS) -c -o $@ $(INC_FLAGS) -lstdc++
	@printf "\e[92mBuilt $@ sucessfully\n\n\e[0m"

obj/lin/static/%.o : %.cpp $(H_SRC_FILES) $(HPP_SRC_FILES)
	$(CCXX) -D BUILDING_FMANC $< $(CXX_FLAGS) -c -o $@ $(INC_FLAGS) -lstdc++
	@printf "\e[92mBuilt $@ sucessfully\n\n\e[0m"

obj/win/static/%.o : %.c $(H_SRC_FILES) $(HPP_SRC_FILES)
	$(CC) -D BUILDING_FMANC -D FMC_STATIC $< $(CFLAGS) -c -o $@ $(INC_FLAGS) -lstdc++
	@printgreen Built $@ sucessfully

obj/win/static/%.o : %.cpp $(H_SRC_FILES) $(HPP_SRC_FILES)
	$(CCXX) -D BUILDING_FMANC -D FMC_STATIC $< $(CXX_FLAGS) -c -o $@ $(INC_FLAGS) -lstdc++
	@printgreen Built $@ sucessfully

bin/libFManC_x86_64.so : $(O_LIN_SHARED_FILES)
	rm -f $@ && rm -f $@.$(MAJOR_VERSION) && rm -f $@.$(VERSION)
	$(CC) -D BUILDING_FMANC $(O_LIN_SHARED_FILES) $(CFLAGS) -shared -fPIC -o $@.$(VERSION) $(INC_FLAGS) -lstdc++ $(LD_FLAGS_SO)libFManC_x86_64.so.$(MAJOR_VERSION)
	cd ./bin/ && ln -s $(notdir $@).$(VERSION) $(notdir $@).$(MAJOR_VERSION) && ln -s $(notdir $@).$(MAJOR_VERSION) $(notdir $@)
	@printf "\e[92mBuilt $@ sucessfully\n\n\e[0m"

bin/libFManC_x86_64.dll : lib/libFManC_x86_64.dll.a
	@printgreen Built DLL for $(PRINTED_OS)

lib/libFManC_x86_64.dll.a : $(O_WIN_SHARED_FILES)
	$(CC) -D BUILDING_FMANC $(O_WIN_SHARED_FILES) $(CFLAGS) -shared -o bin/libFManC_x86_64.dll $(INC_FLAGS) -lstdc++ $(LD_FLAGS_DLL)
	@move /Y .\\libFManC.dll.a .\\lib\\
	@printgreen Built $@ sucessfully

obj/lin/shared/%.o : %.c $(H_SRC_FILES) $(HPP_SRC_FILES)
	$(CC) -D BUILDING_FMANC $< $(CFLAGS) -c -fPIC -o $@ $(INC_FLAGS) -lstdc++
	@printf "\e[92mBuilt $@ sucessfully\n\n\e[0m"

obj/lin/shared/%.o : %.cpp $(H_SRC_FILES) $(HPP_SRC_FILES)
	$(CCXX) -D BUILDING_FMANC $< $(CXX_FLAGS) -c -fPIC -o $@ $(INC_FLAGS) -lstdc++
	@printf "\e[92mBuilt $@ sucessfully\n\n\e[0m"

obj/win/shared/%.o : %.c $(H_SRC_FILES) $(HPP_SRC_FILES)
	$(CC) -D BUILDING_FMANC -D FMC_BUILD_DLL $< $(CFLAGS) -c -o $@ $(INC_FLAGS) -lstdc++
	@printgreen Built $@ sucessfully

obj/win/shared/%.o : %.cpp $(H_SRC_FILES) $(HPP_SRC_FILES)
	$(CCXX) -D BUILDING_FMANC -D FMC_BUILD_DLL $< $(CXX_FLAGS) -c -o $@ $(INC_FLAGS) -lstdc++
	@printgreen Built $@ sucessfully