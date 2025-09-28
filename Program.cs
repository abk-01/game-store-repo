using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Text;

// Small runner that delegates to the API project when run from the solution root.
// Purpose: make `dotnet run` work at repo root by launching the proper project.

// When building/running from the repo root, AppContext.BaseDirectory will be
// something like ...\GameStore\bin\Debug\net8.0\. We want to find the
// GameStore.Api project file relative to the repo root.
string repoRoot = Path.GetFullPath(Path.Combine(AppContext.BaseDirectory, "..", "..", ".."));
string apiPath = Path.GetFullPath(Path.Combine(repoRoot, "GameStore.Api", "GameStore.Api.csproj"));

if (!File.Exists(apiPath))
{
    Console.Error.WriteLine($"API project not found at {apiPath}");
    return 1;
}

var psi = new ProcessStartInfo();
psi.FileName = "dotnet";
psi.Arguments = $"run --project \"{apiPath}\"" + (args.Contains("--watch") ? " --watch" : "");
psi.UseShellExecute = false;
psi.RedirectStandardOutput = true;
psi.RedirectStandardError = true;

var p = Process.Start(psi) ?? throw new Exception("failed to start dotnet");

// Relay output so user sees the server logs
_ = Task.Run(async () =>
{
    var buffer = new char[1024];
    while (!p.StandardOutput.EndOfStream)
    {
        int read = await p.StandardOutput.ReadAsync(buffer, 0, buffer.Length);
        if (read > 0) Console.Write(new string(buffer, 0, read));
    }
});

_ = Task.Run(async () =>
{
    var buffer = new char[1024];
    while (!p.StandardError.EndOfStream)
    {
        int read = await p.StandardError.ReadAsync(buffer, 0, buffer.Length);
        if (read > 0) Console.Error.Write(new string(buffer, 0, read));
    }
});

p.WaitForExit();
return p.ExitCode;