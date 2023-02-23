using System;
using System.Web.Mvc;
using System.Collections.Generic;
using JobTrack.Models.Employee;
using JobTrack.Models.Profile;
using System.Configuration;
using System.Data;
using MySql.Data.MySqlClient;
using System.Linq;
using System.Net.Mail;
using System.Net;

namespace JobTrack.Controllers
{
    public class ProfileController : Controller
    {
        // CONNECTION STRING
        public MySqlConnection dbConnection = new MySqlConnection(ConfigurationManager.ConnectionStrings["SQLConn"].ConnectionString);
        public MySqlCommand cmd = new MySqlCommand();
        public MySqlDataAdapter adp = new MySqlDataAdapter();

        // CONNECTION STRING FOR USER
        public MySqlConnection dbConnection_User = new MySqlConnection(ConfigurationManager.ConnectionStrings["SQLConn_User"].ConnectionString);
        public MySqlCommand cmd_User = new MySqlCommand();
        public MySqlDataAdapter adp_User = new MySqlDataAdapter();

        public ActionResult TopMenu()
        {
            return PartialView("_Topbar");
        }

        public ActionResult SideMenu()
        {
            if (Session["UserAccess"].ToString() == "Admin")
            {
                return PartialView("_SidebarAdmin");
            }
            else if (Session["UserAccess"].ToString() == "Client(LE)")
            {
                return PartialView("_Sidebar_LE");
            }
            else if (Session["UserAccess"].ToString() == "Straive(PE)")
            {
                return PartialView("_SidebarRegular");
            }
            else if (Session["UserAccess"].ToString() == "Coding")
            {
                return PartialView("_SidebarRegular");
            }
            else if (Session["UserAccess"].ToString() == "Coding TL")
            {
                return PartialView("_SidebarCodingTL");
            }
            else if (Session["UserAccess"].ToString() == "Straive(PE) TL")
            {
                return PartialView("_Sidebar_PETL");
            }
            return View();
        }
        public ActionResult EditProfile()
        {
            #region Check Session
            if (Session["UserName"] == null)
            {
                TempData["alertMessage"] = "You must log in to continue";
                return RedirectToAction("Login", "Login");
            }
            #endregion
            if (dbConnection_User.State == ConnectionState.Closed)
                dbConnection_User.Open();

            ProfileData mdata = new ProfileData();
            try
            {
                DataTable dt = new DataTable();
                var Username = Session["UserName"];
                cmd_User = new MySqlCommand("GetEmployeeDataByUserName", dbConnection_User);
                cmd_User.CommandType = CommandType.StoredProcedure;

                cmd_User.Parameters.Clear();
                //cmd_User.Parameters.AddWithValue("@p_EmployeeID", employeeid);
                cmd_User.Parameters.AddWithValue("@p_UserName", Username);
                adp_User = new MySqlDataAdapter(cmd_User);
                adp_User.Fill(dt);

                foreach (DataRow dr in dt.Rows)
                {
                    mdata.EmployeeID = Convert.ToInt32(dr["EmployeeID"].ToString());
                    mdata.UserAccessName = dr["UserAccessName"].ToString();
                    mdata.Status = dr["Status"].ToString();
                    mdata.UserName = dr["UserName"].ToString();
                    mdata.FirstName = dr["FirstName"].ToString();
                    mdata.LastName = dr["LastName"].ToString();
                    mdata.FullName = dr["FullName"].ToString();
                    mdata.EmailAddress = dr["EmailAddress"].ToString();
                    mdata.MobileNumber = dr["MobileNumber"].ToString();
                    mdata.IsManager = Convert.ToBoolean(Convert.ToInt32(dr["IsManager"]));
                    mdata.IsEditorialContact = Convert.ToBoolean(Convert.ToInt32(dr["IsEditorialContact"]));
                    mdata.IsEmailList = Convert.ToBoolean(Convert.ToInt32(dr["IsEmailList"]));
                    mdata.IsMandatoryRecepient = Convert.ToBoolean(Convert.ToInt32(dr["IsMandatoryRecepient"]));
                    mdata.IsShowUser = Convert.ToBoolean(Convert.ToInt32(dr["IsShowUser"]));
                    mdata.DateCreated = Convert.ToDateTime(dr["DateCreated"].ToString());
                    mdata.PasswordUpdate = Convert.ToDateTime(dr["PasswordUpdate"].ToString());

                }
                dbConnection_User.Close();
                return View(mdata);
            }



            catch (Exception ex)
            {
                ModelState.AddModelError("ErrorMessage", ex.Message);
                mdata.ErrorMessage = ex.Message;
                dbConnection_User.Close();
                return View(mdata);
            }
        }
    }
}