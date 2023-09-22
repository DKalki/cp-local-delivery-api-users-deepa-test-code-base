using Microsoft.AspNetCore.Http;

namespace Cp.LocalDelivery.Core.Request
{
	public interface IHttpRequestContext
	{
		string CallingApplicationId { get; }

		HttpRequest HttpRequest { get; }

		string GetSingleHeaderValue(string header);
	}
}
