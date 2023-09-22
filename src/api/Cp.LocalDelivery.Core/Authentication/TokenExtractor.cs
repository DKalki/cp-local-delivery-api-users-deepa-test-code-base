using System.IdentityModel.Tokens.Jwt;
using Microsoft.AspNetCore.Http;

namespace Cp.LocalDelivery.Core.Authentication
{
	public class TokenExtractor : ITokenExtractor
	{
		private string? _tokenString;
		private JwtSecurityToken? _token;

		public JwtSecurityToken? ExtractToken(HttpRequest request)
		{
			if (request == null)
				return null;

			if (!request.Headers.ContainsKey("Authorization"))
				return null;

			var tokenString = request.Headers["Authorization"].ToString().Replace("Bearer ", "");

			if (string.IsNullOrEmpty(tokenString))
				return null;

			if (_tokenString == tokenString)
				return _token;

			try
			{
				var jwtHandler = new JwtSecurityTokenHandler();

				_token = jwtHandler.ReadJwtToken(tokenString);
				_tokenString = tokenString;
			}
			catch
			{
				return null;
			}

			return _token;
		}
	}
}
