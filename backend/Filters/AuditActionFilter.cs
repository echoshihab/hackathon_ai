using System.Security.Claims;
using backend.Models;
using backend.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;

namespace backend.Filters;

public class AuditActionFilter : IAsyncActionFilter
{
    private readonly IAuditService _audit;

    public AuditActionFilter(IAuditService audit) => _audit = audit;

    public async Task OnActionExecutionAsync(ActionExecutingContext context, ActionExecutionDelegate next)
    {
        var executed = await next();

        var httpContext = context.HttpContext;
        var user = httpContext.User;

        var controllerName = (context.Controller as ControllerBase)?.ControllerContext
            .ActionDescriptor.ControllerName ?? "Unknown";
        var actionName = context.ActionDescriptor.DisplayName ?? "Unknown";
        var httpMethod = httpContext.Request.Method.ToUpperInvariant();

        var statusCode = executed.Result switch
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

            Controller  = controllerName,
            Action      = actionName,
            HttpMethod  = httpMethod,
            StatusCode  = statusCode,
            ErrorMessage = executed.Exception?.Message
        };

        await _audit.LogAsync(entry);
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
