using OSINTPlatform.Core;
using OSINTPlatform.Infrastructure.Forensics;
using OSINTPlatform.Infrastructure.Reports;
using System.Text;
namespace OSINTPlatform.Tests;
public sealed class ForensicsTests
{
 [Fact] public void KnownSha256Matches()=>Assert.Equal("ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad",HashingService.Hash("abc"u8.ToArray()));
 [Fact] public void ChangedBytesFailIntegrity(){var hash=HashingService.Hash("original"u8.ToArray());Assert.False(new EvidenceIntegrityService().Verify("changed"u8.ToArray(),hash));}
 [Fact] public void SpoofedImageIsRejected()=>Assert.Throws<ValidationException>(()=>new FileValidationService().Validate("image.png","not a png"u8.ToArray()));
 [Fact] public void OversizeEvidenceIsRejected()=>Assert.Throws<ValidationException>(()=>new FileValidationService().Validate("huge.txt",new byte[FileValidationService.MaxBytes+1]));
 [Fact] public void PlainTextCannotEnterImageEndpoint()=>Assert.Throws<ValidationException>(()=>new FileValidationService().Validate("note.txt","note"u8.ToArray(),true));
 [Fact] public void PdfEscapesTextAndPaginates(){var pdf=Encoding.ASCII.GetString(PdfReportService.Render(Enumerable.Repeat("Evidence (review) \\ source",120)));Assert.StartsWith("%PDF-1.4",pdf);Assert.Contains("/Count 3",pdf);Assert.Contains(@"\(review\)",pdf);Assert.EndsWith("%%EOF\n",pdf);}
}
