using System;
using System.Web.Mvc;
using System.Collections.Generic;
using JobTrack.Models.Employee;
using JobTrack.Models.Admin;
using System.Configuration;
using System.Data;
using MySql.Data.MySqlClient;


namespace JobTrack.Controllers
{
    public class PETLController : Controller
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
            return PartialView("_Sidebar_PETL");
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

            cmd = new MySqlCommand("GetAllActiveJobDataPE", dbConnection);
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