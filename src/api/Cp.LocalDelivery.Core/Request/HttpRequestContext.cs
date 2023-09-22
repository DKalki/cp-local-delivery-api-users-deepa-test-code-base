using Microsoft.AspNetCore.Http;

namespace Cp.LocalDelivery.Core.Request
{
	public class HttpRequestContext : IHttpRequestContext
	{
		private readonly IHttpContextAccessor _httpContextAccessor;

		public HttpRequestContext(IHttpContextAccessor httpContextAccessor)
		{
			_httpContextAccessor = httpContextAccessor ?? throw new ArgumentNullException(nameof(httpContextAccessor));
		}

		public string CallingApplicationId
		{
			get { return GetSingleHeaderValue("EMIS-AppId"); }
		}

		public string GetSingleHeaderValue(string header)
		{
			if (!_httpContextAccessor.HttpContext.Request.Headers.TryGetValue(header, out var headerValues))
				return string.Empty;

			return headerValues.First();
		}

		public HttpRequest HttpRequest
		{
			get { return _httpContextAccessor.HttpContext.Request; }
		}
	}
}
