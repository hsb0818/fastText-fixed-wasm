#
# Copyright (c) 2016-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

CXX = c++
CXXFLAGS = -pthread -std=c++17 -march=native
OBJS = args.o autotune.o matrix.o dictionary.o loss.o productquantizer.o densematrix.o quantmatrix.o vector.o model.o utils.o meter.o fasttext.o
INCLUDES = -I.

opt: CXXFLAGS += -O3 -funroll-loops -DNDEBUG
opt: fasttext

coverage: CXXFLAGS += -O0 -fno-inline -fprofile-arcs --coverage
coverage: fasttext

debug: CXXFLAGS += -g -O0 -fno-inline
debug: fasttext

wasm: webassembly/fasttext_wasm.js

wasmdebug: export EMCC_DEBUG=1
wasmdebug: webassembly/fasttext_wasm.js


args.o: src/args.cc src/args.h
	$(CXX) $(CXXFLAGS) -c src/args.cc

autotune.o: src/autotune.cc src/autotune.h
	$(CXX) $(CXXFLAGS) -c src/autotune.cc

matrix.o: src/matrix.cc src/matrix.h
	$(CXX) $(CXXFLAGS) -c src/matrix.cc

dictionary.o: src/dictionary.cc src/dictionary.h src/args.h
	$(CXX) $(CXXFLAGS) -c src/dictionary.cc

loss.o: src/loss.cc src/loss.h src/matrix.h src/real.h
	$(CXX) $(CXXFLAGS) -c src/loss.cc

productquantizer.o: src/productquantizer.cc src/productquantizer.h src/utils.h
	$(CXX) $(CXXFLAGS) -c src/productquantizer.cc

densematrix.o: src/densematrix.cc src/densematrix.h src/utils.h src/matrix.h
	$(CXX) $(CXXFLAGS) -c src/densematrix.cc

quantmatrix.o: src/quantmatrix.cc src/quantmatrix.h src/utils.h src/matrix.h
	$(CXX) $(CXXFLAGS) -c src/quantmatrix.cc

vector.o: src/vector.cc src/vector.h src/utils.h
	$(CXX) $(CXXFLAGS) -c src/vector.cc

model.o: src/model.cc src/model.h src/args.h
	$(CXX) $(CXXFLAGS) -c src/model.cc

utils.o: src/utils.cc src/utils.h
	$(CXX) $(CXXFLAGS) -c src/utils.cc

meter.o: src/meter.cc src/meter.h
	$(CXX) $(CXXFLAGS) -c src/meter.cc

fasttext.o: src/fasttext.cc src/*.h
	$(CXX) $(CXXFLAGS) -c src/fasttext.cc

fasttext: $(OBJS) src/fasttext.cc src/main.cc
	$(CXX) $(CXXFLAGS) $(OBJS) src/main.cc -o fasttext

clean:
	rm -rf *.o *.gcno *.gcda fasttext *.bc webassembly/fasttext_wasm.js webassembly/fasttext_wasm.wasm


EMCXX = em++
EMCXXFLAGS = --bind --std=c++11 -s WASM=1 -s ALLOW_MEMORY_GROWTH=1 -s "EXPORTED_RUNTIME_METHODS=['addOnPostRun', 'FS']" -s "DISABLE_EXCEPTION_CATCHING=0" -s "EXCEPTION_DEBUG=1" -s "FORCE_FILESYSTEM=1" -s "MODULARIZE=1" -s "EXPORT_ES6=1" -s 'EXPORT_NAME="FastTextModule"' -Isrc/

webassembly/fasttext_wasm.js: src/*.cc webassembly/fasttext_wasm.cc Makefile
	$(EMCXX) $(EMCXXFLAGS) src/args.cc src/autotune.cc src/matrix.cc src/dictionary.cc src/loss.cc src/productquantizer.cc src/densematrix.cc src/quantmatrix.cc src/vector.cc src/model.cc src/utils.cc src/meter.cc src/fasttext.cc webassembly/fasttext_wasm.cc -o webassembly/fasttext_wasm.js


