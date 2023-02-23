using System;
using JobTrack.Models;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Collections.Generic;
using System.Net;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using JobTrack.Models.Job;
using JobTrack.Models.Coversheet;
using MySql.Data.MySqlClient;
using System.Globalization;
using JobTrack.Models.Employee;

namespace JobTrack.Controllers
{
    public class CodingTLController : Controller
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
            return PartialView("_Sidebar_CodingTL");
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
        public ActionResult GetJobCoversheetData()
        {
            if (dbConnection.State == ConnectionState.Closed)
                dbConnection.Open();

            List<CoversheetData> mdata = new List<CoversheetData>();
            DataTable dt = new DataTable();

            cmd = new MySqlCommand("GetAllActiveJobCoversheetData", dbConnection);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Clear();
            adp = new MySqlDataAdapter(cmd);
            adp.Fill(dt);

            foreach (DataRow dr in dt.Rows)
            {
                mdata.Add(new CoversheetData
                {

                    JobCoversheetID = Convert.ToInt32(dr["JobCoversheetID"].ToString()),
                    BPSProductID = dr["BPSProductID"].ToString(),
                    ServiceNumber = dr["ServiceNumber"].ToString(),
                    LatestTaskNumber = dr["LatestTaskNumber"].ToString(),
                    DateCreated = Convert.ToDateTime(dr["DateCreated"].ToString()),
                    DateUpdated = Convert.ToDateTime(dr["DateUpdated"].ToString())

                });
            }
            dbConnection.Close();
            return Json(mdata, JsonRequestBehavior.AllowGet);
        }
        public ActionResult GetCoversheetData(string bpsproductid, string servicenumber)
        {
            if (dbConnection.State == ConnectionState.Closed)
                dbConnection.Open();

            List<CoversheetData> mdata = new List<CoversheetData>();
            DataTable dt = new DataTable();

            cmd = new MySqlCommand("GetAllActiveCoversheetData", dbConnection);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@p_BPSProductID", bpsproductid);
            cmd.Parameters.AddWithValue("@p_ServiceNumber", servicenumber);
            adp = new MySqlDataAdapter(cmd);
            adp.Fill(dt);
            foreach (DataRow dr in dt.Rows)
            {
                mdata.Add(new CoversheetData
                {

                    CoversheetID = Convert.ToInt32(dr["CoversheetID"].ToString()),
                    CoversheetNumber = dr["CoversheetNumber"].ToString(),
                    CoversheetTier = dr["CoversheetTier"].ToString(),
                    TaskNumber = dr["TaskNumber"].ToString(),

                    BPSProductID = dr["BPSProductID"].ToString(),
                    ServiceNumber = dr["ServiceNumber"].ToString(),
                    JobOwner = dr["CurrentOwner"].ToString(),
                    DateUpdated = Convert.ToDateTime(dr["DateUpdated"])

                });
            }
            dbConnection.Close();
            return Json(mdata, JsonRequestBehavior.AllowGet);
        }
    }
}