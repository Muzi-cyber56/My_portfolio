using System.Buffers.Binary;
using MetadataExtractor;
using OSINTPlatform.Core.DTOs;
using OSINTPlatform.Core.Interfaces;
namespace OSINTPlatform.Infrastructure.Forensics;
public sealed class ImageMetadataService(OCRService ocr) : IImageForensicsService
{
 public async Task<ImageAnalysisDtoResult> AnalyzeAsync(byte[] data,CancellationToken ct)
 {
  int? width=null,height=null; string format="JPEG";
  if(data.Length>=24 && data.AsSpan(0,8).SequenceEqual(new byte[]{137,80,78,71,13,10,26,10})) {
   format="PNG";width=BinaryPrimitives.ReadInt32BigEndian(data.AsSpan(16,4));height=BinaryPrimitives.ReadInt32BigEndian(data.AsSpan(20,4));
  } else {
   int p=2;
   while(p+4<data.Length) {
    if(data[p++]!=255)break;
    byte marker=data[p++];if(marker==0xd9 || marker==0xda)break;
    if(marker==0xff){p--;continue;}
    int size=BinaryPrimitives.ReadUInt16BigEndian(data.AsSpan(p,2));
    if(size<2 || p+size>data.Length)break;
    if((marker is >=0xc0 and <=0xc3 or >=0xc5 and <=0xc7 or >=0xc9 and <=0xcb or >=0xcd and <=0xcf) && size>=7) {
     height=BinaryPrimitives.ReadUInt16BigEndian(data.AsSpan(p+3,2));width=BinaryPrimitives.ReadUInt16BigEndian(data.AsSpan(p+5,2));break;
    }p+=size;
   }
  }
  var tags=new Dictionary<string,string>();string status;
  try {
   using var stream=new MemoryStream(data,false);
   var directories=ImageMetadataReader.ReadMetadata(stream);
   foreach(var dir in directories)foreach(var tag in dir.Tags.Take(200))tags[$"{dir.Name}: {tag.Name}"]=tag.Description ?? "";
   status=directories.Any(d=>d.Name.StartsWith("Exif",StringComparison.OrdinalIgnoreCase)) ? "EXIF extracted. Metadata can be edited and does not establish authenticity." : "Metadata inspected. No EXIF directory was found.";
  } catch(ImageProcessingException) { status="Metadata parser could not read this image. Original bytes were preserved."; }
    catch(IOException) { status="Image metadata is truncated or malformed. Original bytes were preserved."; }
  var recognized=width>0 && height>0 && (long)width*height<=50_000_000 ? await ocr.ExtractAsync(data,ct) : ("Skipped: dimensions missing or image exceeds 50 megapixels.","");
  return new(format,width,height,HashingService.Hash(data),status,recognized.Item1,tags,recognized.Item2);
 }
}
