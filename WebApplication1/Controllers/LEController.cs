using System;
using System.Web.Mvc;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using MySql.Data.MySqlClient;
using JobTrack.Models.Employee;

namespace JobTrack.Controllers
{
    public class LEController : Controller
    {
        // CONNECTION STRING
        public MySqlConnection dbConnection = new MySqlConnection(ConfigurationManager.ConnectionStrings["SQLConn"].ConnectionString);
        public MySqlCommand cmd = new MySqlCommand();
        public MySqlDataAdapter adp = new MySqlDataAdapter();

        public ActionResult TopMenu()
        {
            return PartialView("_Topbar");
        }

        public ActionResult SideMenu()
        {
            return PartialView("_Sidebar_LE");
        }
        public ActionResult MainForm()
        {
            #region Check Session
            if (Session["UserName"] == null)
            {
                TempData["alertMessage"] = "You must log in to continue";
                return RedirectToAction("Login", "Login");
            }
            #endregion

            return View();
        }
        public ActionResult AllJob()
        {
            #region Check Session
            if (Session["UserName"] == null)
            {
                TempData["alertMessage"] = "You must log in to continue";
                return RedirectToAction("Login", "Login");
            }
            #endregion

            return View();
        }
        public ActionResult JobReassignment()
        {
            #region Check Session
            if (Session["UserName"] == null)
            {
                TempData["alertMessage"] = "You must log in to continue";
                return RedirectToAction("Login", "Login");
            }
            #endregion

            return View();
        }
        public ActionResult GetJobReassignmentData()
        {
            if (dbConnection.State == ConnectionState.Closed)
                dbConnection.Open();

            List<JobReassignmentData> mdata = new List<JobReassignmentData>();
            DataTable dt = new DataTable();

            cmd = new MySqlCommand("GetAllActiveJobDataLE", dbConnection);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Clear();
            adp = new MySqlDataAdapter(cmd);
            adp.Fill(dt);
            foreach (DataRow dr in dt.Rows)
            {
                mdata.Add(new JobReassignmentData
                {

                    TransactionLogID = Convert.ToInt32(dr["TransactionLogID"].ToString()),
                    JobNumber = dr["JobNumber"].ToString(),
                    BPSProductID = dr["BPSProductID"].ToString(),
                    ServiceNumber = Convert.ToInt32(dr["ServiceNumber"].ToString()),
                    CurrentOwner = dr["CurrentOwner"].ToString(),
                    DateUpdated = Convert.ToDateTime(dr["DateUpdated"].ToString())

                });
            }
            dbConnection.Close();
            return Json(mdata, JsonRequestBehavior.AllowGet);
        }
    }
}