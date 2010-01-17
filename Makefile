# Copyright (c) 2010 , 杨博 (Yang Bo) All rights reserved.
#
#         pop.atry@gmail.com
#
# Use, modification and distribution are subject to the "New BSD License"
# as listed at <url: http://www.opensource.org/licenses/bsd-license.php >.
include config.mk

all: classes/com/netease/protocGenAs3/Main.class dist/protobuf.swc 

classes/com/netease/protocGenAs3/Main.class: \
	plugin.proto.java/google/protobuf/compiler/Plugin.java \
	compiler/com/netease/protocGenAs3/Main.java \
	$(PROTOBUF_DIR)/java/target/protobuf-java-2.3.0.jar \
	| classes
	javac -encoding UTF-8 -Xlint:all -d classes \
	-classpath "$(PROTOBUF_DIR)/java/target/protobuf-java-2.3.0.jar" \
	-sourcepath "plugin.proto.java$(PATH_SEPARATOR)compiler" \
	compiler/com/netease/protocGenAs3/Main.java

plugin.proto.java/google/protobuf/compiler/Plugin.java: \
	$(PROTOBUF_DIR)/src/$(PROTOC) | plugin.proto.java
	"$(PROTOBUF_DIR)/src/$(PROTOC)" \
	"--proto_path=$(PROTOBUF_DIR)/src" --java_out=plugin.proto.java \
	"$(PROTOBUF_DIR)/src/google/protobuf/compiler/plugin.proto"

dist.tar.gz: dist/protoc-gen-as3 dist/protoc-gen-as3.bat \
	dist/protobuf.swc dist/README\
	dist/protoc-gen-as3.jar dist/protobuf-java-2.3.0.jar
	tar -zcf dist.tar.gz dist

dist/README: README | dist
	cp README dist/README

dist/protoc-gen-as3: | dist
	echo -n -e '#!/bin/sh\ncd `dirname "$$0"`\njava -cp protobuf-java-2.3.0.jar -jar protoc-gen-as3.jar' > $@
	chmod +x $@

dist/protoc-gen-as3.bat: | dist
	echo -n -e '@echo off\r\ncd %~dp0\r\njava -cp protobuf-java-2.3.0.jar -jar protoc-gen-as3.jar' > $@
	chmod +x $@

dist/protobuf.swc: as3 | dist
	$(COMPC) -include-sources+=as3 -output=$@

dist/protoc-gen-as3.jar: classes/com/netease/protocGenAs3/Main.class | dist
	jar ecf com/netease/protocGenAs3/Main $@ classes

dist/protobuf-java-2.3.0.jar: \
	$(PROTOBUF_DIR)/java/target/protobuf-java-2.3.0.jar \
	| dist
	cp $< $@

descriptor.proto.as3 classes plugin.proto.java unittest.proto.as3 dist:
	mkdir $@

$(PROTOBUF_DIR)/src/$(PROTOC): $(PROTOBUF_DIR)/Makefile
	cd $(PROTOBUF_DIR) && make

$(PROTOBUF_DIR)/Makefile: $(PROTOBUF_DIR)/configure
	cd $(PROTOBUF_DIR) && ./configure

$(PROTOBUF_DIR)/configure:
	cd $(PROTOBUF_DIR) && ./autogen.sh

$(PROTOBUF_DIR)/java/target/protobuf-java-2.3.0.jar: $(PROTOBUF_DIR)/src
	cd $(PROTOBUF_DIR)/java && mvn package

plugin: classes/com/netease/protocGenAs3/Main.class
	java -ea \
	-classpath "$(PROTOBUF_DIR)/java/target/protobuf-java-2.3.0.jar$(PATH_SEPARATOR)classes" \
	com.netease.protocGenAs3.Main

clean:
	rm -fr dist
	rm -fr dist.tar.gz
	rm -fr classes
	rm -fr unittest.proto.as3
	rm -fr descriptor.proto.as3
	rm -fr plugin.proto.java
	rm -fr test.swc
	rm -fr test.swf

test: test.swf
	echo -e 'c\r\nq' | $(FDB) $<

test.swf: test.swc test/Test.as dist/protobuf.swc
	$(MXMLC) -library-path+=test.swc,dist/protobuf.swc -output=$@ \
	-source-path+=test test/Test.as -debug

test.swc: unittest.proto.as3/protobuf_unittest dist/protobuf.swc
	$(COMPC) -include-sources+=unittest.proto.as3 \
	-external-library-path+=dist/protobuf.swc -output=$@

descriptor.proto.as3/google: \
	$(PROTOBUF_DIR)/src/$(PROTOC) \
	classes/com/netease/protocGenAs3/Main.class \
	| descriptor.proto.as3
	"$(PROTOBUF_DIR)/src/$(PROTOC)" \
	--plugin=protoc-gen-as3=bin/protoc-gen-as3 \
	"--proto_path=$(PROTOBUF_DIR)/src" \
	--as3_out=descriptor.proto.as3 \
	"$(PROTOBUF_DIR)/src/google/protobuf/descriptor.proto"
	touch $@

unittest.proto.as3/protobuf_unittest: \
	$(PROTOBUF_DIR)/src/$(PROTOC) \
	classes/com/netease/protocGenAs3/Main.class \
	| unittest.proto.as3
	"$(PROTOBUF_DIR)/src/$(PROTOC)" \
	--plugin=protoc-gen-as3=bin/protoc-gen-as3 \
	"--proto_path=$(PROTOBUF_DIR)/src" \
	--as3_out=unittest.proto.as3 \
	$(PROTOBUF_DIR)/src/google/protobuf/unittest.proto \
	$(PROTOBUF_DIR)/src/google/protobuf/unittest_import.proto
	touch $@

.PHONY: plugin all clean test
