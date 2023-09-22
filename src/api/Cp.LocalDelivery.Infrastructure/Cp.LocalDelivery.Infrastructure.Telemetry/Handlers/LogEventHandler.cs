using Cp.LocalDelivery.Core.Authentication;
using Cp.LocalDelivery.Core.Request;
using Microsoft.Extensions.Logging;
using Tracking;
using Tracking.Models;

namespace Cp.LocalDelivery.Infrastructure.Telemetry.Handlers
{
	public class LogEventHandler
	{
		private readonly ITracker _tracker;
		private readonly IHttpRequestContext _httpRequestContext;
		private readonly ITokenExtractor _tokenExtractor;

		public LogEventHandler(
			ITracker tracker,
			IHttpRequestContext httpRequestContext,
			ITokenExtractor tokenExtractor)
		{
			_tracker = tracker ?? throw new ArgumentNullException(nameof(tracker));
			_httpRequestContext = httpRequestContext ?? throw new ArgumentNullException(nameof(httpRequestContext));
			_tokenExtractor = tokenExtractor ?? throw new ArgumentNullException(nameof(tokenExtractor));
		}

		public async Task Log(Core.Logging.LogEvent notification, CancellationToken cancellationToken)
		{
			await SetContext();

			if (notification.Level == LogLevel.Error)
			{
				await _tracker.ErrorAsync(new Log
				{
					EventText = notification.EventText,
					Error = notification.Error,
					EventDate = notification.EventDate,
					CategoryErn = notification.CategoryErn,
					KBNumber = notification.KbNumber
				});
			}
			else
			{
				await _tracker.InfoAsync(new Log
				{
					EventText = notification.EventText,
					EventDate = notification.EventDate,
					CategoryErn = notification.CategoryErn
				});
			}
		}

		private async Task SetContext()
		{
			if (!string.IsNullOrWhiteSpace(_httpRequestContext.CallingApplicationId))
				_tracker.SetCallerAppId(_httpRequestContext.CallingApplicationId);

			await _tracker.SetJwtSecurityTokenContextAsync(_tokenExtractor.ExtractToken(_httpRequestContext.HttpRequest));
		}
	}
}
