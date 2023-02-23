using System;
using System.Linq;
using System.Linq.Dynamic;
using System.Web.Mvc;
using System.Collections.Generic;
using JobTrack.Models.Coversheet;
using System.Configuration;
using System.Data;
using MySql.Data.MySqlClient;
using System.Net.Mail;
using JobTrack.Models.Manuscript;

namespace JobTrack.Controllers
{
    public class JobCoversheetController : Controller
    {
        // CONNECTION STRING
        public MySqlConnection dbConnection = new MySqlConnection(ConfigurationManager.ConnectionStrings["SQLConn"].ConnectionString);
        public MySqlCommand cmd = new MySqlCommand();
        public MySqlDataAdapter adp = new MySqlDataAdapter();

        public ActionResult GetJobCoversheetData()
        {
            if (dbConnection.State == ConnectionState.Closed)
                dbConnection.Open();

            List<CoversheetData> mdata = new List<CoversheetData>();
            DataTable dt = new DataTable();

            cmd = new MySqlCommand("GetAllJobCoversheetData", dbConnection);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Clear();
            adp = new MySqlDataAdapter(cmd);
            adp.Fill(dt);

            foreach (DataRow dr in dt.Rows)
            {
                mdata.Add(new CoversheetData
                {

                    //JobCoversheetID = Convert.ToInt32(dr["JobCoversheetID"].ToString()),
                    CoversheetTier = dr["CoversheetTier"].ToString(),
                    BPSProductID = dr["BPSProductID"].ToString(),
                    ServiceNumber = dr["ServiceNumber"].ToString(),
                    LatestTaskNumber = dr["LatestTaskNumber"].ToString(),
                    CodingStatus = dr["CodingStatus"].ToString(),
                    PDFQAStatus = dr["PDFQAStatus"].ToString(),
                    OnlineStatus = dr["OnlineStatus"].ToString(),
                    DateCreated = Convert.ToDateTime(dr["DateCreated"].ToString())

                });
            }
            dbConnection.Close();
            return Json(mdata, JsonRequestBehavior.AllowGet);
        }
        public ActionResult GetJobCoversheetDataByUserNamePE()
        {
            var Username = Session["UserName"];
            if (dbConnection.State == ConnectionState.Closed)
                dbConnection.Open();

            List<CoversheetData> mdata = new List<CoversheetData>();
            DataTable dt = new DataTable();

            cmd = new MySqlCommand("GetAllJobCoversheetDataByUserNamePE", dbConnection);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@p_Username", Username);
            adp = new MySqlDataAdapter(cmd);
            adp.Fill(dt);
            foreach (DataRow dr in dt.Rows)
            {
                mdata.Add(new CoversheetData
                {

                    JobCoversheetID = Convert.ToInt32(dr["JobCoversheetID"].ToString()),
                    CoversheetTier = dr["CoversheetTier"].ToString(),
                    BPSProductID = dr["BPSProductID"].ToString(),
                    ServiceNumber = dr["ServiceNumber"].ToString(),
                    LatestTaskNumber = dr["LatestTaskNumber"].ToString(),
                    CodingStatus = dr["CodingStatus"].ToString(),
                    PDFQAStatus = dr["PDFQAStatus"].ToString(),
                    OnlineStatus = dr["OnlineStatus"].ToString(),
                    DateCreated = Convert.ToDateTime(dr["DateCreated"].ToString())

                });
            }
            dbConnection.Close();
            return Json(mdata, JsonRequestBehavior.AllowGet);
        }
        [HttpGet]
        public ActionResult AddNewJobCoversheet(string manuscriptids, string bpsproductid, string serviceno)
        {
            CoversheetData mdata = new CoversheetData();
            try
            {

                Session["ManuscriptIDs"] = manuscriptids.ToString();

                var resultpubsched = GetPubSchedData(bpsproductid, serviceno);
                var resultmanuscript = GetManuscriptData(bpsproductid, serviceno, manuscriptids);
                var resultmanuscriptdatecreated = ManuscriptDataDateCreated(bpsproductid, serviceno, manuscriptids);
                TempData["UpdateTypes"] = new SelectList(GetAllTurnAroundTime(), "UpdateType", "UpdateType", resultmanuscript.UpdateType);
                var resultcover = GetJobCoversheetData1(bpsproductid, serviceno);

                mdata.BPSProductID = resultpubsched.BPSProductID;
                mdata.ServiceNumber = resultpubsched.ServiceNumber;
                mdata.IsXMLEditing = true;
                mdata.IsOnline = true;
                mdata.Editor = resultpubsched.Editor;
                mdata.ChargeCode = resultpubsched.ChargeCode;

                mdata.CoversheetTier = resultmanuscript.ManuscriptTier;
                mdata.TargetPressDate = resultmanuscript.TargetPressDate;

                mdata.TaskType = resultmanuscript.TaskType;
                mdata.CodingDueDate = resultmanuscript.CodingDueDate;
                mdata.OnlineDueDate = resultmanuscript.OnlineDueDate;

                mdata.GuideCard = resultmanuscript.PEGuideCard;
                //latest
                mdata.DateCreated = resultmanuscriptdatecreated.DateCreated;

                //tasknumber counter
                int val = 0;
                if
                (resultcover == null)
                {
                    mdata.TaskNumber = "Task1";
                }
                else
                {
                    mdata.TaskNumber = resultcover.TaskNumber;
                    val = Convert.ToInt32(mdata.TaskNumber);
                    val++;
                    mdata.TaskNumber = "Task" + Convert.ToString(val);
                }


                mdata.CoversheetNumber = bpsproductid + '_' + serviceno + '_' + mdata.TaskNumber;

                return PartialView(mdata);
            }
            catch (Exception ex)
            {
                ModelState.AddModelError("ErrorMessage", ex.Message);
                mdata.ErrorMessage = ex.Message;
                return PartialView(mdata);
            }
        }

        public CoversheetData GetPubSchedData(string prodid, string serno)
        {
            try
            {
                var pubsched = GetSpecificPubSchedData(prodid, serno).FirstOrDefault();
                return pubsched;
            }
            catch (Exception)
            {

                throw;
            }
        }
        public ManuscriptData GetManuscriptData(string prodid, string serno, string manuscriptids)
        {
            try
            {
                var manuscript = GetManuscriptDataMaxTurnAroundTime(prodid, serno, manuscriptids).FirstOrDefault();

                return manuscript;
            }
            catch (Exception)
            {

                throw;
            }
        }
        public ManuscriptData ManuscriptDataDateCreated(string prodid, string serno, string manuscriptids)
        {
            try
            {
                var manuscript = GetManuscriptDataDateCreated(prodid, serno, manuscriptids).FirstOrDefault();

                return manuscript;
            }
            catch (Exception)
            {

                throw;
            }
        }
        public CoversheetData GetJobCoversheetData1(string prodid, string serno)
        {
            try
            {
                var cover = GetCoversheetDetails().OrderByDescending(model => model.CoversheetID).FirstOrDefault(model => model.BPSProductID == prodid && model.ServiceNumber == serno);
                return cover;
            }
            catch (Exception)
            {

                throw;
            }
        }

        public List<CoversheetData> GetSpecificPubSchedData(string product, string servicenumber)
        {

            List<CoversheetData> mdata = new List<CoversheetData>();
            DataTable dt = new DataTable();

            cmd = new MySqlCommand("GetSpecificPubSchedData", dbConnection);
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@p_BPSProductID", product);
            cmd.Parameters.AddWithValue("@p_ServiceNumber", servicenumber);
            cmd.CommandType = CommandType.StoredProcedure;
            adp = new MySqlDataAdapter(cmd);
            adp.Fill(dt);

            if (dbConnection.State == ConnectionState.Closed)
                dbConnection.Open();

            foreach (DataRow dr in dt.Rows)
            {
                mdata.Add(new CoversheetData
                {
                    BPSProductID = Convert.ToString(dr[0]),
                    ServiceNumber = Convert.ToString(dr[1]),
                    Editor = Convert.ToString(dr[2]),
                    ChargeCode = Convert.ToString(dr[3])
                });
            }
            return mdata;
        }

        public List<ManuscriptData> GetManuscriptDataMaxTurnAroundTime(string product, string servicenumber, string manuscriptids)
        {

            List<ManuscriptData> mdata = new List<ManuscriptData>();
            DataTable dt = new DataTable();

            if (dbConnection.State == ConnectionState.Closed)
                dbConnection.Open();

            cmd = new MySqlCommand("GetManuscriptDataMaxTurnAroundTime", dbConnection);
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@p_BPSProductID", product);
            cmd.Parameters.AddWithValue("@p_ServiceNumber", servicenumber);
            cmd.Parameters.AddWithValue("@p_manuscriptids", manuscriptids);
            cmd.CommandType = CommandType.StoredProcedure;
            adp = new MySqlDataAdapter(cmd);
            adp.Fill(dt);


            foreach (DataRow dr in dt.Rows)
            {
                mdata.Add(new ManuscriptData
                {
                    ManuscriptID = Convert.ToInt32(dr[0]),
                    ManuscriptTier = Convert.ToString(dr[1]),
                    BPSProductID = Convert.ToString(dr[2]),
                    ServiceNumber = Convert.ToString(dr[3]),
                    TargetPressDate = Convert.ToDateTime(dr[4]),
                    UpdateType = Convert.ToString(dr[5]),
                    TaskType = Convert.ToString(dr[6]),
                    PEGuideCard = Convert.ToString(dr[7]),
                    CodingDueDate = Convert.ToDateTime(dr[8]),
                    OnlineDueDate = Convert.ToDateTime(dr[9]),
                    //6-15
                    DateCreated = Convert.ToDateTime(dr[10])
                });
            }
            return mdata;
        }
        public List<ManuscriptData> GetManuscriptDataDateCreated(string product, string servicenumber, string manuscriptids)
        {

            List<ManuscriptData> mdata = new List<ManuscriptData>();
            DataTable dt = new DataTable();

            if (dbConnection.State == ConnectionState.Closed)
                dbConnection.Open();

            cmd = new MySqlCommand("GetManuscriptDataDateCreated", dbConnection);
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@p_BPSProductID", product);
            cmd.Parameters.AddWithValue("@p_ServiceNumber", servicenumber);
            cmd.Parameters.AddWithValue("@p_manuscriptids", manuscriptids);
            cmd.CommandType = CommandType.StoredProcedure;
            adp = new MySqlDataAdapter(cmd);
            adp.Fill(dt);


            foreach (DataRow dr in dt.Rows)
            {
                mdata.Add(new ManuscriptData
                {
                    DateCreated = Convert.ToDateTime(dr[0])
                });
            }
            return mdata;
        }
        public List<CoversheetData> GetCoversheetDetails()
        {

            List<CoversheetData> mdata = new List<CoversheetData>();
            DataTable dt = new DataTable();

            cmd = new MySqlCommand("GetAllCoversheetData", dbConnection);
            cmd.CommandType = CommandType.StoredProcedure;
            adp = new MySqlDataAdapter(cmd);
            adp.Fill(dt);

            if (dbConnection.State == ConnectionState.Closed)
                dbConnection.Open();

            foreach (DataRow dr in dt.Rows)
            {
                mdata.Add(new CoversheetData
                {
                    CoversheetID = Convert.ToInt32(dr[0]),
                    BPSProductID = Convert.ToString(dr[2]),
                    ServiceNumber = Convert.ToString(dr[3]),
                    TaskNumber = Convert.ToString(dr[4])
                });
            }
            return mdata;
        }

        public List<Models.Manuscript.GetAllTurnAroundTime> GetAllTurnAroundTime()
        {
            DataTable dt = new DataTable();

            cmd = new MySqlCommand("GetAllTurnAroundTime", dbConnection);
            cmd.CommandType = CommandType.StoredProcedure;
            adp = new MySqlDataAdapter(cmd);
            adp.Fill(dt);

            if (dbConnection.State == ConnectionState.Closed)
                dbConnection.Open();

            List<Models.Manuscript.GetAllTurnAroundTime> lst = new List<Models.Manuscript.GetAllTurnAroundTime>();
            foreach (DataRow dr in dt.Rows)
            {
                lst.Add(new Models.Manuscript.GetAllTurnAroundTime
                {
                    TurnAroundTimeID = Convert.ToInt32(dr[0]),
                    UpdateType = Convert.ToString(dr[1]),
                    TaskType = Convert.ToString(dr[2]),
                    TATCopyEdit = Convert.ToInt32(dr[3]),
                    TATCoding = Convert.ToInt32(dr[4]),
                    TATOnline = Convert.ToInt32(dr[6]),
                    BenchMarkDays = Convert.ToInt32(dr[7]),
                });
            }
            return lst;
        }
        public ActionResult GetTaskType(string selectedItem)
        {
            var data = GetAllTurnAroundTime().Where(model => model.UpdateType == selectedItem).FirstOrDefault();

            return Json(data.TaskType, JsonRequestBehavior.AllowGet);
        }
        public ActionResult GetTATCoding(string selectedItem, DateTime datecreated)
        {
            var data = GetAllTurnAroundTime().Where(model => model.UpdateType == selectedItem).FirstOrDefault();
            DateTime d = AddBusinessDays(datecreated, data.TATCoding);
            return Json(d.ToString("d-MMM-yy"), JsonRequestBehavior.AllowGet);
        }
        public ActionResult GetTATOnline(string selectedItem, DateTime datecreated)
        {
            var data = GetAllTurnAroundTime().Where(model => model.UpdateType == selectedItem).FirstOrDefault();
            DateTime d = AddBusinessDays(datecreated, data.TATOnline);
            return Json(d.ToString("d-MMM-yy"), JsonRequestBehavior.AllowGet);
        }
        public static DateTime AddBusinessDays(DateTime date, int days)
        {
            if (days < 0)
            {
                throw new ArgumentException("days cannot be negative", "days");
            }

            if (days == 0) return date;

            if (date.DayOfWeek == DayOfWeek.Saturday)
            {
                date = date.AddDays(2);
                days -= 1;
            }
            else if (date.DayOfWeek == DayOfWeek.Sunday)
            {
                date = date.AddDays(1);
                days -= 1;
            }

            date = date.AddDays(days / 5 * 7);
            int extraDays = days % 5;

            if ((int)date.DayOfWeek + extraDays > 5)
            {
                extraDays += 2;
            }

            return date.AddDays(extraDays);

        }
        [HttpPost]
        public JsonResult AddNewJobCoversheet(CoversheetData mdata)
        {
            try
            {
                if (ModelState.IsValid)
                {

                    if (!string.IsNullOrEmpty(mdata.BPSProductID) && !string.IsNullOrEmpty(mdata.ServiceNumber))
                    {
                        var result = IsJobExists(mdata.BPSProductID, mdata.ServiceNumber);
                        if (result != null)
                        {
                            //if jobcoversheet exist
                            if (result.JobCoversheetID == 0 || result.JobCoversheetID < 0)
                            {
                                mdata.Response = "N";
                                mdata.ErrorMessage = "Entered invalid Product or Service Number";
                            }
                            else
                            {
                                ////if multiple manuscript
                                string Manus = Session["ManuscriptIDs"].ToString();
                                var Username = Session["UserName"];
                                string Combi = mdata.CoversheetNumber + "_" + mdata.GuideCard;
                                MySqlCommand com = new MySqlCommand("InsertCoversheet", dbConnection);
                                com.CommandType = CommandType.StoredProcedure;
                                com.Parameters.AddWithValue("@p_Username", Username);
                                com.Parameters.AddWithValue("@p_ManuscriptID", Manus);
                                com.Parameters.AddWithValue("@p_CoversheetNumber", Combi);
                                com.Parameters.AddWithValue("@p_BPSProductID", mdata.BPSProductID);
                                com.Parameters.AddWithValue("@p_ServiceNumber", mdata.ServiceNumber);
                                com.Parameters.AddWithValue("@p_TaskNumber", mdata.TaskNumber);
                                com.Parameters.AddWithValue("@p_CoversheetTier", mdata.CoversheetTier);
                                com.Parameters.AddWithValue("@p_Editor", mdata.Editor);
                                com.Parameters.AddWithValue("@p_ChargeCode", mdata.ChargeCode);
                                com.Parameters.AddWithValue("@p_TargetPressDate", mdata.TargetPressDate);
                                com.Parameters.AddWithValue("@p_TaskType", mdata.TaskType);
                                com.Parameters.AddWithValue("@p_GuideCard", mdata.GuideCard);
                                com.Parameters.AddWithValue("@p_LocationOfManuscript", mdata.LocationOfManuscript);
                                com.Parameters.AddWithValue("@p_UpdateType", mdata.UpdateType);

                                com.Parameters.AddWithValue("@p_GeneralLegRefCheck", mdata.GeneralLegRefCheck);
                                com.Parameters.AddWithValue("@p_GeneralTOC", mdata.GeneralTOC);
                                com.Parameters.AddWithValue("@p_GeneralTOS", mdata.GeneralTOS);
                                com.Parameters.AddWithValue("@p_GeneralReprints", mdata.GeneralReprints);
                                com.Parameters.AddWithValue("@p_GeneralFascicleInsertion", mdata.GeneralFascicleInsertion);
                                com.Parameters.AddWithValue("@p_GeneralGraphicLink", mdata.GeneralGraphicLink);
                                com.Parameters.AddWithValue("@p_GeneralGraphicEmbed", mdata.GeneralGraphicEmbed);
                                com.Parameters.AddWithValue("@p_GeneralHandtooling", mdata.GeneralHandtooling);
                                com.Parameters.AddWithValue("@p_GeneralNonContent", mdata.GeneralNonContent);
                                com.Parameters.AddWithValue("@p_GeneralSamplePages", mdata.GeneralSamplePages);
                                com.Parameters.AddWithValue("@p_GeneralComplexTask", mdata.GeneralComplexTask);

                                com.Parameters.AddWithValue("@p_FurtherInstruction", mdata.FurtherInstruction);
                                com.Parameters.AddWithValue("@p_CodingDueDate", mdata.CodingDueDate);

                                com.Parameters.AddWithValue("@p_IsXMLEditing", mdata.IsXMLEditing);
                                com.Parameters.AddWithValue("@p_OnlineDueDate", mdata.OnlineDueDate);
                                com.Parameters.AddWithValue("@p_IsOnline", mdata.IsOnline);

                                //if (mdata.OnlineDueDate >= DateTime.Now)
                                //{
                                //    mdata.OnlineTimeliness = "On Time";
                                //    com.Parameters.AddWithValue("@p_OnlineTimeliness", mdata.OnlineTimeliness);
                                //}
                                //else
                                //{
                                //    mdata.OnlineTimeliness = "Late";
                                //    com.Parameters.AddWithValue("@p_OnlineTimeliness", mdata.OnlineTimeliness);
                                //}
                                if (dbConnection.State == ConnectionState.Closed)
                                    dbConnection.Open();
                                int Counto = com.ExecuteNonQuery();
                                com.Parameters.Clear();
                                if (Counto > 0)
                                {
                                    mdata.Response = "Y";
                                    SendNewCoversheetEmail(mdata);
                                }
                                else
                                {
                                    mdata.Response = "N";
                                    mdata.ErrorMessage = "Coversheet data could not be added";
                                }
                            }
                        }
                        else
                        //if jobcoversheet does not exist
                        {
                            //if multiple manuscript
                            string Manus = Session["ManuscriptIDs"].ToString();
                            var Username = Session["UserName"];
                            string Combi = mdata.CoversheetNumber + "_" + mdata.GuideCard;
                            MySqlCommand com = new MySqlCommand("InsertJobCoversheet", dbConnection);
                            com.CommandType = CommandType.StoredProcedure;
                            com.Parameters.AddWithValue("@p_Username", Username);
                            com.Parameters.AddWithValue("@p_ManuscriptID", Manus);
                            com.Parameters.AddWithValue("@p_CoversheetNumber", Combi);
                            com.Parameters.AddWithValue("@p_BPSProductID", mdata.BPSProductID);
                            com.Parameters.AddWithValue("@p_ServiceNumber", mdata.ServiceNumber);
                            com.Parameters.AddWithValue("@p_TaskNumber", mdata.TaskNumber);
                            com.Parameters.AddWithValue("@p_CoversheetTier", mdata.CoversheetTier);
                            com.Parameters.AddWithValue("@p_Editor", mdata.Editor);
                            com.Parameters.AddWithValue("@p_ChargeCode", mdata.ChargeCode);
                            com.Parameters.AddWithValue("@p_TargetPressDate", mdata.TargetPressDate);
                            com.Parameters.AddWithValue("@p_TaskType", mdata.TaskType);
                            com.Parameters.AddWithValue("@p_GuideCard", mdata.GuideCard);
                            com.Parameters.AddWithValue("@p_LocationOfManuscript", mdata.LocationOfManuscript);
                            com.Parameters.AddWithValue("@p_UpdateType", mdata.UpdateType);

                            com.Parameters.AddWithValue("@p_GeneralLegRefCheck", mdata.GeneralLegRefCheck);
                            com.Parameters.AddWithValue("@p_GeneralTOC", mdata.GeneralTOC);
                            com.Parameters.AddWithValue("@p_GeneralTOS", mdata.GeneralTOS);
                            com.Parameters.AddWithValue("@p_GeneralReprints", mdata.GeneralReprints);
                            com.Parameters.AddWithValue("@p_GeneralFascicleInsertion", mdata.GeneralFascicleInsertion);
                            com.Parameters.AddWithValue("@p_GeneralGraphicLink", mdata.GeneralGraphicLink);
                            com.Parameters.AddWithValue("@p_GeneralGraphicEmbed", mdata.GeneralGraphicEmbed);
                            com.Parameters.AddWithValue("@p_GeneralHandtooling", mdata.GeneralHandtooling);
                            com.Parameters.AddWithValue("@p_GeneralNonContent", mdata.GeneralNonContent);
                            com.Parameters.AddWithValue("@p_GeneralSamplePages", mdata.GeneralSamplePages);
                            com.Parameters.AddWithValue("@p_GeneralComplexTask", mdata.GeneralComplexTask);

                            com.Parameters.AddWithValue("@p_FurtherInstruction", mdata.FurtherInstruction);
                            com.Parameters.AddWithValue("@p_CodingDueDate", mdata.CodingDueDate);

                            com.Parameters.AddWithValue("@p_IsXMLEditing", mdata.IsXMLEditing);
                            com.Parameters.AddWithValue("@p_OnlineDueDate", mdata.OnlineDueDate);
                            com.Parameters.AddWithValue("@p_IsOnline", mdata.IsOnline);
                            //if (mdata.OnlineDueDate >= DateTime.Now)
                            //{
                            //    mdata.OnlineTimeliness = "On Time";
                            //    com.Parameters.AddWithValue("@p_OnlineTimeliness", mdata.OnlineTimeliness);
                            //}
                            //else
                            //{
                            //    mdata.OnlineTimeliness = "Late";
                            //    com.Parameters.AddWithValue("@p_OnlineTimeliness", mdata.OnlineTimeliness);
                            //}
                            if (dbConnection.State == ConnectionState.Closed)
                                dbConnection.Open();
                            int Counto = com.ExecuteNonQuery();
                            com.Parameters.Clear();
                            if (Counto > 0)
                            {
                                mdata.Response = "Y";
                                SendNewCoversheetEmail(mdata);
                            }
                            else
                            {
                                mdata.Response = "N";
                                mdata.ErrorMessage = "Coversheet data could not be added";
                            }
                        }
                    }

                }
                else
                {
                    foreach (var Key in ModelState.Keys)
                    {
                        if (ModelState[Key].Errors.Count > 0)
                        {
                            mdata.Response = "N";
                            mdata.ErrorMessage = ModelState[Key].Errors[0].ErrorMessage;

                            //return Json(new { success = false, responseText = "registration failed, please check", JsonRequestBehavior.AllowGet);
                        }
                    }
                }
                //return Json(mdata, JsonRequestBehavior.AllowGet);

                // Json(new { success = false, responseText = "registration failed, please check", JsonRequestBehavior.AllowGet);
            }
            catch (Exception ex)
            {
                ModelState.AddModelError("ErrorMessage", ex.Message);
                ViewBag.ErrorMessage = ex.Message;
                mdata.Response = "N";
                mdata.ErrorMessage = "Error : " + ex.Message;
            }
            finally
            {
                dbConnection.Close();
            }
            return Json(mdata, JsonRequestBehavior.AllowGet);

        }

        public ActionResult GetJobCoversheetDataCoding()
        {
            if (dbConnection.State == ConnectionState.Closed)
                dbConnection.Open();

            List<CoversheetData> mdata = new List<CoversheetData>();
            DataTable dt = new DataTable();
            var Username = Session["UserName"];

            cmd = new MySqlCommand("GetJobCoversheetData", dbConnection);
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@p_Username", Username);
            cmd.CommandType = CommandType.StoredProcedure;
            adp = new MySqlDataAdapter(cmd);
            adp.Fill(dt);
            foreach (DataRow dr in dt.Rows)
            {
                mdata.Add(new CoversheetData
                {

                    JobCoversheetID = Convert.ToInt32(dr["JobCoversheetID"].ToString()),
                    CoversheetTier = dr["CoversheetTier"].ToString(),
                    BPSProductID = dr["BPSProductID"].ToString(),
                    ServiceNumber = dr["ServiceNumber"].ToString(),
                    LatestTaskNumber = dr["LatestTaskNumber"].ToString(),
                    CodingStatus = dr["CodingStatus"].ToString(),
                    PDFQAStatus = dr["PDFQAStatus"].ToString(),
                    OnlineStatus = dr["OnlineStatus"].ToString(),
                    DateCreated = Convert.ToDateTime(dr["DateCreated"].ToString())

                });
            }
            dbConnection.Close();
            return Json(mdata, JsonRequestBehavior.AllowGet);
        }
        public CoversheetData IsJobExists(string bpsproductid, string servicenumber)
        {
            try
            {
                var jobdata = GetJobData().FirstOrDefault(model => model.BPSProductID == bpsproductid && model.ServiceNumber == servicenumber);
                return jobdata;
            }
            catch (Exception)
            {

                throw;
            }
        }
        public List<CoversheetData> GetJobData()
        {

            List<CoversheetData> mdata = new List<CoversheetData>();
            DataTable dt = new DataTable();

            cmd = new MySqlCommand("GetAllJobCoversheetData", dbConnection);
            cmd.CommandType = CommandType.StoredProcedure;
            adp = new MySqlDataAdapter(cmd);
            adp.Fill(dt);

            if (dbConnection.State == ConnectionState.Closed)
                dbConnection.Open();

            foreach (DataRow dr in dt.Rows)
            {
                mdata.Add(new CoversheetData
                {
                    JobCoversheetID = Convert.ToInt32(dr[0]),
                    //JobNumber = Convert.ToInt32(dr[1]),
                    BPSProductID = Convert.ToString(dr[2]),
                    ServiceNumber = Convert.ToString(dr[3]),
                    DateCreated = Convert.ToDateTime(dr[8])
                });
            }
            dbConnection.Close();
            return mdata;
        }

        public void SendNewCoversheetEmail(CoversheetData mdata)
        {
            if (ModelState.IsValid)
            {
                try
                {
                    using (var mail = new MailMessage())
                    {
                        //const string password = "2544Joey9067!";


                        mail.From = new MailAddress("JobTrack_AUNZ-NoReply@spi-global.com", "JobTrack_AUNZ-NoReply@spi-global.com");
                        mail.CC.Add(new MailAddress("jeffrey.danque@spi-global.com"));
                        mail.CC.Add(new MailAddress("mark.mendoza@straive.com"));
                        mail.CC.Add(new MailAddress("katherine.masangkay@straive.com"));
                        mail.Subject = "[JobTrack AUNZ] New Coversheet data " + mdata.BPSProductID + "_" + mdata.ServiceNumber + "_" + mdata.CoversheetNumber;

                        string body = "<div>" +
                        "<table border=0 cellspacing=1 cellpadding=0 width='100%'" +
                        "style='width:100.0%;mso-cellspacing:.7pt;mso-padding-alt:4.5pt 4.5pt 4.5pt 4.5pt'>" +
                        "<tr>" +
                        "<td valign=top style='background:whitesmoke;padding:4.5pt 4.5pt 4.5pt 4.5pt'>" +
                        "<p>" +
                        "<b>" +
                        "<span style='font-size:12.0pt;font-family:Verdana'>JobTrack AUNZ Manuscript</span>" +
                        "</b>" +
                        "<span style='font-size:12.0pt;font-family:Verdana'></span>" +
                        "</p>" +
                        "</td>" +
                        "</tr>" +
                        "<tr>" +
                        "<td style='padding:4.5pt 4.5pt 4.5pt 4.5pt'>" +
                        "<p>" +
                        "<b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> Date Created: </span>" +
                        "</b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> " + DateTime.Now.ToString("yyyy-MM-dd") + " </span>" +
                        "</p>" +
                        "</td>" +
                        "</tr>" +
                        "<tr style='height:12.25pt'>" +
                        "<td style='padding:4.5pt 4.5pt 4.5pt 4.5pt;height:12.25pt'>" +
                        "<p>" +
                        "<b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> Coversheet Number : </span>" +
                        "</b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> " + mdata.CoversheetNumber + " </span>" +
                        "</p>" +
                        "</td>" +
                        "</tr>" +
                        "<tr style='height:12.25pt'>" +
                        "<td style='padding:4.5pt 4.5pt 4.5pt 4.5pt;height:12.25pt'>" +
                        "<p>" +
                        "<b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> Service Number : </span>" +
                        "</b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> " + mdata.ServiceNumber + " </span>" +
                        "</p>" +
                        "</td>" +
                        "</tr>" +
                        "<tr style='height:7.75pt'>" +
                        "<td style='padding:4.5pt 4.5pt 4.5pt 4.5pt;height:7.75pt'>" +
                        "<p>" +
                        "<b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> Task Number : </span>" +
                        "</b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> " + mdata.TaskNumber + " </span>" +
                        "</p>" +
                        "</td>" +
                        "</tr>" +
                        "<tr style='height:7.75pt'>" +
                        "<td style='padding:4.5pt 4.5pt 4.5pt 4.5pt;height:7.75pt'>" +
                        "<p>" +
                        "<b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> Product : </span>" +
                        "</b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> " + mdata.BPSProductID + " </span>" +
                        "</p>" +
                        "</td>" +
                        "</tr>" +
                        "<tr>" +
                        "<td style='padding:4.5pt 4.5pt 4.5pt 4.5pt'>" +
                        "<p>" +
                        "<b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> Editor :</span>" +
                        "</b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> " + mdata.Editor + " </span>" +
                        "</p>" +
                        "</td>" +
                        "</tr>" +
                        "<tr>" +
                        "<td style='padding:4.5pt 4.5pt 4.5pt 4.5pt'>" +
                        "<p>" +
                        "<b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> Charge Code : </span>" +
                        "</b>" +
                        "<span>" +
                        "<span style='font-size:8.0pt;font-family: Verdana'> " + mdata.ChargeCode + " </span>" +
                        "</span>" +
                        "</td>" +
                        "</tr>" +
                        "<tr>" +
                        "<td style='padding:4.5pt 4.5pt 4.5pt 4.5pt'>" +
                        "<p>" +
                        "<b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> Target Press Date: </span>" +
                        "</b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> " + mdata.TargetPressDate + " </span>" +
                        "</p>" +
                        "</td>" +
                        "</tr>" +
                        "<tr>" +
                        "<td style='padding:4.5pt 4.5pt 4.5pt 4.5pt'>" +
                        "<p>" +
                        "<b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> Task Type: </span>" +
                        "</b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> " + mdata.TaskType + " </span>" +
                        "</p>" +
                        "</td>" +
                        "</tr>" +
                        "<tr>" +
                        "<td style='padding:4.5pt 4.5pt 4.5pt 4.5pt'>" +
                        "<p>" +
                        "<b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> Guide Cards: </span>" +
                        "</b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> " + mdata.GuideCard + " </span>" +
                        "</p>" +
                        "</td>" +
                        "</tr>" +
                        "<tr>" +
                        "<td style='padding:4.5pt 4.5pt 4.5pt 4.5pt'>" +
                        "<p>" +
                        "<b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> Location of manuscript/legislation/further instructions: </span>" +
                        "</b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> " + mdata.LocationOfManuscript + " </span>" +
                        "</p>" +
                        "</td>" +
                        "</tr>" +
                        "<tr>" +
                        "<td style='padding:4.5pt 4.5pt 4.5pt 4.5pt'>" +
                        "<p>" +
                        "<b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> Update Type: </span>" +
                        "</b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> " + mdata.UpdateType + " </span>" +
                        "</p>" +
                        "</td>" +
                        "</tr>" +
                        "<tr>" +
                        "<td style='padding:4.5pt 4.5pt 4.5pt 4.5pt'>" +
                        "<p>" +
                        "<b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> Further Instruction: </span>" +
                        "</b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> " + mdata.FurtherInstruction + " </span>" +
                        "</p>" +
                        "</td>" +
                        "</tr>" +
                            "<tr>" +
                            "<td width=581 style='width:435.8pt;padding:4.5pt 4.5pt 4.5pt 4.5pt'>" +
                            "<p>" +
                            "<span style='font-size:7.0pt;font-family:Verdana'> This is an auto-generated e-mail. No need to reply to this e-mail. </span>" +
                            "</p>" +
                            "</td>" +
                            "</tr>" +
                            "<tr>" +
                            "<td width=581 style='width:435.8pt;padding:4.5pt 4.5pt 4.5pt 4.5pt'>" +
                            "<p>" +
                            "<span style='font-size:7.0pt;font-family:Verdana'> The content of this e-mail message may be privileged and confidential." +
                            "Therefore, if this message has been received in error, please delete it without reading it." +
                            "Your receipt of this message is not intended to waive any applicable privilege." +
                            "Please do not disseminate this message without the permission of the author </span>" +
                            "</p>" +
                            "</td>" +
                            "</tr>" +
                            "</table>" +
                            "</div>";

                        mail.Body = body;
                        mail.IsBodyHtml = true;

                        try
                        {
                            //comment for local
                            //using (var smtpClient = new SmtpClient("smtp.gmail.com", 587))
                            //{
                            //    smtpClient.DeliveryMethod = System.Net.Mail.SmtpDeliveryMethod.Network;
                            //    smtpClient.EnableSsl = true;
                            //    smtpClient.UseDefaultCredentials = false;
                            //    smtpClient.Credentials = new NetworkCredential("jeffrey.b.danque@gmail.com", "nvylrkfuoiwxnfqy");


                            //    smtpClient.Send(mail);
                            //}
                            //comment for live
                            SmtpClient objSmtp = new SmtpClient(ConfigurationManager.AppSettings["smtp_server"].ToString());

                            mail.DeliveryNotificationOptions =
                               DeliveryNotificationOptions.OnSuccess |
                               DeliveryNotificationOptions.OnFailure |
                               DeliveryNotificationOptions.Delay;

                            //SmtpClient objSmtp = new SmtpClient("MySMPTHost");
                            //objSmtp.DeliveryMethod = SmtpDeliveryMethod.SpecifiedPickupDirectory;
                            objSmtp.Timeout = 30000;

                            objSmtp.Send(mail);
                        }

                        finally
                        {
                            //dispose the client
                            mail.Dispose();
                        }

                    }
                }
                catch (SmtpFailedRecipientsException ex)
                {
                    foreach (SmtpFailedRecipientException t in ex.InnerExceptions)
                    {
                        var status = t.StatusCode;
                        if (status == SmtpStatusCode.MailboxBusy ||
                            status == SmtpStatusCode.MailboxUnavailable)
                        {
                            Response.Write("Delivery failed - retrying in 5 seconds.");
                            System.Threading.Thread.Sleep(5000);
                            //resend
                            //smtpClient.Send(message);
                        }
                        else
                        {
                            //Response.Write("Failed to deliver message to {0}",
                            //                  t.FailedRecipient);
                        }
                    }
                }
                catch (SmtpException Se)
                {
                    // handle exception here
                    Response.Write(Se.ToString());
                }

                catch (Exception ex)
                {
                    Response.Write(ex.ToString());
                }
            }
        }
    }
}