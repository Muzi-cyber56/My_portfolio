using System.Diagnostics;
using Microsoft.Extensions.Configuration;
namespace OSINTPlatform.Infrastructure.Forensics;
public sealed class OCRService(IConfiguration config)
{
 public async Task<(string Status,string Text)> ExtractAsync(byte[] bytes,CancellationToken ct)
 {
  var executable=config["Forensics:TesseractPath"];
  if(string.IsNullOrWhiteSpace(executable)) return ("Not configured. Set Forensics:TesseractPath to enable local OCR.","");
  if(!Path.IsPathFullyQualified(executable) || !File.Exists(executable)) return ("Configured OCR executable was not found.","");
  var temp=Path.Combine(Path.GetTempPath(),"sentinel-ocr-"+Guid.NewGuid().ToString("N")+".img");
  await File.WriteAllBytesAsync(temp,bytes,ct);
  try {
   using var process=new Process { StartInfo=new ProcessStartInfo(executable) { UseShellExecute=false,CreateNoWindow=true,RedirectStandardOutput=true,RedirectStandardError=true } };
   process.StartInfo.ArgumentList.Add(temp);process.StartInfo.ArgumentList.Add("stdout");
   process.StartInfo.ArgumentList.Add("-l");process.StartInfo.ArgumentList.Add("eng");
   process.Start();
   var output=process.StandardOutput.ReadToEndAsync(ct);var error=process.StandardError.ReadToEndAsync(ct);
   using var limit=CancellationTokenSource.CreateLinkedTokenSource(ct);limit.CancelAfter(TimeSpan.FromSeconds(20));
   try { await process.WaitForExitAsync(limit.Token); }
   catch(OperationCanceledException) { if(!process.HasExited) process.Kill(true);if(ct.IsCancellationRequested)throw;return ("OCR timed out.",""); }
   var text=await output;_ = await error;
   return process.ExitCode==0 ? ("Completed. Machine-recognized text requires review.",text[..Math.Min(text.Length,100000)]) : ("OCR failed. Verify the engine and English language data.","");
  } catch(System.ComponentModel.Win32Exception) { return ("OCR executable could not start.",""); }
  finally { File.Delete(temp); }
 }
}
