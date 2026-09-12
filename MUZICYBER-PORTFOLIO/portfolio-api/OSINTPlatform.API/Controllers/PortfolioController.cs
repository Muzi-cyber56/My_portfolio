using System.Net;
using System.Net.Mail;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;
using OSINTPlatform.Core.DTOs;
namespace OSINTPlatform.API.Controllers;
[ApiController, Route("api/portfolio")]
public sealed class PortfolioController(IConfiguration config, ILogger<PortfolioController> log) : ControllerBase
{
 [HttpPost("contact"), EnableRateLimiting("auth")]
 public async Task<IActionResult> Contact(ContactDto r, CancellationToken ct)
 {
  var s=config.GetSection("Smtp");
  if(string.IsNullOrWhiteSpace(s["Host"]) || string.IsNullOrWhiteSpace(s["Username"]) || string.IsNullOrWhiteSpace(s["Password"]))
   return Problem("The portfolio email service is not configured.",statusCode:503);
  try {
   var from=s["From"] ?? s["Username"]!;
   var appPassword=s["Password"]!.Replace(" ",string.Empty);
   using var c=new SmtpClient(s["Host"],s.GetValue<int>("Port",587)) { EnableSsl=s.GetValue("EnableSsl",true), Timeout=12000, Credentials=new NetworkCredential(s["Username"],appPassword) };
   using var mail=new MailMessage(from,s["To"]??"muzicyber56@gmail.com",$"Muzicyber portfolio message from {r.Name.Trim()}",$"From: {r.Name.Trim()} <{r.Email.Trim()}>\n\n{r.Message.Trim()}") { ReplyToList={new MailAddress(r.Email.Trim())} };
   var deliveryTask=c.SendMailAsync(mail,ct);
   if(await Task.WhenAny(deliveryTask,Task.Delay(TimeSpan.FromSeconds(12),ct))!=deliveryTask) return Problem("The email server timed out. Please try again.",statusCode:504);
   await deliveryTask;
   return Ok(new { received=true, status="Emailed", message="Thanks. Your message was sent." });
  } catch(Exception e) { log.LogError(e,"Portfolio email failed"); return Problem("The message could not be delivered. Check the Gmail App Password and restart the API.",statusCode:502); }
 }
}
