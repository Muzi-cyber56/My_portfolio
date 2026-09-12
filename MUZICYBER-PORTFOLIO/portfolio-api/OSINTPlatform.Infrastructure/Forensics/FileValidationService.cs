using OSINTPlatform.Core;
namespace OSINTPlatform.Infrastructure.Forensics;
public sealed class FileValidationService
{
 public const int MaxBytes=10*1024*1024;
 public string Validate(string name,byte[] bytes,bool imageOnly=false)
 {
  if(bytes.Length==0 || bytes.Length>MaxBytes) throw new ValidationException("Choose a non-empty file up to 10 MB.");
  var ext=Path.GetExtension(name).ToLowerInvariant();
  if(ext==".png" && bytes.Length>=24 && bytes.AsSpan(0,8).SequenceEqual(new byte[]{137,80,78,71,13,10,26,10}) && bytes.AsSpan(12,4).SequenceEqual("IHDR"u8)) return "image/png";
  if((ext==".jpg" || ext==".jpeg") && bytes.Length>=4 && bytes[0]==255 && bytes[1]==216 && bytes[2]==255) return "image/jpeg";
  if(!imageOnly && ext==".pdf" && bytes.Length>=5 && bytes.AsSpan(0,5).SequenceEqual("%PDF-"u8)) return "application/pdf";
  if(!imageOnly && ext==".txt" && !bytes.Contains((byte)0)) {
   try { _=new System.Text.UTF8Encoding(false,true).GetString(bytes); return "text/plain"; } catch(System.Text.DecoderFallbackException) { }
  }
  throw new ValidationException(imageOnly ? "Only PNG and JPEG images with matching signatures are accepted." : "Accepted evidence: PNG, JPEG, PDF and UTF-8 TXT with matching signatures.");
 }
}
