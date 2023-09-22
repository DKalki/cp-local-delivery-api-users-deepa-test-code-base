using Microsoft.Extensions.Logging;

namespace Cp.LocalDelivery.Core.Logging
{
	public class LogEvent
	{
		public LogEvent(Exception error, LogLevel logLevel, string eventText)
		: this(null, null, error, logLevel, eventText)
		{
		}

		public LogEvent(LogLevel logLevel, string eventText)
			: this(null, null, null, logLevel, eventText)
		{
		}

		public LogEvent(string? categoryErn, string? kbNumber, Exception? error, LogLevel logLevel, string eventText)
		{
			Error = error;
			EventDate = DateTime.UtcNow;
			KbNumber = kbNumber;
			Level = logLevel;
			CategoryErn = categoryErn;
			EventText = eventText;
		}

		public DateTimeOffset? EventDate { get; set; }
		public string? CategoryErn { get; set; }
		public Exception? Error { get; set; }
		public string? KbNumber { get; set; }
		public LogLevel Level { get; set; }
		public string EventText { get; set; }
	}
}
