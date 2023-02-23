using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Extensions.Logging;
using System.Threading.Tasks;

namespace FunctionApp;

public static class Function
{
    [FunctionName("Function")]
    public static Task<IActionResult> Run(
        [HttpTrigger(AuthorizationLevel.Anonymous, "get", "post", Route = null)]
        HttpRequest request,
        ILogger logger)
    {
        logger.LogInformation("C# HTTP trigger function processed a request.");

        IActionResult result = new OkObjectResult("This HTTP triggered function executed successfully (Container).");

        return Task.FromResult(result);
    }
}