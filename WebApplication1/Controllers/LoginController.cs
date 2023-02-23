using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using JobTrack.Models.Login;
using JobTrack.Models.Employee;
using CaptchaMvc;
using CaptchaMvc.HtmlHelpers;
using JobTrack.Services;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.Security;
using MySql.Data.MySqlClient;


namespace JobTrack.Controllers
{
    public class LoginController : Controller
    {
        // CONNECTION STRING
        MySqlConnection dbConnection = new MySqlConnection(ConfigurationManager.ConnectionStrings["SQLConn"].ConnectionString);
        public MySqlCommand cmd = new MySqlCommand();
        public MySqlDataAdapter adp = new MySqlDataAdapter();
        // CONNECTION STRING FOR USER
        public MySqlConnection dbConnection_User = new MySqlConnection(ConfigurationManager.ConnectionStrings["SQLConn_User"].ConnectionString);
        public MySqlCommand cmd_User = new MySqlCommand();
        public MySqlDataAdapter adp_User = new MySqlDataAdapter();

        // GET: Login
        [HttpGet]
        public ActionResult Login()
        {
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Login(LoginViewModel loginViewModel)
        {
            try
            {
                if (!this.IsCaptchaValid("Captcha is not valid"))
                {
                    ViewBag.errormessage = "Captcha entered is not valid";

                    return View(loginViewModel);
                }
                if (!string.IsNullOrEmpty(loginViewModel.Username) && !string.IsNullOrEmpty(loginViewModel.Password))
                {
                    var result = IsUserValid(loginViewModel.Username, loginViewModel.Password);
                    if (result != null)
                    {
                        if (result.EmployeeID == 0 || result.EmployeeID < 0)
                        {
                            ViewBag.errormessage = "Entered Invalid Username and Password";
                        }
                        else
                        {
                            var UserAccess = result.UserAccess;
                            Remove_Anonymous_Cookies(); //Remove Anonymous_Cookies

                            Session["UserAccess"] = Convert.ToString(result.UserAccess);
                            Session["UserName"] = Convert.ToString(result.UserName);
                            if (UserAccess == "Admin")
                            {
                                Session["EmployeeID"] = Convert.ToString(result.EmployeeID);
                                return RedirectToAction("AllJob", "Admin");
                            }
                            else if (UserAccess == "Client(LE)")
                            {
                                Session["EmployeeID"] = Convert.ToString(result.EmployeeID);
                                return RedirectToAction("Mainform", "LE");
                            }
                            else if (UserAccess == "Straive(PE)")
                            {
                                Session["EmployeeID"] = Convert.ToString(result.EmployeeID);
                                return RedirectToAction("Mainform", "PE");
                            }
                            else if (UserAccess == "Coding")
                            {
                                Session["EmployeeID"] = Convert.ToString(result.EmployeeID);
                                return RedirectToAction("Mainform", "Coding");
                            }
                            else if (UserAccess == "Coding TL")
                            {
                                Session["EmployeeID"] = Convert.ToString(result.EmployeeID);
                                return RedirectToAction("AllJob", "CodingTL");
                            }
                            else if (UserAccess == "Straive(PE) TL")
                            {
                                Session["EmployeeID"] = Convert.ToString(result.EmployeeID);
                                return RedirectToAction("AllJob", "PETL");
                            }
                        }
                    }
                    else
                    {
                        ViewBag.errormessage = "Invalid Username or Password";
                        return View(loginViewModel);
                    }
                }

                return View(loginViewModel);
            }
            catch (Exception)
            {
                throw;
            }
        }

        public EmployeeRegistration IsUserValid(string username, string password)
        {
            try
            {
                var user = GetUserPassword().FirstOrDefault(model => model.UserName == username && model.Password == password);
                return user;
            }
            catch (Exception)
            {

                throw;
            }
        }

        public List<EmployeeRegistration> GetUserPassword()
        {

            List<EmployeeRegistration> mdata = new List<EmployeeRegistration>();
            DataTable dt = new DataTable();

            cmd_User = new MySqlCommand("GetAllUserPassword", dbConnection_User);
            cmd_User.CommandType = CommandType.StoredProcedure;
            adp_User = new MySqlDataAdapter(cmd_User);
            adp_User.Fill(dt);

            if (dbConnection_User.State == ConnectionState.Closed)
                dbConnection_User.Open();

            foreach (DataRow dr in dt.Rows)
            {
                mdata.Add(new EmployeeRegistration
                {
                    EmployeeID = Convert.ToInt32(dr[0]),
                    UserName = Convert.ToString(dr[1]),
                    Password = Convert.ToString(dr[2]),
                    UserAccess = Convert.ToString(dr[5]),
                });
            }
            return mdata;
        }


        [HttpGet]
        public ActionResult LogOut()
        {
            Response.Cache.SetCacheability(HttpCacheability.NoCache);
            Response.Cache.SetExpires(DateTime.Now.AddSeconds(-1));
            Response.Cache.SetNoStore();

            HttpCookie Cookies = new HttpCookie("WebTime");
            Cookies.Value = "";
            Cookies.Expires = DateTime.Now.AddHours(-1);
            Response.Cookies.Add(Cookies);
            HttpContext.Session.Clear();
            Session.Abandon();
            return RedirectToAction("Login", "Login");
        }

        [NonAction]
        public void Remove_Anonymous_Cookies()
        {
            try
            {

                if (Request.Cookies["WebTime"] != null)
                {
                    var option = new HttpCookie("WebTime");
                    option.Expires = DateTime.Now.AddDays(-1);
                    Response.Cookies.Add(option);
                }
            }
            catch (Exception)
            {

                throw;
            }
        }

        public static string Base64Encode(string plainText)
        {
            var plainTextBytes = System.Text.Encoding.UTF8.GetBytes(plainText);
            return System.Convert.ToBase64String(plainTextBytes);
        }
        public static string Base64Decode(string base64EncodedData)
        {
            var base64EncodedBytes = System.Convert.FromBase64String(base64EncodedData);
            return System.Text.Encoding.UTF8.GetString(base64EncodedBytes);
        }


    }
}