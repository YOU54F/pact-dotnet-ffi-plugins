ifeq ($(DOCKER_DEFAULT_PLATFORM),)
    ifeq ($(shell uname -m),aarch64)
        DOCKER_DEFAULT_PLATFORM = linux/arm64
		DOTNET_ARCH = arm64
	else ifeq ($(shell uname -m),arm64)
        DOCKER_DEFAULT_PLATFORM = linux/arm64
		DOTNET_ARCH = arm64
    else
        DOCKER_DEFAULT_PLATFORM = linux/amd64
		DOTNET_ARCH = x64
    endif
endif

test_ci:
	act --container-architecture linux/amd64 --job ruby

# usage: make test JOB=lua
test: 
	act --container-architecture linux/amd64 --job $(JOB)

get_pact_ffi:
	./script/download-libs.sh

get_pact_plugins: get_plugin_cli install_matt_plugin install_avro_plugin

get_plugin_cli:
	./script/download-plugin-cli.sh

install_protobuf_plugin:
	${HOME}/.pact/cli/plugin/pact-plugin-cli -y install https://github.com/pactflow/pact-protobuf-plugin/releases/latest
install_matt_plugin:
	${HOME}/.pact/cli/plugin/pact-plugin-cli$(EXE) -y install https://github.com/mefellows/pact-matt-plugin/releases/latest
install_avro_plugin:
	${HOME}/.pact/cli/plugin/pact-plugin-cli$(EXE) -y install https://github.com/austek/pact-avro-plugin/releases/latest

# Grpc.Tools do not provide precompiled binaries for alpine/musl - https://github.com/grpc/grpc/issues/24188#issuecomment-1403435551
alpine_dotnet:
	docker run --platform=${DOCKER_DEFAULT_PLATFORM} -v ${PWD}:/app --rm alpine sh -c 'apk add dotnet8-sdk grpc-plugins bash make curl git file openjdk17-jre && export PROTOBUF_PROTOC=/usr/bin/protoc && export GRPC_PROTOC_PLUGIN=/usr/bin/grpc_csharp_plugin && echo $$PATH && cd /app && make get_pact_plugins && make dotnet'

debian_dotnet:
	docker run --platform=${DOCKER_DEFAULT_PLATFORM} -v ${PWD}:/app --rm debian:12 bash -c 'apt-get update && apt-get install -y curl protobuf-compiler make libicu-dev openjdk-17-jre && mkdir -p /root/.dotnet && curl -LO https://download.visualstudio.microsoft.com/download/pr/4bfdbe1a-e1f9-4535-8da6-6e1e7ea0994c/b110641d008b36dded561ff2bdb0f793/dotnet-sdk-8.0.303-linux-$(DOTNET_ARCH).tar.gz && tar -xf dotnet-sdk-8.0.303-linux-$(DOTNET_ARCH).tar.gz -C /root/.dotnet && export DOTNET_ROOT=/root/.dotnet && export PATH=$$PATH:/root/.dotnet && cd /app && make get_pact_plugins && make dotnet'

dotnet_grpc_client_test:
	$(LOAD_PATH) dotnet test Grpc/GrpcGreeterClient.Tests 
dotnet_grpc_provider_test:
	$(LOAD_PATH) dotnet test Grpc/GrpcGreeter.Tests 
dotnet_grpc_client_run:
	dotnet run --project Grpc/GrpcGreeterClient 
dotnet_grpc_provider_run:
	dotnet run --project Grpc/GrpcGreeter 
dotnet_grpc: 
	make dotnet_grpc_client_test 
	make dotnet_grpc_provider_test

dotnet_tcp_client_run:
	dotnet run --project Tcp/TcpClient
dotnet_tcp_provider_run:
	dotnet run --project Tcp/TcpListener
dotnet_tcp_client_test:
	$(LOAD_PATH) dotnet test Tcp/TcpClient.Tests
dotnet_tcp_provider_test:
	$(LOAD_PATH) dotnet test Tcp/TcpListener.Tests
dotnet_tcp: 
	make dotnet_tcp_client_test 
	make dotnet_tcp_provider_test

dotnet_avro_client_run:
	dotnet run --project Avro/AvroClient
dotnet_avro_provider_run:
	dotnet run --project Avro/AvroProvider
dotnet_avro_client_test:
	$(LOAD_PATH) dotnet test Avro/AvroClient.Tests
dotnet_avro_provider_test:
	$(LOAD_PATH) dotnet test Avro/AvroProvider.Tests
dotnet_avro: 
	make dotnet_avro_client_test 
	make dotnet_avro_provider_test

dotnet_protobuf_client_run:
	dotnet run --project Protobuf/RouteGuideClient
dotnet_protobuf_provider_run:
	dotnet run --project Protobuf/RouteGuideServer
dotnet_protobuf_client_test:
	$(LOAD_PATH) dotnet test Protobuf/RouteGuideClient.Tests
dotnet_protobuf_provider_test:
	$(LOAD_PATH) dotnet test Protobuf/RouteGuideServer.Tests
dotnet_protobuf: 
	make dotnet_protobuf_client_test 
	make dotnet_protobuf_provider_test

dotnet_plugin_client_test:
	$(LOAD_PATH) dotnet test Plugin/FooPluginConsumer.Tests
dotnet_plugin_install_local:
	cd PactDotnetPlugin && make install_local
dotnet_plugin: 
	make dotnet_plugin_install_local 
	make dotnet_plugin_client_test 

dotnet: dotnet_grpc dotnet_tcp dotnet_avro dotnet_protobuf dotnet_plugin

ABS_PATH_FFI_LIB=$(PWD)/$(pactffi_filename)
JEXTRACT_PATH=./jextract-19/bin/jextract
ifeq ($(OS),Windows_NT)
	# This will allow powershell to use PWD
	# it will reverse slashes to backslashes
	# only seems to be relevant to java panama linking
	ifndef ${PWD}
	override PWD := $(subst /,\,$(CURDIR))
	ABS_PATH_FFI_LIB=$(subst /,\,$(PWD)/$(pactffi_filename))
	JEXTRACT_PATH=$(subst /,\,$(JEXTRACT_PATH))
	endif
	
    pactffi_filename = pact_ffi.dll
	pactffi_libname = pact_ffi.dll
	DLL=.dll
	EXE=.exe
	BAT=.bat
	# LOAD_PATH=$$env:LD_LIBRARY_PATH=$$env:PWD.Path;
	STD_LIB_DIR=TODO
	VBC_COMPILER="C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\MSBuild\Current\Bin\Roslyn\vbc.exe"
	MCS_COMPILER="C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\MSBuild\Current\Bin\Roslyn\csc.exe"
	# VBC_COMPILER=vbc.exe
	GO_CMD=go1.20rc1
else
    UNAME_S := $(shell uname -s)
    ifeq ($(UNAME_S),Linux)
        pactffi_filename = libpact_ffi.so
        pactffi_libname = pact_ffi
		LOAD_PATH=LD_LIBRARY_PATH=$$PWD
		STD_LIB_DIR=/usr/include
		VBC_COMPILER?=vbnc
		MCS_COMPILER=mcs
		MONO=mono
    endif
    ifeq ($(UNAME_S),Darwin)
        pactffi_filename = libpact_ffi.dylib
        pactffi_libname = pact_ffi
		LOAD_PATH=DYLD_LIBRARY_PATH=$$PWD
		STD_LIB_DIR=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/usr/include
		VBC_COMPILER=vbc
		MCS_COMPILER=mcs
		MONO=mono
    endif
endif
