using System.Threading.Tasks;
using System.Threading;
using FluentAssertions;
using Xunit;
using PactFfi;

namespace GrpcGreeter.Tests
{
    public class GrpcGreeterTests
    {

        [Fact]
        public void ReturnsVerificationFailureWhenNoRunningProvider()
        {

            _ = Pact.LogToStdOut(3);

            var verifier = Pact.VerifierNewForApplication("pact-dotnet","0.0.0");
            Pact.VerifierSetProviderInfo(verifier,"grpc-greeter",null,null,0,null);
            Pact.AddProviderTransport(verifier, "grpc",5060,"/","http");
            Pact.VerifierAddFileSource(verifier,"../../../../pacts/grpc-greeter-client-grpc-greeter.json");
            var VerifierExecuteResult = Pact.VerifierExecute(verifier);
            VerifierExecuteResult.Should().Be(1);
        }
        [Fact]
        public async Task ReturnsVerificationSuccessRunningProviderAsync()
        {
            _ = Pact.LogToStdOut(3);

            var verifier = Pact.VerifierNewForApplication("pact-dotnet", "0.0.0");
            Pact.VerifierSetProviderInfo(verifier, "grpc-greeter", null, null, 0, null);
            Pact.AddProviderTransport(verifier, "grpc", 5000, "/", "https");
            Pact.VerifierAddFileSource(verifier, "../../../../pacts/grpc-greeter-client-grpc-greeter.json");

            // Arrange
            // Setup our app to run before our verifier executes
            // Setup a cancellation token so we can shutdown the app after
            var cts = new CancellationTokenSource();
            var token = cts.Token;
            var runAppTask = Task.Run(async () =>
            {
                await GrpcGreeterService.RunApp([], token);
            }, token);
            await Task.Delay(2000);

            // Act
            var VerifierExecuteResult = Pact.VerifierExecute(verifier);
            VerifierExecuteResult.Should().Be(0);
            Pact.VerifierShutdown(verifier);
            // After test execution, signal the task to terminate
            cts.Cancel();
        }
    }
}
