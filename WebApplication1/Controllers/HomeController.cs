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

namespace JobTrack.Controllers
{
    public class HomeController : Controller
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
            return PartialView("_SidebarAdmin");
        }

        public ActionResult MainForm()
        {
            //#region Check Session
            //if (Session["Username"] == null)
            //{
            //    TempData["Message"] = "You must log in to continue";
            //    TempData["Toastr"] = "error";
            //    return RedirectToAction("Login", "Login");
            //}
            //#endregion
            return View();
        }
        public ActionResult GetJobTrackData()
        {
            //#region Check Session
            //if (Session["Username"] == null)
            //{
            //    TempData["Message"] = "You must log in to continue";
            //    TempData["Toastr"] = "error";
            //    return RedirectToAction("Login", "Login");
            //}
            //#endregion
            if (dbConnection.State == ConnectionState.Closed)
                dbConnection.Open();

            List<JobData> mdata = new List<JobData>();
            DataTable dt = new DataTable();

            cmd = new MySqlCommand("GetAllJobData", dbConnection);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Clear();
            //cmd.Parameters.AddWithValue("@int_owner", owner);
            adp = new MySqlDataAdapter(cmd);
            adp.Fill(dt);
            //DateTime? temp = null; //this is fine
            //var indexOfYourColumn = dt.Columns.IndexOf(dt.Columns[6]);
            foreach (DataRow dr in dt.Rows)
            {
                //temp = dr[indexOfYourColumn] != DBNull.Value ? (DateTime?)null : DateTime.Parse(dr[indexOfYourColumn].ToString());
                mdata.Add(new JobData
                {


                    JobID = Convert.ToInt32(dr["JobID"].ToString()),
                    //JobNumber = Convert.ToInt32(dr["JobNumber"].ToString()),
                    JobNumber = dr["JobNumber"].ToString().PadLeft(8, '0'),
                    ManuscriptTier = dr["ManuscriptTier"].ToString(),
                    BPSProductID = dr["BPSProductID"].ToString(),
                    ServiceNumber = dr["ServiceNumber"].ToString(),
                    TargetPressDate = Convert.ToDateTime(dr["TargetPressDate"].ToString()),

                    ActualPressDate = dr.Field<DateTime?>("ActualPressDate"),
                    //TargetPressDate = DateTime.ParseExact(dr["TargetPressDate"].ToString(), "yyyy/MM/dd hh:mm:ss tt", CultureInfo.InvariantCulture),
                    //ActualPressDate = DateTime.ParseExact(dr["ActualPressDate"].ToString(), "yyyy/MM/dd hh:mm:ss tt", CultureInfo.InvariantCulture),
                    CopyEditStatus = dr["CopyEditStatus"].ToString(),
                    CodingStatus = dr["CodingStatus"].ToString(),
                    OnlineStatus = dr["OnlineStatus"].ToString(),
                    STPStatus = dr["STPStatus"].ToString()

                });
            }
            dbConnection.Close();
            return Json(mdata, JsonRequestBehavior.AllowGet);
        }

        //public ActionResult AddNewManuscript()
        //{
        //    ManuscriptData mdata = new ManuscriptData();
        //    //LastManuscriptID mid = new LastManuscriptID();
        //    //this.ViewBag.Service = new SelectList(mid.GetLastManuscriptID(), "service_id", "service_no");
        //    try
        //    {
        //        TempData["ManuscriptTier"] = new SelectList(GetAllPubschedTier(), "PubSchedTier", "PubSchedTier");
        //        TempData["BPSProductID"] = new SelectList(GetAllPubschedBPSProductID(), "PubschedBPSProductID", "PubschedBPSProductID");
        //        TempData["UpdateType"] = new SelectList(GetAllTurnAroundTime(), "TurnAroundTimeID", "UpdateType");
        //        return PartialView(mdata);
        //    }
        //    catch (Exception ex)
        //    {
        //        ModelState.AddModelError("ErrorMessage", ex.Message);
        //        mdata.ErrorMessage = ex.Message;
        //        return PartialView(mdata);
        //    }
        //}

        //public List<GetPubSchedTier> GetAllPubschedTier()
        //{
        //    DataTable dt = new DataTable();

        //    cmd = new MySqlCommand("GetAllPubschedTier", dbConnection);
        //    cmd.CommandType = CommandType.StoredProcedure;
        //    adp = new MySqlDataAdapter(cmd);
        //    adp.Fill(dt);

        //    if (dbConnection.State == ConnectionState.Closed)
        //        dbConnection.Open();

        //    List<GetPubSchedTier> lst = new List<GetPubSchedTier>();
        //    foreach (DataRow dr in dt.Rows)
        //    {
        //        lst.Add(new GetPubSchedTier
        //        {
        //            PubSchedTier = Convert.ToString(dr[0])

        //        });
        //    }
        //    return lst;
        //}
        //public List<GetPubschedBPSProductID> GetAllPubschedBPSProductID()
        //{
        //    DataTable dt = new DataTable();

        //    cmd = new MySqlCommand("GetAllPubschedBPSProductID", dbConnection);
        //    cmd.CommandType = CommandType.StoredProcedure;
        //    adp = new MySqlDataAdapter(cmd);
        //    adp.Fill(dt);

        //    if (dbConnection.State == ConnectionState.Closed)
        //        dbConnection.Open();

        //    List<GetPubschedBPSProductID> lst = new List<GetPubschedBPSProductID>();
        //    foreach (DataRow dr in dt.Rows)
        //    {
        //        lst.Add(new GetPubschedBPSProductID
        //        {
        //            PubschedBPSProductID = Convert.ToString(dr[0])

        //        });
        //    }
        //    return lst;
        //}

        //public List<GetAllTurnAroundTime> GetAllTurnAroundTime()
        //{
        //    DataTable dt = new DataTable();

        //    cmd = new MySqlCommand("GetAllTurnAroundTime", dbConnection);
        //    cmd.CommandType = CommandType.StoredProcedure;
        //    adp = new MySqlDataAdapter(cmd);
        //    adp.Fill(dt);

        //    if (dbConnection.State == ConnectionState.Closed)
        //        dbConnection.Open();

        //    List<GetAllTurnAroundTime> lst = new List<GetAllTurnAroundTime>();
        //    foreach (DataRow dr in dt.Rows)
        //    {
        //        lst.Add(new GetAllTurnAroundTime
        //        {
        //            TurnAroundTimeID = Convert.ToInt32(dr[0]),
        //            UpdateType = Convert.ToString(dr[1]),
        //            TaskType = Convert.ToString(dr[2]),
        //            TATCopyEdit = Convert.ToInt32(dr[3]),
        //            TATCoding = Convert.ToInt32(dr[4]),
        //            TATOnline = Convert.ToInt32(dr[5]),
        //            TATPDFQA = Convert.ToInt32(dr[6]),
        //            BenchMarkDays = Convert.ToInt32(dr[7]),
        //        });
        //    }
        //    return lst;
        //}
        //public ActionResult GetTaskType(int selectedItem)
        //{
        //    var data = GetAllTurnAroundTime().Where(model => model.TurnAroundTimeID == selectedItem).FirstOrDefault();

        //    return Json(data.TaskType, JsonRequestBehavior.AllowGet);
        //}
        //public ActionResult GetTATCopyEdit(int selectedItem)
        //{
        //    var data = GetAllTurnAroundTime().Where(model => model.TurnAroundTimeID == selectedItem).FirstOrDefault();
        //    DateTime d = DateTime.Now.AddDays(data.TATCopyEdit);
        //    return Json(d.ToString("yyyy-MM-dd"), JsonRequestBehavior.AllowGet);
        //}
        //public ActionResult GetTATCoding(int selectedItem)
        //{
        //    var data = GetAllTurnAroundTime().Where(model => model.TurnAroundTimeID == selectedItem).FirstOrDefault();
        //    DateTime d = DateTime.Now.AddDays(data.TATCoding);
        //    return Json(d.ToString("yyyy-MM-dd"), JsonRequestBehavior.AllowGet);
        //}
        //public ActionResult GetTATOnline(int selectedItem)
        //{
        //    var data = GetAllTurnAroundTime().Where(model => model.TurnAroundTimeID == selectedItem).FirstOrDefault();
        //    DateTime d = DateTime.Now.AddDays(data.TATOnline);
        //    return Json(d.ToString("yyyy-MM-dd"), JsonRequestBehavior.AllowGet);
        //}
        //public ActionResult GetJobData(int countryId)
        //{
        //    //logic to find country code goes here
        //    string countryCode = "1";
        //    return Content(countryCode);
        //}

        //[HttpPost]
        //public JsonResult AddNewManuscript(ManuscriptData mdata)
        //{
        //    try
        //    {
        //        if (ModelState.IsValid)
        //        {
        //            var Username = Session["Username"];
        //            MySqlCommand com = new MySqlCommand("InsertManuscript", dbConnection);
        //            com.CommandType = CommandType.StoredProcedure;
        //            com.Parameters.AddWithValue("@p_Username", Username);
        //            com.Parameters.AddWithValue("@p_JobNumber", mdata.JobNumber);
        //            com.Parameters.AddWithValue("@p_ManuscriptTier", mdata.ManuscriptTier);
        //            com.Parameters.AddWithValue("@p_BPSProductID", mdata.BPSProductID);
        //            com.Parameters.AddWithValue("@p_ServiceNumber", mdata.ServiceNumber);
        //            com.Parameters.AddWithValue("@p_ManuscriptLegTitle", mdata.ManuscriptLegTitle);
        //            com.Parameters.AddWithValue("@p_TargetPressDate", mdata.TargetPressDate);
        //            //com.Parameters.AddWithValue("@p_ActualPressDate", mdata.ActualPressDate);
        //            com.Parameters.AddWithValue("@p_LatupAttribution", mdata.LatupAttribution);
        //            com.Parameters.AddWithValue("@p_DateReceivedFromAuthor", mdata.DateReceivedFromAuthor);
        //            com.Parameters.AddWithValue("@p_UpdateType", mdata.UpdateType);
        //            com.Parameters.AddWithValue("@p_JobSpecificInstruction", mdata.JobSpecificInstruction);
        //            com.Parameters.AddWithValue("@p_TaskType", mdata.TaskType);
        //            com.Parameters.AddWithValue("@p_CopyEditDueDate", mdata.CopyEditDueDate);
        //            //com.Parameters.AddWithValue("@p_CopyEditStatus", mdata.CopyEditStatus);
        //            com.Parameters.AddWithValue("@p_CodingDueDate", mdata.CodingDueDate);
        //            com.Parameters.AddWithValue("@p_OnlineDueDate", mdata.OnlineDueDate);
        //            com.Parameters.AddWithValue("@p_STPStatus", mdata.STPStatus);
        //            dbConnection.Open();
        //            int Count = com.ExecuteNonQuery();


        //            //return Json(new { success = true, responseText = "registration successful" }, JsonRequestBehavior.AllowGet);

        //            if (Count > 0)
        //                mdata.Response = "Y";
        //            else
        //            {
        //                mdata.Response = "N";
        //                mdata.ErrorMessage = "User could not be added";
        //            }
        //        }
        //        else
        //        {
        //            foreach (var Key in ModelState.Keys)
        //            {
        //                if (ModelState[Key].Errors.Count > 0)
        //                {
        //                    mdata.Response = "N";
        //                    mdata.ErrorMessage = ModelState[Key].Errors[0].ErrorMessage;

        //                    //return Json(new { success = false, responseText = "registration failed, please check", JsonRequestBehavior.AllowGet);
        //                }
        //            }
        //        }
        //    }
        //    catch (Exception ex)
        //    {
        //        ModelState.AddModelError("ErrorMessage", ex.Message);
        //        ViewBag.ErrorMessage = ex.Message;
        //        mdata.Response = "N";
        //        mdata.ErrorMessage = "Error : " + ex.Message;
        //    }
        //    finally
        //    {
        //        dbConnection.Close();
        //    }
        //    return Json(mdata, JsonRequestBehavior.AllowGet);
        //}
        //public ActionResult EditManuscript(int ManuscriptID)
        //{
        //    ManuscriptData mdata = new ManuscriptData();
        //    try
        //    {
        //        TempData["ManuscriptTier"] = new SelectList(GetAllPubschedTier(), "PubSchedTier", "PubSchedTier");
        //        TempData["BPSProductID"] = new SelectList(GetAllPubschedBPSProductID(), "PubschedBPSProductID", "PubschedBPSProductID");
        //        TempData["UpdateType"] = new SelectList(GetAllTurnAroundTime(), "TurnAroundTimeID", "UpdateType");
        //        DataTable dt = new DataTable();

        //        cmd = new MySqlCommand("GetManuscriptByID", dbConnection);
        //        cmd.CommandType = CommandType.StoredProcedure;

        //        cmd.Parameters.Clear();
        //        cmd.Parameters.AddWithValue("@p_ManuscriptID", ManuscriptID);
        //        adp = new MySqlDataAdapter(cmd);
        //        adp.Fill(dt);

        //        foreach (DataRow dr in dt.Rows)
        //        {

        //            mdata.ManuscriptID = Convert.ToInt32(dr["ManuscriptID"].ToString());
        //            mdata.JobNumber = dr["JobNumber"].ToString();
        //            //mdata.ManuscriptTier = dr["ManuscriptTier"].ToString();
        //            mdata.ManuscriptTier = dr["ManuscriptTier"].ToString();
        //            mdata.BPSProductID = dr["BPSProductID"].ToString();
        //            mdata.ServiceNumber = dr["ServiceNumber"].ToString();
        //            mdata.ManuscriptLegTitle = dr["ManuscriptLegTitle"].ToString();
        //            mdata.TargetPressDate = Convert.ToDateTime(dr["TargetPressDate"].ToString());
        //            mdata.ActualPressDate = Convert.ToDateTime(dr["ActualPressDate"].ToString());
        //            mdata.LatupAttribution = dr["LatupAttribution"].ToString();
        //            //mdata.DateReceivedFromAuthor = Convert.ToDateTime(dr["DateReceivedFromAuthor"].ToString());
        //            mdata.UpdateType = dr["UpdateType"].ToString();
        //            mdata.JobSpecificInstruction = dr["JobSpecificInstruction"].ToString();
        //            mdata.TaskType = dr["TaskType"].ToString();
        //            mdata.CopyEditDueDate = Convert.ToDateTime(dr["CopyEditDueDate"].ToString());
        //            mdata.CodingDueDate = Convert.ToDateTime(dr["CodingDueDate"].ToString());
        //            mdata.OnlineDueDate = Convert.ToDateTime(dr["OnlineDueDate"].ToString());
        //            mdata.STPStatus = dr["STPStatus"].ToString();

        //        }
        //        return PartialView(mdata);
        //    }



        //    catch (Exception ex)
        //    {
        //        ModelState.AddModelError("ErrorMessage", ex.Message);
        //        mdata.ErrorMessage = ex.Message;
        //        return PartialView(mdata);
        //    }
        //}
        //[HttpPost]
        //public JsonResult EditManuscript(ManuscriptData mdata)
        //{
        //    try
        //    {
        //        if (ModelState.IsValid)
        //        {
        //            var Username = Session["Username"];
        //            MySqlCommand com = new MySqlCommand("UpdateManuscript", dbConnection);
        //            com.CommandType = CommandType.StoredProcedure;
        //            com.Parameters.AddWithValue("@p_Username", Username);
        //            com.Parameters.AddWithValue("@p_JobNumber", mdata.JobNumber);
        //            com.Parameters.AddWithValue("@p_ManuscriptTier", mdata.ManuscriptTier);
        //            com.Parameters.AddWithValue("@p_BPSProductID", mdata.BPSProductID);
        //            com.Parameters.AddWithValue("@p_ServiceNumber", mdata.ServiceNumber);
        //            com.Parameters.AddWithValue("@p_ManuscriptLegTitle", mdata.ManuscriptLegTitle);
        //            com.Parameters.AddWithValue("@p_TargetPressDate", mdata.TargetPressDate);
        //            com.Parameters.AddWithValue("@p_ActualPressDate", mdata.ActualPressDate);
        //            com.Parameters.AddWithValue("@p_LatupAttribution", mdata.LatupAttribution);
        //            com.Parameters.AddWithValue("@p_DateReceivedFromAuthor", mdata.DateReceivedFromAuthor);
        //            com.Parameters.AddWithValue("@p_UpdateType", mdata.UpdateType);
        //            com.Parameters.AddWithValue("@p_JobSpecificInstruction", mdata.JobSpecificInstruction);
        //            com.Parameters.AddWithValue("@p_TaskType", mdata.TaskType);
        //            com.Parameters.AddWithValue("@p_CopyEditDueDate", mdata.CopyEditDueDate);
        //            //com.Parameters.AddWithValue("@p_CopyEditStatus", mdata.CopyEditStatus);
        //            com.Parameters.AddWithValue("@p_CodingDueDate", mdata.CodingDueDate);
        //            com.Parameters.AddWithValue("@p_OnlineDueDate", mdata.OnlineDueDate);

        //            dbConnection.Open();
        //            int Count = com.ExecuteNonQuery();


        //            //return Json(new { success = true, responseText = "registration successful" }, JsonRequestBehavior.AllowGet);

        //            if (Count > 0)
        //                mdata.Response = "Y";
        //            else
        //            {
        //                mdata.Response = "N";
        //                mdata.ErrorMessage = "Manuscript could not be updated";
        //            }
        //        }
        //        else
        //        {
        //            foreach (var Key in ModelState.Keys)
        //            {
        //                if (ModelState[Key].Errors.Count > 0)
        //                {
        //                    mdata.Response = "N";
        //                    mdata.ErrorMessage = ModelState[Key].Errors[0].ErrorMessage;

        //                    //return Json(new { success = false, responseText = "registration failed, please check", JsonRequestBehavior.AllowGet);
        //                }
        //            }
        //        }
        //    }
        //    catch (Exception ex)
        //    {
        //        ModelState.AddModelError("ErrorMessage", ex.Message);
        //        ViewBag.ErrorMessage = ex.Message;
        //        mdata.Response = "N";
        //        mdata.ErrorMessage = "Error : " + ex.Message;
        //    }
        //    finally
        //    {
        //        dbConnection.Close();
        //    }
        //    return Json(mdata, JsonRequestBehavior.AllowGet);
        //}

        //public ActionResult ViewCoversheet(string BPSProductID, string ServiceNumber)
        //{

        //    List<CoversheetData> mdata = new List<CoversheetData>();
        //    DataTable dt = new DataTable();

        //    cmd = new MySqlCommand("GetCoversheetByProductIDServiceNumber", dbConnection);
        //    cmd.CommandType = CommandType.StoredProcedure;
        //    cmd.Parameters.Clear();
        //    cmd.Parameters.AddWithValue("@p_BPSProductID", BPSProductID);
        //    cmd.Parameters.AddWithValue("@p_ServiceNumber", ServiceNumber);
        //    adp = new MySqlDataAdapter(cmd);
        //    adp.Fill(dt);

        //    foreach (DataRow dr in dt.Rows)
        //    {
        //        mdata.Add(new CoversheetData
        //        {


        //            CoversheetID = Convert.ToInt32(dr["CoversheetID"].ToString()),
        //            CoversheetTier = dr["CoversheetTier"].ToString(),
        //            CoversheetName = dr["CoversheetName"].ToString(),
        //            BPSProductID = dr["BPSProductID"].ToString(),
        //            ServiceNumber = dr["ServiceNumber"].ToString(),
        //            ManuscriptFile = dr["ManuscriptFile"].ToString(),
        //            LatupAttribution = dr["LatupAttribution"].ToString(),
        //            DateReceivedFromAuthor = Convert.ToDateTime(dr["DateReceivedFromAuthor"].ToString()),
        //            DateEnteredIntoTracker = Convert.ToDateTime(dr["DateEnteredIntoTracker"].ToString()),
        //            UpdateType = dr["UpdateType"].ToString(),
        //            GuideCard = dr["GuideCard"].ToString(),
        //            TaskNumber = dr["TaskNumber"].ToString(),
        //            RevisedOnlineDueDate = Convert.ToDateTime(dr["RevisedOnlineDueDate"].ToString()),
        //            DepositedBy = dr["DepositedBy"].ToString(),
        //            LEInstructions = dr["LEInstructions"].ToString(),
        //            PickUpBy = dr["PickUpBy"].ToString(),
        //            PickUpDate = dr["PickUpDate"].ToString(),
        //            QABy = dr["QABy"].ToString(),
        //            QADate = Convert.ToDateTime(dr["QADate"].ToString()),
        //            QACompletionDate = dr["QACompletionDate"].ToString(),
        //            QueryLog = dr["QueryLog"].ToString(),
        //            QueryForApprovalStartDate = dr["QueryForApprovalStartDate"].ToString(),
        //            QueryForApprovalEndDate = dr["QueryForApprovalEndDate"].ToString(),
        //            QueryForApprovalAge = Convert.ToInt32(dr["QueryForApprovalAge"].ToString()),
        //            Process = dr["Process"].ToString(),
        //            PETargetCompletion = Convert.ToDateTime(dr["PETargetCompletion"].ToString()),
        //            LatupTargetCompletion = Convert.ToDateTime(dr["LatupTargetCompletion"].ToString()),
        //            EndingDueDate = Convert.ToDateTime(dr["EndingDueDate"].ToString()),
        //            PEActualCompletion = Convert.ToDateTime(dr["PEActualCompletion"].ToString()),
        //            CodingDueDate = Convert.ToDateTime(dr["CodingDueDate"].ToString()),
        //            CodingActualCompletion = Convert.ToDateTime(dr["CodingActualCompletion"].ToString()),
        //            ActualPages = Convert.ToInt32(dr["ActualPages"].ToString()),
        //            OnlineDueDate = Convert.ToDateTime(dr["OnlineDueDate"].ToString()),
        //            OnlineActualCompletion = Convert.ToDateTime(dr["OnlineActualCompletion"].ToString()),
        //            LNRedCheckingActualCompletion = Convert.ToDateTime(dr["LNRedCheckingActualCompletion"].ToString()),
        //            AffectedPages = Convert.ToInt32(dr["AffectedPages"].ToString()),
        //            NoOfMSSFile = Convert.ToInt32(dr["NoOfMSSFile"].ToString()),
        //            ActualTAT = Convert.ToInt32(dr["ActualTAT"].ToString()),
        //            BenchmarkMET = dr["BenchmarkMET"].ToString(),
        //            FilePath = dr["FilePath"].ToString(),
        //            PEStatus = dr["PEStatus"].ToString(),
        //            TaskType = dr["TaskType"].ToString(),
        //            TaskReadyDate = Convert.ToDateTime(dr["TaskReadyDate"].ToString()),
        //            PDFQA_PE = dr["PDFQA_PE"].ToString(),
        //            QMSID = Convert.ToInt32(dr["QMSID"].ToString()),
        //            CodingStatus = dr["CodingStatus"].ToString(),
        //            CoversheetRemarks = dr["CoversheetRemarks"].ToString()


        //        });
        //    }
        //    return View(mdata);
        //}
    }


}