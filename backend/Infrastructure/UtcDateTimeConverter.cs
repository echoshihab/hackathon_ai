using System.Text.Json;
using System.Text.Json.Serialization;

namespace backend.Infrastructure;

/// <summary>
/// Treats any DateTime with Kind=Unspecified arriving in JSON as UTC.
/// Prevents Npgsql from rejecting dates sent from date-only HTML inputs.
/// </summary>
public class UtcDateTimeConverter : JsonConverter<DateTime>
{
    public override DateTime Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
    {
        var value = reader.GetDateTime();
        return value.Kind == DateTimeKind.Unspecified
            ? DateTime.SpecifyKind(value, DateTimeKind.Utc)
            : value.ToUniversalTime();
    }

    public override void Write(Utf8JsonWriter writer, DateTime value, JsonSerializerOptions options) =>
        writer.WriteStringValue(value.ToUniversalTime());
}
