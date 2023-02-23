using MySql.Data.MySqlClient;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Linq;
using System.Web.Mvc;
using JobTrack.Models.Manuscript;
using JobTrack.Models.Job;
using System.Net.Mail;
using System.Net;

namespace JobTrack.Controllers
{
    public class JobController : Controller
    {
        // CONNECTION STRING
        public MySqlConnection dbConnection = new MySqlConnection(ConfigurationManager.ConnectionStrings["SQLConn"].ConnectionString);
        public MySqlCommand cmd = new MySqlCommand();
        public MySqlDataAdapter adp = new MySqlDataAdapter();

        public ActionResult GetJobData()
        {
            if (dbConnection.State == ConnectionState.Closed)
                dbConnection.Open();

            List<JobData> mdata = new List<JobData>();
            DataTable dt = new DataTable();

            cmd = new MySqlCommand("GetAllJobData", dbConnection);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Clear();
            adp = new MySqlDataAdapter(cmd);
            adp.Fill(dt);
            foreach (DataRow dr in dt.Rows)
            {
                mdata.Add(new JobData
                {


                    JobID = Convert.ToInt32(dr["JobID"].ToString()),
                    JobNumber = dr["JobNumber"].ToString().PadLeft(8, '0'),
                    ManuscriptTier = dr["ManuscriptTier"].ToString(),
                    BPSProductID = dr["BPSProductID"].ToString(),
                    ServiceNumber = dr["ServiceNumber"].ToString(),
                    TargetPressDate = Convert.ToDateTime(dr["TargetPressDate"].ToString()),

                    ActualPressDate = dr.Field<DateTime?>("ActualPressDate"),
                    CopyEditStatus = dr["CopyEditStatus"].ToString(),
                    CodingStatus = dr["CodingStatus"].ToString(),
                    OnlineStatus = dr["OnlineStatus"].ToString(),
                    STPStatus = dr["STPStatus"].ToString()

                });
            }
            dbConnection.Close();
            return Json(mdata, JsonRequestBehavior.AllowGet);
        }

        public ActionResult GetJobDataByUserNameLE()
        {
            var Username = Session["UserName"];
            if (dbConnection.State == ConnectionState.Closed)
                dbConnection.Open();

            List<JobData> mdata = new List<JobData>();
            DataTable dt = new DataTable();

            cmd = new MySqlCommand("GetAllJobDataByUserNameLE", dbConnection);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@p_Username", Username);
            adp = new MySqlDataAdapter(cmd);
            adp.Fill(dt);

            foreach (DataRow dr in dt.Rows)
            {

                mdata.Add(new JobData
                {
                    JobID = Convert.ToInt32(dr["JobID"].ToString()),

                    JobNumber = dr["JobNumber"].ToString().PadLeft(8, '0'),
                    ManuscriptTier = dr["ManuscriptTier"].ToString(),
                    BPSProductID = dr["BPSProductID"].ToString(),
                    ServiceNumber = dr["ServiceNumber"].ToString(),
                    TargetPressDate = Convert.ToDateTime(dr["TargetPressDate"].ToString()),

                    ActualPressDate = dr.Field<DateTime?>("ActualPressDate"),
                    CopyEditStatus = dr["CopyEditStatus"].ToString(),
                    CodingStatus = dr["CodingStatus"].ToString(),
                    OnlineStatus = dr["OnlineStatus"].ToString(),
                    STPStatus = dr["STPStatus"].ToString()

                });
            }
            dbConnection.Close();
            return Json(mdata, JsonRequestBehavior.AllowGet);
        }
        public ActionResult GetJobDataByUserNamePE()
        {
            var Username = Session["UserName"];
            if (dbConnection.State == ConnectionState.Closed)
                dbConnection.Open();

            List<JobData> mdata = new List<JobData>();
            DataTable dt = new DataTable();

            cmd = new MySqlCommand("GetAllJobDataByUserNamePE", dbConnection);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@p_Username", Username);
            adp = new MySqlDataAdapter(cmd);
            adp.Fill(dt);

            foreach (DataRow dr in dt.Rows)
            {

                mdata.Add(new JobData
                {
                    JobID = Convert.ToInt32(dr["JobID"].ToString()),

                    JobNumber = dr["JobNumber"].ToString().PadLeft(8, '0'),
                    ManuscriptTier = dr["ManuscriptTier"].ToString(),
                    BPSProductID = dr["BPSProductID"].ToString(),
                    ServiceNumber = dr["ServiceNumber"].ToString(),
                    TargetPressDate = Convert.ToDateTime(dr["TargetPressDate"].ToString()),

                    ActualPressDate = dr.Field<DateTime?>("ActualPressDate"),
                    CopyEditStatus = dr["CopyEditStatus"].ToString(),
                    CodingStatus = dr["CodingStatus"].ToString(),
                    OnlineStatus = dr["OnlineStatus"].ToString(),
                    STPStatus = dr["STPStatus"].ToString()

                });
            }
            dbConnection.Close();
            return Json(mdata, JsonRequestBehavior.AllowGet);
        }


        public ActionResult AddNewJob(string jobcount)
        {
            ManuscriptData mdata = new ManuscriptData();
            try
            {
                mdata.JobNumber = jobcount.PadLeft(8, '0');
                TempData["BPSProductID"] = new SelectList(GetAllPubschedBPSProductID(), "PubschedBPSProductID", "PubschedBPSProductID");
                TempData["UpdateType"] = new SelectList(GetAllTurnAroundTime(), "TurnAroundTimeID", "UpdateType");
                return PartialView(mdata);
            }
            catch (Exception ex)
            {
                ModelState.AddModelError("ErrorMessage", ex.Message);
                mdata.ErrorMessage = ex.Message;
                return PartialView(mdata);
            }
        }

        public List<Models.Manuscript.GetPubschedBPSProductID> GetAllPubschedBPSProductID()
        {
            DataTable dt = new DataTable();

            var Username = Session["UserName"];

            if (dbConnection.State == ConnectionState.Closed)
                dbConnection.Open();

            cmd = new MySqlCommand("GetAllPubschedBPSProductID", dbConnection);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@p_Username", Username);
            adp = new MySqlDataAdapter(cmd);
            adp.Fill(dt);


            List<Models.Manuscript.GetPubschedBPSProductID> lst = new List<Models.Manuscript.GetPubschedBPSProductID>();
            foreach (DataRow dr in dt.Rows)
            {
                lst.Add(new Models.Manuscript.GetPubschedBPSProductID
                {
                    PubschedBPSProductID = Convert.ToString(dr[0])

                });
            }
            return lst;
        }
        [HttpPost]
        public JsonResult GetAllPubschedServiceNumber(string bpsproductid, string servicenumber)
        {

            if (dbConnection.State == ConnectionState.Closed)
                dbConnection.Open();

            List<Models.Manuscript.GetAllPubschedServiceNumber> lst = new List<Models.Manuscript.GetAllPubschedServiceNumber>();

            string storedProcName;
            storedProcName = "GetAllPubschedServiceNumber";

            using (MySqlCommand command = new MySqlCommand(storedProcName, dbConnection))
            {
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.AddWithValue("@p_BPSProductID", bpsproductid);
                if (servicenumber == null)
                    command.Parameters.AddWithValue("@p_ServiceNumber", DBNull.Value);
                else
                    command.Parameters.AddWithValue("@p_ServiceNumber", servicenumber);

                MySqlDataReader reader = command.ExecuteReader();
                if (reader.HasRows)
                {
                    while (reader.Read())
                    {
                        lst.Add(new Models.Manuscript.GetAllPubschedServiceNumber()
                        {
                            PubschedTier = reader[0].ToString(),
                            PubschedBPSProductID = reader[1].ToString(),
                            PubschedServiceNumber = reader[2].ToString(),
                            PubschedTargetPressDate = Convert.ToDateTime(reader[3].ToString())
                        });
                    }
                }
                else
                {
                    lst = new List<Models.Manuscript.GetAllPubschedServiceNumber>();
                }
                reader.Close();
            }
            dbConnection.Close();

            return Json(lst, JsonRequestBehavior.AllowGet);
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
        public ActionResult GetTaskType(int selectedItem)
        {
            var data = GetAllTurnAroundTime().Where(model => model.TurnAroundTimeID == selectedItem).FirstOrDefault();

            return Json(data.TaskType, JsonRequestBehavior.AllowGet);
        }
        public ActionResult GetTATCopyEdit(int selectedItem)
        {
            var data = GetAllTurnAroundTime().Where(model => model.TurnAroundTimeID == selectedItem).FirstOrDefault();
            DateTime d = AddBusinessDays(DateTime.Now, data.TATCopyEdit);
            string result;
            if (data.TATCopyEdit == 0)
            {
                result = null;
            }
            else
            {
                result = d.ToString("d-MMM-yy");
            }
            return Json(result, JsonRequestBehavior.AllowGet);

        }
        public ActionResult GetTATCoding(int selectedItem)
        {
            var data = GetAllTurnAroundTime().Where(model => model.TurnAroundTimeID == selectedItem).FirstOrDefault();
            DateTime d = AddBusinessDays(DateTime.Now, data.TATCoding);
            return Json(d.ToString("d-MMM-yy"), JsonRequestBehavior.AllowGet);

        }
        public ActionResult GetTATOnline(int selectedItem)
        {
            var data = GetAllTurnAroundTime().Where(model => model.TurnAroundTimeID == selectedItem).FirstOrDefault();
            DateTime d = AddBusinessDays(DateTime.Now, data.TATOnline);
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
        public JsonResult AddNewJob(ManuscriptData mdata, JobData jdata)
        {
            try
            {
                if (ModelState.IsValid)
                {
                    if (!string.IsNullOrEmpty(jdata.BPSProductID) && !string.IsNullOrEmpty(jdata.ServiceNumber))
                    {
                        var result = IsJobExists(jdata.BPSProductID, jdata.ServiceNumber);
                        if (result != null)
                        {
                            if (result.JobID == 0 || result.JobID < 0)
                            {
                                mdata.Response = "N";
                                mdata.ErrorMessage = "Entered invalid Product or Service Number";
                            }
                            else
                            {
                                var Username = Session["UserName"];
                                MySqlCommand com = new MySqlCommand("InsertManuscript", dbConnection);
                                com.CommandType = CommandType.StoredProcedure;
                                com.Parameters.AddWithValue("@p_Username", Username);
                                com.Parameters.AddWithValue("@p_ManuscriptTier", mdata.ManuscriptTier);
                                com.Parameters.AddWithValue("@p_BPSProductID", mdata.BPSProductID);
                                com.Parameters.AddWithValue("@p_ServiceNumber", mdata.ServiceNumber);
                                com.Parameters.AddWithValue("@p_ManuscriptLegTitle", mdata.ManuscriptLegTitle);
                                com.Parameters.AddWithValue("@p_TargetPressDate", mdata.TargetPressDate);
                                com.Parameters.AddWithValue("@p_LatupAttribution", mdata.LatupAttribution);
                                com.Parameters.AddWithValue("@p_DateReceivedFromAuthor", mdata.DateReceivedFromAuthor);
                                com.Parameters.AddWithValue("@p_UpdateType", mdata.UpdateType);
                                com.Parameters.AddWithValue("@p_JobSpecificInstruction", mdata.JobSpecificInstruction);
                                com.Parameters.AddWithValue("@p_TaskType", mdata.TaskType);
                                if (mdata.CopyEditDueDate is null)
                                {
                                    com.Parameters.AddWithValue("@p_CopyEditDueDate", null);
                                    com.Parameters.AddWithValue("@p_CopyEditStatus", "Not Applicable");
                                }
                                else
                                {
                                    com.Parameters.AddWithValue("@p_CopyEditDueDate", mdata.CopyEditDueDate);
                                    com.Parameters.AddWithValue("@p_CopyEditStatus", "New");
                                }
                                com.Parameters.AddWithValue("@p_CodingDueDate", mdata.CodingDueDate);
                                com.Parameters.AddWithValue("@p_OnlineDueDate", mdata.OnlineDueDate);
                                if (dbConnection.State == ConnectionState.Closed)
                                    dbConnection.Open();
                                int Count = com.ExecuteNonQuery();

                                if (Count > 0)
                                {
                                    InsertTransactionLog(mdata.BPSProductID, mdata.ServiceNumber, Username.ToString());
                                    mdata.Response = "Y";
                                    SendNewManuscriptEmail(mdata);
                                }
                                else
                                {
                                    mdata.Response = "N";
                                    mdata.ErrorMessage = "Manuscript data could not be added";
                                }

                            }
                        }
                        else
                        {
                            try
                            {
                                var Username = Session["UserName"];
                                MySqlCommand com = new MySqlCommand("InsertJob", dbConnection);
                                com.CommandType = CommandType.StoredProcedure;
                                com.Parameters.AddWithValue("@p_Username", Username);
                                com.Parameters.AddWithValue("@p_ManuscriptTier", mdata.ManuscriptTier);
                                com.Parameters.AddWithValue("@p_BPSProductID", mdata.BPSProductID);
                                com.Parameters.AddWithValue("@p_ServiceNumber", mdata.ServiceNumber);
                                com.Parameters.AddWithValue("@p_ManuscriptLegTitle", mdata.ManuscriptLegTitle);
                                com.Parameters.AddWithValue("@p_TargetPressDate", mdata.TargetPressDate);
                                com.Parameters.AddWithValue("@p_LatupAttribution", mdata.LatupAttribution);
                                com.Parameters.AddWithValue("@p_DateReceivedFromAuthor", mdata.DateReceivedFromAuthor);
                                com.Parameters.AddWithValue("@p_UpdateType", mdata.UpdateType);
                                com.Parameters.AddWithValue("@p_JobSpecificInstruction", mdata.JobSpecificInstruction);
                                com.Parameters.AddWithValue("@p_TaskType", mdata.TaskType);
                                if (mdata.CopyEditDueDate is null)
                                {
                                    com.Parameters.AddWithValue("@p_CopyEditDueDate", null);
                                    com.Parameters.AddWithValue("@p_CopyEditStatus", "Not Applicable");
                                }
                                else
                                {
                                    com.Parameters.AddWithValue("@p_CopyEditDueDate", mdata.CopyEditDueDate);
                                    com.Parameters.AddWithValue("@p_CopyEditStatus", "New");
                                }
                                com.Parameters.AddWithValue("@p_CodingDueDate", mdata.CodingDueDate);
                                com.Parameters.AddWithValue("@p_OnlineDueDate", mdata.OnlineDueDate);
                                if (dbConnection.State == ConnectionState.Closed)
                                    dbConnection.Open();
                                int Count = com.ExecuteNonQuery();

                                InsertTransactionLog(mdata.BPSProductID, mdata.ServiceNumber, Username.ToString());
                                mdata.Response = "Y";
                                SendNewManuscriptEmail(mdata);
                            }
                            catch
                            {
                                mdata.Response = "N";
                                mdata.ErrorMessage = "Job data could not be added";
                            }
                            finally
                            {
                                dbConnection.Close();
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
                        }
                    }
                }
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

        public JobData IsJobExists(string bpsproductid, string servicenumber)
        {
            try
            {
                var jobdata = GetJobDetails().FirstOrDefault(model => model.BPSProductID == bpsproductid && model.ServiceNumber == servicenumber);
                return jobdata;
            }
            catch (Exception)
            {

                throw;
            }
        }
        public List<JobData> GetJobDetails()
        {

            List<JobData> mdata = new List<JobData>();
            DataTable dt = new DataTable();

            cmd = new MySqlCommand("GetAllJobData", dbConnection);
            cmd.CommandType = CommandType.StoredProcedure;
            adp = new MySqlDataAdapter(cmd);
            adp.Fill(dt);

            if (dbConnection.State == ConnectionState.Closed)
                dbConnection.Open();

            foreach (DataRow dr in dt.Rows)
            {
                mdata.Add(new JobData
                {
                    JobID = Convert.ToInt32(dr[0]),
                    JobNumber = Convert.ToString(dr[1]).PadLeft(8, '0'),
                    BPSProductID = Convert.ToString(dr[3]),
                    ServiceNumber = Convert.ToString(dr[4]),
                    DateCreated = Convert.ToDateTime(dr[11])
                });
            }
            dbConnection.Close();
            return mdata;
        }

        public IEnumerable<JobData> GetAllJobDetails()
        {
            List<JobData> mdata = new List<JobData>();
            DataTable dt = new DataTable();

            cmd = new MySqlCommand("GetJobManuscript", dbConnection);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Clear();
            adp = new MySqlDataAdapter(cmd);
            adp.Fill(dt);

            foreach (DataRow dr in dt.Rows)
            {
                mdata.Add(new JobData
                {


                    JobID = Convert.ToInt32(dr["JobID"].ToString()),
                    ManuscriptTier = dr["ManuscriptTier"].ToString(),
                    BPSProductID = dr["BPSProductID"].ToString(),
                    ServiceNumber = dr["ServiceNumber"].ToString(),
                    TargetPressDate = Convert.ToDateTime(dr["TargetPressDate"].ToString()),
                    ActualPressDate = Convert.ToDateTime(dr["ActualPressDate"].ToString()),
                    CopyEditStatus = dr["CopyEditStatus"].ToString(),
                    CodingStatus = dr["CodingStatus"].ToString(),
                    OnlineStatus = dr["OnlineStatus"].ToString(),
                    STPStatus = dr["STPStatus"].ToString()

                });
            }
            return (mdata);
        }
        public ActionResult EditJob()
        {
            JobData mdata = new JobData();
            try
            {
                mdata.DateUpdated = DateTime.Now;
                TempData["JobNumber"] = new SelectList(GetJobDetails(), "JobNumber", "JobNumber");
                return PartialView(mdata);
            }
            catch (Exception ex)
            {
                ModelState.AddModelError("ErrorMessage", ex.Message);
                mdata.ErrorMessage = ex.Message;
                return PartialView(mdata);
            }
        }
        [HttpPost]
        public JsonResult GetJobDataByID(int? jobnumber)
        {

            if (jobnumber != null)
            {
                List<JobData> lst = new List<JobData>();
                if (dbConnection.State == ConnectionState.Closed)
                    dbConnection.Open();



                string storedProcName;
                storedProcName = "GetJobDataByID";

                using (MySqlCommand command = new MySqlCommand(storedProcName, dbConnection))
                {
                    command.CommandType = System.Data.CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@p_JobNumber", jobnumber);
                    MySqlDataReader reader = command.ExecuteReader();
                    if (reader.HasRows)
                    {
                        while (reader.Read())
                        {
                            lst.Add(new JobData
                            {
                                ManuscriptTier = reader[2].ToString(),
                                BPSProductID = reader[3].ToString(),
                                ServiceNumber = reader[4].ToString(),
                                TargetPressDate = Convert.ToDateTime(reader[5].ToString()),
                                CopyEditStatus = reader[7].ToString(),
                                CodingStatus = reader[8].ToString(),
                                OnlineStatus = reader[9].ToString(),
                                STPStatus = reader[10].ToString(),
                                DateCreated = Convert.ToDateTime(reader[11].ToString()),
                                DateUpdated = Convert.ToDateTime(reader[13].ToString()),
                            });
                        }
                    }
                    else
                    {
                        lst = new List<JobData>();
                    }
                    reader.Close();
                }
                dbConnection.Close();

                return Json(lst, JsonRequestBehavior.AllowGet);
            }
            return Json(new EmptyResult(), JsonRequestBehavior.AllowGet);
        }
        [HttpPost]
        public JsonResult EditJob(ManuscriptData mdata, JobData jdata)
        {
            //try
            //{
            //    if (ModelState.IsValid)
            //    {
            //        if (!string.IsNullOrEmpty(jdata.BPSProductID) && !string.IsNullOrEmpty(jdata.ServiceNumber))
            //        {
            //            var result = IsJobExists(jdata.BPSProductID, jdata.ServiceNumber);
            //            if (result != null)
            //            {
            //                if (result.JobID == 0 || result.JobID < 0)
            //                {
            //                    mdata.Response = "N";
            //                    mdata.ErrorMessage = "Entered invalid Product or Service Number";
            //                }
            //                else
            //                {
            //                    var Username = Session["UserName"];
            //                    //var JobNumber = Session["JobNumber"];
            //                    MySqlCommand com = new MySqlCommand("InsertManuscript", dbConnection);
            //                    com.CommandType = CommandType.StoredProcedure;
            //                    com.Parameters.AddWithValue("@p_Username", Username);
            //                    //com.Parameters.AddWithValue("@p_JobNumber", JobNumber);
            //                    com.Parameters.AddWithValue("@p_ManuscriptTier", mdata.ManuscriptTier);
            //                    com.Parameters.AddWithValue("@p_BPSProductID", mdata.BPSProductID);
            //                    com.Parameters.AddWithValue("@p_ServiceNumber", mdata.ServiceNumber);
            //                    com.Parameters.AddWithValue("@p_ManuscriptLegTitle", mdata.ManuscriptLegTitle);
            //                    com.Parameters.AddWithValue("@p_TargetPressDate", mdata.TargetPressDate);
            //                    //com.Parameters.AddWithValue("@p_ActualPressDate", mdata.ActualPressDate);
            //                    com.Parameters.AddWithValue("@p_LatupAttribution", mdata.LatupAttribution);
            //                    com.Parameters.AddWithValue("@p_DateReceivedFromAuthor", mdata.DateReceivedFromAuthor);
            //                    com.Parameters.AddWithValue("@p_UpdateType", mdata.UpdateType);
            //                    com.Parameters.AddWithValue("@p_JobSpecificInstruction", mdata.JobSpecificInstruction);
            //                    com.Parameters.AddWithValue("@p_TaskType", mdata.TaskType);
            //                    com.Parameters.AddWithValue("@p_CopyEditDueDate", mdata.CopyEditDueDate);
            //                    //com.Parameters.AddWithValue("@p_CopyEditStatus", mdata.CopyEditStatus);
            //                    com.Parameters.AddWithValue("@p_CodingDueDate", mdata.CodingDueDate);
            //                    com.Parameters.AddWithValue("@p_OnlineDueDate", mdata.OnlineDueDate);
            //                    //com.Parameters.AddWithValue("@p_STPStatus", mdata.STPStatus);
            //                    if (dbConnection.State == ConnectionState.Closed)
            //                        dbConnection.Open();
            //                    int Count = com.ExecuteNonQuery();

            //                    if (Count > 0)
            //                    {
            //                        mdata.Response = "Y";
            //                    }
            //                    else
            //                    {
            //                        mdata.Response = "N";
            //                        mdata.ErrorMessage = "Manuscript data could not be added";
            //                    }

            //                }
            //            }
            //            else
            //            {
            //                try
            //                {
            //                    var Username = Session["UserName"];
            //                    MySqlCommand com = new MySqlCommand("InsertJob", dbConnection);
            //                    com.CommandType = CommandType.StoredProcedure;
            //                    com.Parameters.AddWithValue("@p_Username", Username);
            //                    com.Parameters.AddWithValue("@p_ManuscriptTier", mdata.ManuscriptTier);
            //                    com.Parameters.AddWithValue("@p_BPSProductID", mdata.BPSProductID);
            //                    com.Parameters.AddWithValue("@p_ServiceNumber", mdata.ServiceNumber);
            //                    com.Parameters.AddWithValue("@p_ManuscriptLegTitle", mdata.ManuscriptLegTitle);
            //                    com.Parameters.AddWithValue("@p_TargetPressDate", mdata.TargetPressDate);
            //                    com.Parameters.AddWithValue("@p_LatupAttribution", mdata.LatupAttribution);
            //                    com.Parameters.AddWithValue("@p_DateReceivedFromAuthor", mdata.DateReceivedFromAuthor);
            //                    com.Parameters.AddWithValue("@p_UpdateType", mdata.UpdateType);
            //                    com.Parameters.AddWithValue("@p_JobSpecificInstruction", mdata.JobSpecificInstruction);
            //                    com.Parameters.AddWithValue("@p_TaskType", mdata.TaskType);
            //                    com.Parameters.AddWithValue("@p_CopyEditDueDate", mdata.CopyEditDueDate);
            //                    com.Parameters.AddWithValue("@p_CodingDueDate", mdata.CodingDueDate);
            //                    com.Parameters.AddWithValue("@p_OnlineDueDate", mdata.OnlineDueDate);
            //                    if (dbConnection.State == ConnectionState.Closed)
            //                        dbConnection.Open();
            //                    int Count = com.ExecuteNonQuery();
            //                    mdata.Response = "Y";
            //                }
            //                catch
            //                {
            //                    mdata.Response = "N";
            //                    mdata.ErrorMessage = "Job data could not be added";
            //                    //mdata.ErrorMessage = resultExecute;
            //                }
            //                finally
            //                {
            //                    dbConnection.Close();
            //                }

            //                // Json(new { success = false, responseText = "registration failed, please check", JsonRequestBehavior.AllowGet);
            //            }
            //        }

            //    }
            //    else
            //    {
            //        foreach (var Key in ModelState.Keys)
            //        {
            //            if (ModelState[Key].Errors.Count > 0)
            //            {
            //                mdata.Response = "N";
            //                mdata.ErrorMessage = ModelState[Key].Errors[0].ErrorMessage;

            //                //return Json(new { success = false, responseText = "registration failed, please check", JsonRequestBehavior.AllowGet);
            //            }
            //        }
            //    }
            //}
            //catch (Exception ex)
            //{
            //    ModelState.AddModelError("ErrorMessage", ex.Message);
            //    ViewBag.ErrorMessage = ex.Message;
            //    mdata.Response = "N";
            //    mdata.ErrorMessage = "Error : " + ex.Message;
            //}
            //finally
            //{
            //    dbConnection.Close();
            //}
            mdata.Response = "N";
            mdata.ErrorMessage = "Function under maintencance";
            return Json(mdata, JsonRequestBehavior.AllowGet);
        }

        public void SendNewManuscriptEmail(ManuscriptData mdata)
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
                        mail.Subject = "[JobTrack AUNZ] New Manuscript data " + mdata.BPSProductID + "_" + mdata.ServiceNumber + "_" + mdata.JobNumber;

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
                        "<span style='font-size:8.0pt;font-family:Verdana'> Job Number : </span>" +
                        "</b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> " + mdata.JobNumber + " </span>" +
                        "</p>" +
                        "</td>" +
                        "</tr>" +
                        "<tr style='height:12.25pt'>" +
                        "<td style='padding:4.5pt 4.5pt 4.5pt 4.5pt;height:12.25pt'>" +
                        "<p>" +
                        "<b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> Tier : </span>" +
                        "</b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> " + mdata.ManuscriptTier + " </span>" +
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
                        "<tr style='height:7.75pt'>" +
                        "<td style='padding:4.5pt 4.5pt 4.5pt 4.5pt;height:7.75pt'>" +
                        "<p>" +
                        "<b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> Service Number : </span>" +
                        "</b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> " + mdata.ServiceNumber + " </span>" +
                        "</p>" +
                        "</td>" +
                        "</tr>" +
                        "<tr>" +
                        "<td style='padding:4.5pt 4.5pt 4.5pt 4.5pt'>" +
                        "<p>" +
                        "<b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> Manuscript/Leg Title :</span>" +
                        "</b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> " + mdata.ManuscriptLegTitle + " </span>" +
                        "</p>" +
                        "</td>" +
                        "</tr>" +
                        "<tr>" +
                        "<td style='padding:4.5pt 4.5pt 4.5pt 4.5pt'>" +
                        "<p>" +
                        "<b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> Target Press Date : </span>" +
                        "</b>" +
                        "<span>" +
                        "<span style='font-size:8.0pt;font-family: Verdana'> " + mdata.TargetPressDate + " </span>" +
                        "</span>" +
                        "</td>" +
                        "</tr>" +
                        "<tr>" +
                        "<td style='padding:4.5pt 4.5pt 4.5pt 4.5pt'>" +
                        "<p>" +
                        "<b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> Latup Attribution: </span>" +
                        "</b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> " + mdata.LatupAttribution + " </span>" +
                        "</p>" +
                        "</td>" +
                        "</tr>" +
                        "<tr>" +
                        "<td style='padding:4.5pt 4.5pt 4.5pt 4.5pt'>" +
                        "<p>" +
                        "<b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> Date Received From Author: </span>" +
                        "</b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> " + mdata.DateReceivedFromAuthor + " </span>" +
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
                        "<span style='font-size:8.0pt;font-family:Verdana'> Job Specific Instruction: </span>" +
                        "</b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> " + mdata.JobSpecificInstruction + " </span>" +
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
                            //    smtpClient.Credentials = new NetworkCredential("jeffrey.b.danque@gmail.com", "xqksmfjgdwjrhqds");


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

        public void InsertTransactionLog(string BPSProductID, string ServiceNumber, string UserName)
        {
            dbConnection.Close();

            MySqlCommand com = new MySqlCommand("InsertTransactionLogJobReassignment", dbConnection);
            com.CommandType = CommandType.StoredProcedure;
            com.Parameters.AddWithValue("@p_BPSProductID", BPSProductID);
            com.Parameters.AddWithValue("@p_ServiceNumber", ServiceNumber);
            com.Parameters.AddWithValue("@p_UserName", UserName);
            if (dbConnection.State == ConnectionState.Closed)
                dbConnection.Open();
            com.ExecuteNonQuery();
        }
    }
}