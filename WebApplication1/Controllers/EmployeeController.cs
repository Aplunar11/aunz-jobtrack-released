using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Security;
using System.Web.Mvc;
using JobTrack.Models.Employee;
using JobTrack.Services;
using CaptchaMvc.HtmlHelpers;


namespace JobTrack.Controllers
{
    public class EmployeeController : Controller
    {
        // GET: Employee
        [Route("EmployeeLogin")]
        public ActionResult EmployeeLogin(int? id)

        {

            return View();

            //return RedirectToAction("Index", "Home");

        }
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult EmployeeLogin(EmployeeLogin account)

        {
            FormsAuthentication.SetAuthCookie(account.ID, false);
            FormsAuthentication.SetAuthCookie(account.Password, false);
            AuthenticationWrapper authenticationWrapper = new AuthenticationWrapper();
            try
            {
                if (authenticationWrapper.IsUserValid(account.ID, account.Password))
                {
                    //image validation
                    //if (Session["UserImagePath"].ToString() == "")
                    //{
                    //    Session["UserImagePath"] = "default.jpg";
                    //}
                    TempData["Message"] = "";
                    TempData["Toastr"] = "";
                    return RedirectToAction("MainForm", "Home");
                }
                else
                {
                    TempData["Message"] = "Invalid UsernName or Password";
                    TempData["Toastr"] = "warning";
                    return RedirectToAction("EmployeeLogin", "Employee", new { @id = "" });
                    //return View(account);
                }
            }
            catch (Exception)
            {
                TempData["Message"] = "Invalid UserName or Password";
                TempData["Toastr"] = "warning";
                return RedirectToAction("EmployeeLogin", "Employee", new { @id = "" });
                //return View(account);
            }
            //return RedirectToAction("MainForm", "Home");

        }


    }
}