using Microsoft.AspNetCore.Mvc;

namespace ErpGovernance.Web.Controllers;

public class HomeController : Controller
{
    [Route("Home/Error")]
    [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
    public IActionResult Error()
    {
        return View();
    }

    public IActionResult Privacy()
    {
        return View();
    }
}
