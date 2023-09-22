using System.IdentityModel.Tokens.Jwt;
using Microsoft.AspNetCore.Http;

namespace Cp.LocalDelivery.Core.Authentication
{
	public interface ITokenExtractor
	{
		JwtSecurityToken? ExtractToken(HttpRequest request);
	}
}
