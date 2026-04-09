using System.Security.Claims;
using backend.Models;
using backend.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;

namespace backend.Filters;

public class AuditActionFilter : IAsyncActionFilter
{
    private readonly IAuditService _audit;
    private readonly ILogger<AuditActionFilter> _logger;

    public AuditActionFilter(IAuditService audit, ILogger<AuditActionFilter> logger)
    {
        _audit = audit;
        _logger = logger;
    }

    public async Task OnActionExecutionAsync(ActionExecutingContext context, ActionExecutionDelegate next)
    {
        var executed = await next();

        var httpContext = context.HttpContext;
        var user = httpContext.User;

        var controllerName = (context.Controller as ControllerBase)?.ControllerContext
            .ActionDescriptor.ControllerName ?? "Unknown";
        var actionName = context.ActionDescriptor.DisplayName ?? "Unknown";
        var httpMethod = httpContext.Request.Method.ToUpperInvariant();

        // When the action threw, treat it as a serious failure (outcome 8)
        var statusCode = executed.Exception != null
            ? 500
            : executed.Result switch
            {
                ObjectResult obj    => obj.StatusCode ?? 200,
                StatusCodeResult sc => sc.StatusCode,
                _                   => httpContext.Response.StatusCode
            };

        var entry = new AuditLog
        {
            EventType    = "PHI-Access",
            EventAction  = HttpMethodToAtnaAction(httpMethod),
            EventOutcome = statusCode < 400 ? 0 : (statusCode < 500 ? 4 : 8),

            UserId             = user.FindFirstValue(ClaimTypes.NameIdentifier),
            UserName           = user.FindFirstValue(ClaimTypes.Email),
            NetworkAccessPoint = httpContext.Connection.RemoteIpAddress?.ToString(),

            ResourceType = controllerName,
            ResourceId   = TryGetRouteId(context),

            Controller   = controllerName,
            Action       = actionName,
            HttpMethod   = httpMethod,
            StatusCode   = statusCode,
            ErrorMessage = executed.Exception?.Message
        };

        try
        {
            await _audit.LogAsync(entry);
        }
        catch (Exception auditEx)
        {
            // Never let an audit failure mask the original exception or crash the response
            _logger.LogError(auditEx,
                "Audit log write failed for {Controller}.{Action} — original outcome was {StatusCode}",
                controllerName, actionName, statusCode);
        }
    }

    private static string HttpMethodToAtnaAction(string method) => method switch
    {
        "GET"    => "R",
        "POST"   => "C",
        "PUT"    => "U",
        "PATCH"  => "U",
        "DELETE" => "D",
        _        => "E"
    };

    private static string? TryGetRouteId(ActionExecutingContext context)
    {
        if (context.RouteData.Values.TryGetValue("id", out var id))
            return id?.ToString();
        return null;
    }
}
