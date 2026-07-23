# .NET Pact Plugin Scenarios

This repository contains a collection of pact plugin scenarios for the .NET Interop with the Pact FFI shared library.

## Layout

```sh
.
├── Avro
│   ├── AvroClient
│   ├── AvroClient.Tests
│   ├── AvroProvider
│   └── AvroProvider.Tests
├── Grpc
│   ├── GrpcGreeter
│   ├── GrpcGreeter.Tests
│   ├── GrpcGreeterClient
│   └── GrpcGreeterClient.Tests
├── Pact
│   ├── Pact.cs
│   └── Pact.csproj
├── Plugin
│   └── FooPluginConsumer.Tests
├── Protobuf
│   ├── Protos
│   ├── RouteGuide
│   ├── RouteGuideClient
│   ├── RouteGuideClient.Tests
│   ├── RouteGuideServer
│   └── RouteGuideServer.Tests
├── README.md
└── Tcp
    ├── TcpClient
    ├── TcpClient.Tests
    ├── TcpListener
    └── TcpListener.Tests
```

## Local PactNet Package Source

This repo includes a root `NuGet.config` with a local package source at `./.nuget/local`.
That allows the team to restore a locally downloaded `PactNet` pre-release package without
publishing it to NuGet.org or another remote feed.

Download the package into the local source folder:

```sh
mkdir -p ./.nuget/local
curl -L -o ./.nuget/local/PactNet.5.1.0-beta.1.nupkg \
  https://github.com/YOU54F/pact-net/releases/download/5.1.0-beta.1/PactNet.5.1.0-beta.1.nupkg
curl -L -o ./.nuget/local/PactNet.Abstractions.5.1.0-beta.1.nupkg \
  https://github.com/YOU54F/pact-net/releases/download/5.1.0-beta.1/PactNet.Abstractions.5.1.0-beta.1.nupkg
curl -L -o ./.nuget/local/PactNet.Extensions.Grpc.5.1.0-beta.1.nupkg \
  https://github.com/YOU54F/pact-net/releases/download/5.1.0-beta.1/PactNet.Extensions.Grpc.5.1.0-beta.1.nupkg
curl -L -o ./.nuget/local/PactNet.Output.Xunit.1.0.0.nupkg \
  https://github.com/YOU54F/pact-net/releases/download/5.1.0-beta.1/PactNet.Output.Xunit.1.0.0.nupkg
```

Then restore as normal from the repo root:

```sh
dotnet restore
```

If you want to add/update package references using this local source explicitly:

```sh
dotnet add <project.csproj> package PactNet --version 5.1.0-beta.1 --source ./.nuget/local
```

eg.

```
dotnet add GrpcGreeter.Tests.csproj package PactNet --version 5.1.0-beta.1 --source ../../.nuget/local
dotnet add GrpcGreeter.Tests.csproj package PactNet.Abstractions --version 5.1.0-beta.1 --source ../../.nuget/local
dotnet add GrpcGreeter.Tests.csproj package PactNet.Extensions.Grpc --version 5.1.0-beta.1 --source ../../.nuget/local
dotnet add GrpcGreeter.Tests.csproj package PactNet.Output.Xunit --version 1.0.0 --source ../../.nuget/local
dotnet add GrpcGreeterClient.Tests.csproj package PactNet.Output.Xunit --version 1.0.0 --source ../../.nuget/local
dotnet add GrpcGreeterClient.Tests.csproj package PactNet --version 5.1.0-beta.1 --source ../../.nuget/local
dotnet add GrpcGreeterClient.Tests.csproj package PactNet.Abstractions --version 5.1.0-beta.1 --source ../../.nuget/local
dotnet add GrpcGreeterClient.Tests.csproj package PactNet.Extensions.Grpc --version 5.1.0-beta.1 --source ../../.nuget/local
```

## Scenarios

### Avro

Simple Avro example utilising Apache.Avro library to send HTTP messages in Avro format.

- Type: Synchronous/HTTP
- Transport: HTTP
- Message Format: Avro
- Plugin: pact-avro-plugin
- Pact File: [`./Avro/pacts/AvroConsumer-AvroProvider.json`](./Avro/pacts/AvroConsumer-AvroProvider.json)
- Other Reference Impls
  - [Pact-Go Avro Example](https://github.com/pact-foundation/pact-go/tree/master/examples/avro)

### Grpc

Simple gRPC greeter client.

Adapted for Pact, from [Microsoft's gRPC sample - Tutorial: Create a gRPC client and server in ASP.NET Core](https://learn.microsoft.com/en-us/aspnet/core/tutorials/grpc/grpc-start?view=aspnetcore-8.0&tabs=visual-studio-mac)

- Type: Synchronous/Messages
- Transport: gRPC
- Message Format: Protobuf
- Plugin: pact-protobuf-plugin
- Pact File: [`./Grpc/pacts/grpc-greeter-client-dotnet-grpc-greeter.json`](./Grpc/pacts/grpc-greeter-client-dotnet-grpc-greeter.json)
- Other Reference Impls
  - [Pact-Go RouteGuide gRPC Example](https://github.com/pact-foundation/pact-go/tree/master/examples/grpc)
  - [Pact-Js AreaCalculator Example](https://github.com/pact-foundation/pact-plugins/blob/main/examples/gRPC/area_calculator/js/test/grpc.consumer.spec.ts)
  
### Plugin

Simple example of usage of custom plugin for Pact, which concentrates on message format only.

Part of Pact [create a plugin course](https://docs.pact.io/plugins/workshops/create-a-plugin/intro).

Demonstrates usage of a basic plugin created in .NET

- Type: Synchronous/HTTP
- Transport: HTTP
- Message Format: foo
- Plugin: pact-dotnet-plugin
  - [./PactDotnetPlugin](./PactDotnetPlugin)
- Pact File: [`./Plugin/pacts/DotnetPluginConsumer-DotnetPluginProvider.json`](./Plugin/pacts/DotnetPluginConsumer-DotnetPluginProvider.json)

### Protobuf

gRPC RouteGuide example, adapted from old [.NET gRPC example](https://github.com/grpc/grpc/tree/v1.46.x/examples/csharp/RouteGuide).

Utilises a .NET message proxy to map Pact messages to message handlers.

- Type: Asynchronous/Messages
- Transport: gRPC
- Message Format: Protobuf
- Plugin: pact-protobuf-plugin
- Pact file: [`./Protobuf/pacts/protobufmessageconsumer-protobufmessageprovider.json`](./Protobuf/pacts/protobufmessageconsumer-protobufmessageprovider.json)
- Other Reference Impls
  - [Pact-Go RouteGuide Protobuf Example](https://github.com/pact-foundation/pact-go/tree/master/examples/protobuf)
  - [Pact-Js RouteGuide Example](https://github.com/pact-foundation/pact-js-core/blob/f2b3918c5c92138e0ad4660058a4e1eb679ae494/test/message.integration.spec.ts#L137)


### Tcp

Follows the pact-matt-plugin, as exercised in

- Type: Synchronous/HTTP
- Transport: HTTP
- Message Format: matt
- Plugin: pact-matt-plugin
- Pact file: [`./Tcp/pacts/MattConsumer-MattProvider.json`](./Tcp/pacts/MattConsumer-MattProvider.json)
- Other Reference Impls
  - [Pact-Go Http Example](https://github.com/pact-foundation/pact-go/tree/master/examples/plugin)
  - [Pact-Js-Core Consumer Example](https://github.com/pact-foundation/pact-js-core/blob/master/test/matt.consumer.integration.spec.ts)
  - [Pact-Js-Core Provider Example](https://github.com/pact-foundation/pact-js-core/blob/master/test/matt.provider.integration.spec.ts)

- Type: Synchronous/Messages
- Transport: TCP
- Message Format: matt
- Plugin: pact-matt-plugin
- Pact file: [`./Tcp/pacts/matttcpconsumer-matttcpprovider.json`](./Tcp/pacts/matttcpconsumer-matttcpprovider.json)
- Other Reference Impls
  - [Pact-Go Tcp Example](https://github.com/pact-foundation/pact-go/tree/master/examples/plugin)
