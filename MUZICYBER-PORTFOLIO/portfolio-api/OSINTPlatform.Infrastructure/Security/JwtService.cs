using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using OSINTPlatform.Core.DTOs;
using OSINTPlatform.Core.Entities;
namespace OSINTPlatform.Infrastructure.Security;
public sealed class JwtService(IConfiguration config)
{
 public AuthResult Issue(User user)
 {
  var expires=DateTimeOffset.UtcNow.AddMinutes(config.GetValue<int>("Jwt:Minutes",60));
  var claims=new[]{new Claim(JwtRegisteredClaimNames.Sub,user.Id.ToString()),new Claim(ClaimTypes.Name,user.Username),new Claim(ClaimTypes.Role,user.Role),new Claim(JwtRegisteredClaimNames.Jti,Guid.NewGuid().ToString())};
  var token=new JwtSecurityToken(config["Jwt:Issuer"],config["Jwt:Audience"],claims,expires:expires.UtcDateTime,signingCredentials:new SigningCredentials(new SymmetricSecurityKey(Encoding.UTF8.GetBytes(config["Jwt:Key"]!)),SecurityAlgorithms.HmacSha256));
  return new(new JwtSecurityTokenHandler().WriteToken(token),expires,user.Id,user.Username,user.Role);
 }
}
