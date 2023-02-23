using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Routing;

namespace JobTrack_AUNZ
{
    public class RouteConfig
    {
        public static void RegisterRoutes(RouteCollection routes)
        {
            routes.IgnoreRoute("{resource}.axd/{*pathInfo}");

            routes.MapRoute(
                name: "Default",
                url: "{controller}/{action}/{id}",
                defaults: new { controller = "User", action = "Login", id = UrlParameter.Optional }
            );

            routes.MapRoute(
            name: "LEc",
            url: "{controller}/{action}/{id}",
            defaults: new { controller = "LE", action = "LECreateModal", id = UrlParameter.Optional }
            );


            routes.MapRoute(
                name: "LE",
                url: "{controller}/{action}/{id}",
                defaults: new { controller = "LE", action = "LEAddJob", id = UrlParameter.Optional }
            );


            routes.MapRoute(
                name: "PE",
                url: "{controller}/{action}/{id}",
                defaults: new { controller = "PE", action = "PEAddTask", id = UrlParameter.Optional }
            );

            routes.MapRoute(
               name: "User",
               url: "{controller}/{action}/{id}",
               defaults: new { controller = "User", action = "LogOff", id = UrlParameter.Optional }
           );



        }
    }
}
