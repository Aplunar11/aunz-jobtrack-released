using System;
using System.Linq;
using System.Linq.Dynamic;
using System.Web.Mvc;
using System.Collections.Generic;
using JobTrack.Models.Coversheet;
using JobTrack.Models.Employee;
using System.Configuration;
using System.Data;
using MySql.Data.MySqlClient;
using System.Net.Mail;
using System.Net;

namespace JobTrack.Controllers
{
    public class CoversheetController : Controller
    {
        // CONNECTION STRING
        public MySqlConnection dbConnection = new MySqlConnection(ConfigurationManager.ConnectionStrings["SQLConn"].ConnectionString);
        public MySqlCommand cmd = new MySqlCommand();
        public MySqlDataAdapter adp = new MySqlDataAdapter();
        // CONNECTION STRING FOR USER
        public MySqlConnection dbConnection_User = new MySqlConnection(ConfigurationManager.ConnectionStrings["SQLConn_User"].ConnectionString);
        public MySqlCommand cmd_User = new MySqlCommand();
        public MySqlDataAdapter adp_User = new MySqlDataAdapter();

        public ActionResult GetCoversheetData(string bpsproductid, string servicenumber)
        {
            if (dbConnection.State == ConnectionState.Closed)
                dbConnection.Open();

            List<CoversheetData> mdata = new List<CoversheetData>();
            DataTable dt = new DataTable();

            cmd = new MySqlCommand("GetCoversheetDataByID", dbConnection);
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
                    GuideCard = dr["GuideCard"].ToString(),
                    LocationOfManuscript = dr["LocationOfManuscript"].ToString(),
                    FurtherInstruction = dr["FurtherInstruction"].ToString(),

                    CurrentTask = dr["CurrentTask"].ToString(),
                    TaskStatus = dr["TaskStatus"].ToString(),

                    TargetPressDate = dr.Field<DateTime?>("TargetPressDate"),
                    ActualPressDate = dr.Field<DateTime?>("ActualPressDate"),
                    CodingDueDate = dr.Field<DateTime?>("CodingDueDate"),
                    CodingStartDate = dr.Field<DateTime?>("CodingStartDate"),
                    CodingDoneDate = dr.Field<DateTime?>("CodingDoneDate"),
                    OnlineDueDate = dr.Field<DateTime?>("OnlineDueDate"),
                    OnlineStartDate = dr.Field<DateTime?>("OnlineStartDate"),
                    OnlineDoneDate = dr.Field<DateTime?>("OnlineDoneDate"),
                    OnlineTimeliness = dr["OnlineTimeliness"].ToString(),
                    ReasonIfLate = dr["ReasonIfLate"].ToString(),
                    JobOwner = dr["JobOwner"].ToString()

                });
            }
            dbConnection.Close();
            return Json(mdata, JsonRequestBehavior.AllowGet);
        }
        public ActionResult GetCoversheetDataUserCoding(string bpsproductid, string servicenumber)
        {
            if (dbConnection.State == ConnectionState.Closed)
                dbConnection.Open();

            List<CoversheetData> mdata = new List<CoversheetData>();
            DataTable dt = new DataTable();

            var Username = Session["UserName"];
            cmd = new MySqlCommand("GetCoversheetDataByCoding", dbConnection);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@p_BPSProductID", bpsproductid);
            cmd.Parameters.AddWithValue("@p_ServiceNumber", servicenumber);
            cmd.Parameters.AddWithValue("@p_UserName", Username);
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
                    GuideCard = dr["GuideCard"].ToString(),
                    LocationOfManuscript = dr["LocationOfManuscript"].ToString(),
                    FurtherInstruction = dr["FurtherInstruction"].ToString(),

                    CurrentTask = dr["CurrentTask"].ToString(),
                    TaskStatus = dr["TaskStatus"].ToString(),

                    TargetPressDate = dr.Field<DateTime?>("TargetPressDate"),
                    ActualPressDate = dr.Field<DateTime?>("ActualPressDate"),
                    CodingDueDate = dr.Field<DateTime?>("CodingDueDate"),
                    CodingStartDate = dr.Field<DateTime?>("CodingStartDate"),
                    CodingDoneDate = dr.Field<DateTime?>("CodingDoneDate"),
                    OnlineDueDate = dr.Field<DateTime?>("OnlineDueDate"),
                    OnlineStartDate = dr.Field<DateTime?>("OnlineStartDate"),
                    OnlineDoneDate = dr.Field<DateTime?>("OnlineDoneDate"),
                    OnlineTimeliness = dr["OnlineTimeliness"].ToString(),
                    ReasonIfLate = dr["ReasonIfLate"].ToString(),
                    JobOwner = dr["JobOwner"].ToString()

                });
            }
            dbConnection.Close();
            return Json(mdata, JsonRequestBehavior.AllowGet);
        }
        public List<EmployeeData> GetCoversheetDetails(int coversheetid, string username)
        {

            List<EmployeeData> mdata = new List<EmployeeData>();
            DataTable dt = new DataTable();

            cmd = new MySqlCommand("GetCoversheetCreatedEmail", dbConnection);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Clear();
            cmd.Parameters.AddWithValue("@p_Username", username);
            cmd.Parameters.AddWithValue("@p_CoversheetID", coversheetid);
            adp = new MySqlDataAdapter(cmd);
            adp.Fill(dt);

            if (dbConnection.State == ConnectionState.Closed)
                dbConnection.Open();

            foreach (DataRow dr in dt.Rows)
            {
                mdata.Add(new EmployeeData
                {
                    EmailAddress = Convert.ToString(dr[0])
                });
            }
            return mdata;
        }

        [HttpGet]
        public ActionResult EditCoversheet(string coversheetid, string bpsproductid, string servicenumber)
        {
            EditCoversheetViewModel mdata = new EditCoversheetViewModel();
            mdata.model1 = new CoversheetData();
            try
            {
                //TempData["CodingUser"] = new SelectList(GetAllUser().Where(model => model.UserAccessName == "Coding"), "EmployeeID", "FullName");
                TempData["CodingUser"] = new SelectList(GetAllUser().Where(model => model.UserAccessName == "Coding"), "EmployeeID", "UserName");
                DataTable dt = new DataTable();

                cmd = new MySqlCommand("GetCoversheetDataByCoversheetID", dbConnection);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.Clear();
                cmd.Parameters.AddWithValue("@p_CoversheetID", coversheetid);
                adp = new MySqlDataAdapter(cmd);
                adp.Fill(dt);

                foreach (DataRow dr in dt.Rows)
                {

                    mdata.model1.CoversheetID = Convert.ToInt32(dr["CoversheetID"].ToString());
                    mdata.model1.CoversheetNumber = dr["CoversheetNumber"].ToString();
                    mdata.model1.BPSProductID = dr["BPSProductID"].ToString();
                    mdata.model1.ServiceNumber = dr["ServiceNumber"].ToString();
                    mdata.model1.TaskNumber = dr["TaskNumber"].ToString();
                    mdata.model1.CoversheetTier = dr["CoversheetTier"].ToString();
                    mdata.model1.Editor = dr["Editor"].ToString();
                    mdata.model1.ChargeCode = dr["ChargeCode"].ToString();
                    mdata.model1.TargetPressDate = dr.Field<DateTime?>("TargetPressDate");
                    mdata.model1.ActualPressDate = dr.Field<DateTime?>("ActualPressDate");
                    mdata.model1.CurrentTask = dr["CurrentTask"].ToString();
                    mdata.model1.TaskStatus = dr["TaskStatus"].ToString();
                    mdata.model1.TaskType = dr["TaskType"].ToString();
                    mdata.model1.GuideCard = dr["GuideCard"].ToString();

                    mdata.model1.LocationOfManuscript = dr["LocationOfManuscript"].ToString();
                    mdata.model1.UpdateType = dr["UpdateType"].ToString();
                    mdata.model1.FurtherInstruction = dr["FurtherInstruction"].ToString();

                    mdata.model1.GeneralLegRefCheck = Convert.ToBoolean(Convert.ToInt32(dr["GeneralLegRefCheck"]));
                    mdata.model1.GeneralTOC = Convert.ToBoolean(Convert.ToInt32(dr["GeneralTOC"]));
                    mdata.model1.GeneralTOS = Convert.ToBoolean(Convert.ToInt32(dr["GeneralTOS"]));
                    mdata.model1.GeneralReprints = Convert.ToBoolean(Convert.ToInt32(dr["GeneralReprints"]));
                    mdata.model1.GeneralFascicleInsertion = Convert.ToBoolean(Convert.ToInt32(dr["GeneralFascicleInsertion"]));
                    mdata.model1.GeneralGraphicLink = Convert.ToBoolean(Convert.ToInt32(dr["GeneralGraphicLink"]));
                    mdata.model1.GeneralGraphicEmbed = Convert.ToBoolean(Convert.ToInt32(dr["GeneralGraphicEmbed"]));
                    mdata.model1.GeneralHandtooling = Convert.ToBoolean(Convert.ToInt32(dr["GeneralHandtooling"]));
                    mdata.model1.GeneralNonContent = Convert.ToBoolean(Convert.ToInt32(dr["GeneralNonContent"]));
                    mdata.model1.GeneralSamplePages = Convert.ToBoolean(Convert.ToInt32(dr["GeneralSamplePages"]));
                    mdata.model1.GeneralComplexTask = Convert.ToBoolean(Convert.ToInt32(dr["GeneralComplexTask"]));

                    mdata.model1.AcceptedDate = dr.Field<DateTime?>("AcceptedDate");
                    mdata.model1.JobOwner = dr["JobOwner"].ToString();
                    mdata.model1.UpdateEmailCC = dr["UpdateEmailCC"].ToString();

                    mdata.model1.IsXMLEditing = Convert.ToBoolean(Convert.ToInt32(dr["IsXMLEditing"]));
                    mdata.model1.CodingDueDate = dr.Field<DateTime?>("CodingDueDate");
                    mdata.model1.CodingStartDate = dr.Field<DateTime?>("CodingStartDate");
                    mdata.model1.CodingDoneDate = dr.Field<DateTime?>("CodingDoneDate");

                    mdata.model1.SubTask = dr["SubTask"].ToString();
                    mdata.model1.PDFQAStatus = dr["PDFQAStatus"].ToString();
                    mdata.model1.PDFQCStartDate = dr.Field<DateTime?>("PDFQCStartDate");
                    mdata.model1.PDFQCDoneDate = dr.Field<DateTime?>("PDFQCDoneDate");

                    mdata.model1.XMLStatus = dr["XMLStatus"].ToString();

                    mdata.model1.IsOnline = Convert.ToBoolean(Convert.ToInt32(dr["IsOnline"]));
                    mdata.model1.OnlineDueDate = dr.Field<DateTime?>("OnlineDueDate");
                    mdata.model1.OnlineStartDate = dr.Field<DateTime?>("OnlineStartDate");
                    mdata.model1.OnlineDoneDate = dr.Field<DateTime?>("OnlineDoneDate");
                    mdata.model1.OnlineTimeliness = dr["OnlineTimeliness"].ToString();
                    mdata.model1.ReasonIfLate = dr["ReasonIfLate"].ToString();
                    mdata.model1.DateCreated = Convert.ToDateTime(dr["DateCreated"].ToString());

                    mdata.model1.RevisedOnlineDueDate = dr.Field<DateTime?>("RevisedOnlineDueDate");

                }
                return PartialView(mdata);
            }



            catch (Exception ex)
            {
                ModelState.AddModelError("ErrorMessage", ex.Message);
                mdata.model1.ErrorMessage = ex.Message;
                return PartialView(mdata);
            }
        }
        [HttpPost]
        public JsonResult UpdateStartDateCoding(EditCoversheetViewModelBase mdata)
        {
            try
            {
                if (ModelState.IsValid)
                {
                    if (!string.IsNullOrEmpty(mdata.model1.BPSProductID) && !string.IsNullOrEmpty(mdata.model1.ServiceNumber))
                    {

                        var Username = Session["UserName"];
                        //var JobNumber = Session["JobNumber"];
                        MySqlCommand com = new MySqlCommand("UpdateCoversheetStartDateCoding", dbConnection);
                        com.CommandType = CommandType.StoredProcedure;
                        com.Parameters.AddWithValue("@p_Username", Username);
                        com.Parameters.AddWithValue("@p_CoversheetID", mdata.model1.CoversheetID);
                        com.Parameters.AddWithValue("@p_BPSProductID", mdata.model1.BPSProductID);
                        com.Parameters.AddWithValue("@p_ServiceNumber", mdata.model1.ServiceNumber);
                        com.Parameters.AddWithValue("@p_CodingStartDate", mdata.model1.CodingStartDate);
                        if (mdata.model1.CodingDoneDate == null)
                        {
                            mdata.model1.TaskStatus = "Assigned";
                            com.Parameters.AddWithValue("@p_TaskStatus", mdata.model1.TaskStatus);
                        }
                        if (mdata.model1.CodingStartDate != null && mdata.model1.CodingDoneDate != null)
                        {
                            mdata.model1.TaskStatus = "Closed";
                            com.Parameters.AddWithValue("@p_TaskStatus", mdata.model1.TaskStatus);
                        }
                        if (dbConnection.State == ConnectionState.Closed)
                            dbConnection.Open();
                        int Count = com.ExecuteNonQuery();
                        if (Count > 0)
                        {
                            mdata.model1.Response = "Y";
                        }
                        else
                        {
                            mdata.model1.Response = "N";
                            mdata.model1.ErrorMessage = "Coding data could not be updated";
                        }

                    }
                }
                else
                {
                    foreach (var Key in ModelState.Keys)
                    {
                        if (ModelState[Key].Errors.Count > 0)
                        {
                            mdata.model1.Response = "N";
                            mdata.model1.ErrorMessage = ModelState[Key].Errors[0].ErrorMessage;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ModelState.AddModelError("ErrorMessage", ex.Message);
                ViewBag.ErrorMessage = ex.Message;
                mdata.model1.Response = "N";
                mdata.model1.ErrorMessage = "Error : " + ex.Message;
            }
            finally
            {
                dbConnection.Close();
            }
            return Json(mdata, JsonRequestBehavior.AllowGet);
        }
        [HttpPost]
        public JsonResult UpdateDoneDateCoding(EditCoversheetViewModelBase mdata)
        {
            try
            {
                if (ModelState.IsValid)
                {
                    if (!string.IsNullOrEmpty(mdata.model1.BPSProductID) && !string.IsNullOrEmpty(mdata.model1.ServiceNumber))
                    {

                        var Username = Session["UserName"];
                        //var JobNumber = Session["JobNumber"];
                        MySqlCommand com = new MySqlCommand("UpdateCoversheetDoneDateCoding", dbConnection);
                        com.Parameters.Clear();
                        com.CommandType = CommandType.StoredProcedure;
                        com.Parameters.AddWithValue("@p_Username", Username);
                        com.Parameters.AddWithValue("@p_CoversheetID", mdata.model1.CoversheetID);
                        com.Parameters.AddWithValue("@p_BPSProductID", mdata.model1.BPSProductID);
                        com.Parameters.AddWithValue("@p_ServiceNumber", mdata.model1.ServiceNumber);
                        com.Parameters.AddWithValue("@p_CodingDoneDate", mdata.model1.CodingDoneDate);
                        if (mdata.model1.CodingDoneDate == null)
                        {
                            mdata.model1.TaskStatus = "Assigned";
                            com.Parameters.AddWithValue("@p_TaskStatus", mdata.model1.TaskStatus);
                        }
                        if (mdata.model1.CodingStartDate != null && mdata.model1.CodingDoneDate != null)
                        {
                            mdata.model1.TaskStatus = "Closed";
                            com.Parameters.AddWithValue("@p_TaskStatus", mdata.model1.TaskStatus);
                        }
                        if (dbConnection.State == ConnectionState.Closed)
                            dbConnection.Open();
                        int Count = com.ExecuteNonQuery();

                        if (Count > 0)
                        {
                            mdata.model1.Response = "Y";

                        }
                        else
                        {
                            mdata.model1.Response = "N";
                            mdata.model1.ErrorMessage = "Coding data could not be updated";
                        }

                    }


                }
                else
                {
                    foreach (var Key in ModelState.Keys)
                    {
                        if (ModelState[Key].Errors.Count > 0)
                        {
                            mdata.model1.Response = "N";
                            mdata.model1.ErrorMessage = ModelState[Key].Errors[0].ErrorMessage;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ModelState.AddModelError("ErrorMessage", ex.Message);
                ViewBag.ErrorMessage = ex.Message;
                mdata.model1.Response = "N";
                mdata.model1.ErrorMessage = "Error : " + ex.Message;
            }
            finally
            {
                dbConnection.Close();
            }
            return Json(mdata, JsonRequestBehavior.AllowGet);
        }
        public List<EmployeeData> GetAllUser()
        {
            if (dbConnection_User.State == ConnectionState.Closed)
                dbConnection_User.Open();

            DataTable dt = new DataTable();

            cmd_User = new MySqlCommand("GetAllEmployee", dbConnection_User);
            cmd_User.CommandType = CommandType.StoredProcedure;
            adp_User = new MySqlDataAdapter(cmd_User);
            adp_User.Fill(dt);

            List<Models.Employee.EmployeeData> lst = new List<Models.Employee.EmployeeData>();
            foreach (DataRow dr in dt.Rows)
            {
                lst.Add(new Models.Employee.EmployeeData
                {
                    EmployeeID = Convert.ToInt32(dr[0]),
                    UserAccessName = Convert.ToString(dr[1]),
                    UserName = Convert.ToString(dr[3]),
                    FullName = Convert.ToString(dr[6]),
                    EmailAddress = Convert.ToString(dr[7])
                });
            }
            dbConnection_User.Close();
            return lst;
        }
        public ActionResult GetJobOwnerEmail(int selectedItem)
        {
            var data = GetAllUser().Where(model => model.EmployeeID == selectedItem).FirstOrDefault();

            return Json(data.EmailAddress, JsonRequestBehavior.AllowGet);
        }
        //public EmployeeData GetPEEmail()
        //{
        //    var data = GetAllUser().Where(model => model.UserAccessName == "Straive(PE)").FirstOrDefault();

        //    return data;
        //}
        public EmployeeData GetCoversheetCreatedEmail(int coversheetid, string username)
        {
            try
            {
                var CreatedEmail = GetCoversheetDetails(coversheetid, username).FirstOrDefault();
                return CreatedEmail;
            }
            catch (Exception)
            {

                throw;
            }
        }
        [HttpPost]
        public JsonResult UpdateCodingStartDate(EditCoversheetViewModelBase mdata)
        {
            try
            {
                if (ModelState.IsValid)
                {
                    if (!string.IsNullOrEmpty(mdata.model1.BPSProductID) && !string.IsNullOrEmpty(mdata.model1.ServiceNumber))
                    {
                        var Username = Session["UserName"];
                        MySqlCommand com = new MySqlCommand("UpdateCoversheetCodingStartDate", dbConnection);
                        com.CommandType = CommandType.StoredProcedure;
                        com.Parameters.AddWithValue("@p_Username", Username);
                        com.Parameters.AddWithValue("@p_CoversheetID", mdata.model1.CoversheetID);
                        com.Parameters.AddWithValue("@p_BPSProductID", mdata.model1.BPSProductID);
                        com.Parameters.AddWithValue("@p_ServiceNumber", mdata.model1.ServiceNumber);
                        com.Parameters.AddWithValue("@p_CodingStartDate", mdata.model1.CodingStartDate);

                        com.Parameters.AddWithValue("@p_CurrentTask", "XML Editing");
                        com.Parameters.AddWithValue("@p_TaskStatus", "On-Going");
                        com.Parameters.AddWithValue("@p_CodingStatus", "On-Going");
                        if (dbConnection.State == ConnectionState.Closed)
                            dbConnection.Open();
                        int Count = com.ExecuteNonQuery();
                        if (Count > 0)
                        {
                            mdata.model1.Response = "Y";
                        }
                        else
                        {
                            mdata.model1.Response = "N";
                            mdata.model1.ErrorMessage = "Coversheet data could not be updated";
                        }
                    }
                }
                else
                {
                    foreach (var Key in ModelState.Keys)
                    {
                        if (ModelState[Key].Errors.Count > 0)
                        {
                            mdata.model1.Response = "N";
                            mdata.model1.ErrorMessage = ModelState[Key].Errors[0].ErrorMessage;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ModelState.AddModelError("ErrorMessage", ex.Message);
                ViewBag.ErrorMessage = ex.Message;
                mdata.model1.Response = "N";
                mdata.model1.ErrorMessage = "Error : " + ex.Message;
            }
            finally
            {
                dbConnection.Close();
            }
            return Json(mdata.model1, JsonRequestBehavior.AllowGet);
        }
        [HttpPost]
        public JsonResult UpdateCodingDoneDate(EditCoversheetViewModelBase mdata)
        {
            try
            {
                if (ModelState.IsValid)
                {
                    if (!string.IsNullOrEmpty(mdata.model1.BPSProductID) && !string.IsNullOrEmpty(mdata.model1.ServiceNumber))
                    {
                        var Username = Session["UserName"];
                        MySqlCommand com = new MySqlCommand("UpdateCoversheetCodingDoneDate", dbConnection);
                        com.CommandType = CommandType.StoredProcedure;
                        com.Parameters.AddWithValue("@p_Username", Username);
                        com.Parameters.AddWithValue("@p_CoversheetID", mdata.model1.CoversheetID);
                        com.Parameters.AddWithValue("@p_BPSProductID", mdata.model1.BPSProductID);
                        com.Parameters.AddWithValue("@p_ServiceNumber", mdata.model1.ServiceNumber);
                        com.Parameters.AddWithValue("@p_CodingDoneDate", mdata.model1.CodingDoneDate);

                        com.Parameters.AddWithValue("@p_CurrentTask", "XML Editing");
                        com.Parameters.AddWithValue("@p_TaskStatus", "On-Going");
                        com.Parameters.AddWithValue("@p_CodingStatus", "On-Going");
                        if (dbConnection.State == ConnectionState.Closed)
                            dbConnection.Open();
                        int Count = com.ExecuteNonQuery();

                        if (Count > 0)
                        {
                            mdata.model1.Response = "Y";
                        }
                        else
                        {
                            mdata.model1.Response = "N";
                            mdata.model1.ErrorMessage = "Coversheet data could not be updated";
                        }
                    }
                }
                else
                {
                    foreach (var Key in ModelState.Keys)
                    {
                        if (ModelState[Key].Errors.Count > 0)
                        {
                            mdata.model1.Response = "N";
                            mdata.model1.ErrorMessage = ModelState[Key].Errors[0].ErrorMessage;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ModelState.AddModelError("ErrorMessage", ex.Message);
                ViewBag.ErrorMessage = ex.Message;
                mdata.model1.Response = "N";
                mdata.model1.ErrorMessage = "Error : " + ex.Message;
            }
            finally
            {
                dbConnection.Close();
            }
            return Json(mdata.model1, JsonRequestBehavior.AllowGet);
        }
        [HttpPost]
        public JsonResult UpdatePDFQCStartDate(EditCoversheetViewModelBase mdata)
        {
            try
            {
                if (ModelState.IsValid)
                {
                    if (!string.IsNullOrEmpty(mdata.model1.BPSProductID) && !string.IsNullOrEmpty(mdata.model1.ServiceNumber))
                    {
                        var Username = Session["UserName"];
                        MySqlCommand com = new MySqlCommand("UpdateCoversheetPDFQCStartDate", dbConnection);
                        com.CommandType = CommandType.StoredProcedure;
                        com.Parameters.AddWithValue("@p_Username", Username);
                        com.Parameters.AddWithValue("@p_CoversheetID", mdata.model1.CoversheetID);
                        com.Parameters.AddWithValue("@p_BPSProductID", mdata.model1.BPSProductID);
                        com.Parameters.AddWithValue("@p_ServiceNumber", mdata.model1.ServiceNumber);
                        com.Parameters.AddWithValue("@p_PDFQCStartDate", mdata.model1.PDFQCStartDate);

                        com.Parameters.AddWithValue("@p_CurrentTask", "PDF QC");
                        com.Parameters.AddWithValue("@p_TaskStatus", "On-Going");
                        //com.Parameters.AddWithValue("@p_PDFQAStatus", "New");
                        if (dbConnection.State == ConnectionState.Closed)
                            dbConnection.Open();
                        int Count = com.ExecuteNonQuery();

                        if (Count > 0)
                        {
                            mdata.model1.Response = "Y";
                        }
                        else
                        {
                            mdata.model1.Response = "N";
                            mdata.model1.ErrorMessage = "Coversheet data could not be updated";
                        }
                    }
                }
                else
                {
                    foreach (var Key in ModelState.Keys)
                    {
                        if (ModelState[Key].Errors.Count > 0)
                        {
                            mdata.model1.Response = "N";
                            mdata.model1.ErrorMessage = ModelState[Key].Errors[0].ErrorMessage;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ModelState.AddModelError("ErrorMessage", ex.Message);
                ViewBag.ErrorMessage = ex.Message;
                mdata.model1.Response = "N";
                mdata.model1.ErrorMessage = "Error : " + ex.Message;
            }
            finally
            {
                dbConnection.Close();
            }
            return Json(mdata.model1, JsonRequestBehavior.AllowGet);
        }
        [HttpPost]
        public JsonResult UpdatePDFQCDoneDate(EditCoversheetViewModelBase mdata)
        {
            try
            {
                if (ModelState.IsValid)
                {
                    if (!string.IsNullOrEmpty(mdata.model1.BPSProductID) && !string.IsNullOrEmpty(mdata.model1.ServiceNumber))
                    {
                        var Username = Session["UserName"];
                        MySqlCommand com = new MySqlCommand("UpdateCoversheetPDFQCDoneDate", dbConnection);
                        com.CommandType = CommandType.StoredProcedure;
                        com.Parameters.AddWithValue("@p_Username", Username);
                        com.Parameters.AddWithValue("@p_CoversheetID", mdata.model1.CoversheetID);
                        com.Parameters.AddWithValue("@p_BPSProductID", mdata.model1.BPSProductID);
                        com.Parameters.AddWithValue("@p_ServiceNumber", mdata.model1.ServiceNumber);
                        com.Parameters.AddWithValue("@p_PDFQCDoneDate", mdata.model1.PDFQCDoneDate);

                        com.Parameters.AddWithValue("@p_CurrentTask", "PDF QC");
                        com.Parameters.AddWithValue("@p_TaskStatus", "On-Going");
                        com.Parameters.AddWithValue("@p_CodingStatus", "Completed");
                        //com.Parameters.AddWithValue("@p_PDFQAStatus", "On-Going");
                        if (dbConnection.State == ConnectionState.Closed)
                            dbConnection.Open();
                        int Count = com.ExecuteNonQuery();

                        if (Count > 0)
                        {
                            mdata.model1.Response = "Y";
                        }
                        else
                        {
                            mdata.model1.Response = "N";
                            mdata.model1.ErrorMessage = "Coversheet data could not be updated";
                        }
                    }
                }
                else
                {
                    foreach (var Key in ModelState.Keys)
                    {
                        if (ModelState[Key].Errors.Count > 0)
                        {
                            mdata.model1.Response = "N";
                            mdata.model1.ErrorMessage = ModelState[Key].Errors[0].ErrorMessage;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ModelState.AddModelError("ErrorMessage", ex.Message);
                ViewBag.ErrorMessage = ex.Message;
                mdata.model1.Response = "N";
                mdata.model1.ErrorMessage = "Error : " + ex.Message;
            }
            finally
            {
                dbConnection.Close();
            }
            return Json(mdata.model1, JsonRequestBehavior.AllowGet);
        }
        [HttpPost]
        public JsonResult AssignTask(EditCoversheetViewModelBase mdata)
        {
            try
            {
                var Username = Session["UserName"];
                MySqlCommand com = new MySqlCommand("UpdateCoversheetJobOwner", dbConnection);
                com.CommandType = CommandType.StoredProcedure;
                com.Parameters.AddWithValue("@p_Username", Username);
                com.Parameters.AddWithValue("@p_CoversheetID", mdata.model1.CoversheetID);
                com.Parameters.AddWithValue("@p_BPSProductID", mdata.model1.BPSProductID);
                com.Parameters.AddWithValue("@p_ServiceNumber", mdata.model1.ServiceNumber);
                com.Parameters.AddWithValue("@p_JobOwner", mdata.model1.JobOwner);
                com.Parameters.AddWithValue("@p_UpdateEmailCC", mdata.model1.UpdateEmailCC);
                if (dbConnection.State == ConnectionState.Closed)
                    dbConnection.Open();
                int Count = com.ExecuteNonQuery();

                if (Count > 0)
                {
                    InsertTransactionLog(mdata.model1.CoversheetID, mdata.model1.BPSProductID, mdata.model1.ServiceNumber, mdata.model1.JobOwner, Username.ToString());
                    mdata.model1.Response = "Y";
                    SendAssignTaskEmail(mdata.model1);

                }
                else
                {
                    mdata.model1.Response = "N";
                    mdata.model1.ErrorMessage = "Coversheet data could not be updated";
                }

            }
            catch (Exception ex)
            {
                ModelState.AddModelError("ErrorMessage", ex.Message);
                ViewBag.ErrorMessage = ex.Message;
                mdata.model1.Response = "N";
                mdata.model1.ErrorMessage = "Error : " + ex.Message;
            }
            finally
            {
                dbConnection.Close();
            }
            return Json(mdata.model1, JsonRequestBehavior.AllowGet);
        }
        public void InsertTransactionLog(int CoversheetID, string BPSProductID, string ServiceNumber, string JobOwner, string UserName)
        {
            dbConnection.Close();

            MySqlCommand com = new MySqlCommand("InsertTransactionLogJobCoversheetReassignment", dbConnection);
            com.CommandType = CommandType.StoredProcedure;
            com.Parameters.AddWithValue("@p_CoversheetID", CoversheetID);
            com.Parameters.AddWithValue("@p_BPSProductID", BPSProductID);
            com.Parameters.AddWithValue("@p_JobOwner", JobOwner);
            com.Parameters.AddWithValue("@p_ServiceNumber", ServiceNumber);
            com.Parameters.AddWithValue("@p_UserName", UserName);
            if (dbConnection.State == ConnectionState.Closed)
                dbConnection.Open();
            com.ExecuteNonQuery();
        }
        public void SendAssignTaskEmail(CoversheetData mdata)
        {
            if (ModelState.IsValid)
            {
                try
                {
                    using (var mail = new MailMessage())
                    {
                        //const string password = "2544Joey9067!";


                        mail.From = new MailAddress("JobTrack_AUNZ-NoReply@spi-global.com", "JobTrack_AUNZ-NoReply@spi-global.com");
                        mail.To.Add(new MailAddress(mdata.UpdateEmailCC));
                        mail.CC.Add(new MailAddress("jeffrey.danque@spi-global.com"));
                        mail.CC.Add(new MailAddress("mark.mendoza@straive.com"));
                        mail.CC.Add(new MailAddress("katherine.masangkay@straive.com"));
                        mail.Subject = "[JobTrack AUNZ] New assigned task";

                        string body = "<div>" +
                        "<table border=0 cellspacing=1 cellpadding=0 width='100%'" +
                        "style='width:100.0%;mso-cellspacing:.7pt;mso-padding-alt:4.5pt 4.5pt 4.5pt 4.5pt'>" +
                        "<tr>" +
                        "<td valign=top style='background:whitesmoke;padding:4.5pt 4.5pt 4.5pt 4.5pt'>" +
                        "<p>" +
                        "<b>" +
                        "<span style='font-size:12.0pt;font-family:Verdana'>JobTrack AUNZ Assigned Task Data</span>" +
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
                        "<span style='font-size:8.0pt;font-family:Verdana'> Created By : </span>" +
                        "</b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> " + Session["UserName"] + " </span>" +
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
        public JsonResult CompletedXMLEditing(EditCoversheetViewModelBase mdata)
        {
            try
            {
                if (ModelState.IsValid)
                {
                    if (!string.IsNullOrEmpty(mdata.model1.BPSProductID) && !string.IsNullOrEmpty(mdata.model1.ServiceNumber))
                    {
                        var Username = Session["UserName"];
                        var resultEmail = GetCoversheetCreatedEmail(mdata.model1.CoversheetID, Username.ToString());
                        //var resultEmail = GetPEEmail();
                        MySqlCommand com = new MySqlCommand("InsertSubsequentPass", dbConnection);
                        com.CommandType = CommandType.StoredProcedure;
                        com.Parameters.AddWithValue("@p_Username", Username);
                        com.Parameters.AddWithValue("@p_CoversheetID", mdata.model1.CoversheetID);
                        com.Parameters.AddWithValue("@p_CoversheetNumber", mdata.model1.CoversheetNumber);
                        com.Parameters.AddWithValue("@p_BPSProductID", mdata.model1.BPSProductID);
                        com.Parameters.AddWithValue("@p_ServiceNumber", mdata.model1.ServiceNumber);
                        com.Parameters.AddWithValue("@p_AttachmentBody", mdata.model2.AttachmentBody);

                        com.Parameters.AddWithValue("@p_ActionType", "Completed XML Editing");
                        com.Parameters.AddWithValue("@p_ActionStatus", "Email sent to PE");

                        com.Parameters.AddWithValue("@p_PDFQAStatus", "On-Going");
                        if (dbConnection.State == ConnectionState.Closed)
                            dbConnection.Open();
                        int Count = com.ExecuteNonQuery();

                        if (Count > 0)
                        {
                            mdata.model1.Response = "Y";
                            SendCompletedXMLEditingEmail(mdata, resultEmail);
                        }
                        else
                        {
                            mdata.model1.Response = "N";
                            mdata.model1.ErrorMessage = "cannot send XML Editing Completion";
                        }
                    }
                }
                else
                {
                    foreach (var Key in ModelState.Keys)
                    {
                        if (ModelState[Key].Errors.Count > 0)
                        {
                            mdata.model1.Response = "N";
                            mdata.model1.ErrorMessage = ModelState[Key].Errors[0].ErrorMessage;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ModelState.AddModelError("ErrorMessage", ex.Message);
                ViewBag.ErrorMessage = ex.Message;
                mdata.model1.Response = "N";
                mdata.model1.ErrorMessage = "Error : " + ex.Message;
            }
            finally
            {
                dbConnection.Close();
            }
            return Json(mdata.model1, JsonRequestBehavior.AllowGet);
        }
        public void SendCompletedXMLEditingEmail(EditCoversheetViewModelBase mdata, EmployeeData resultEmail)
        {
            if (ModelState.IsValid)
            {
                try
                {
                    using (var mail = new MailMessage())
                    {
                        mail.From = new MailAddress("JobTrack_AUNZ-NoReply@spi-global.com", "JobTrack_AUNZ-NoReply@spi-global.com");
                        mail.To.Add(new MailAddress(resultEmail.EmailAddress.ToString()));
                        mail.CC.Add(new MailAddress("jeffrey.danque@spi-global.com"));
                        mail.CC.Add(new MailAddress("mark.mendoza@straive.com"));
                        mail.CC.Add(new MailAddress("katherine.masangkay@straive.com"));
                        mail.Subject = "[JobTrack AUNZ] Completed XML Editing";

                        string body = "<div>" +
                        "<table border=0 cellspacing=1 cellpadding=0 width='100%'" +
                        "style='width:100.0%;mso-cellspacing:.7pt;mso-padding-alt:4.5pt 4.5pt 4.5pt 4.5pt'>" +
                        "<tr>" +
                        "<td valign=top style='background:whitesmoke;padding:4.5pt 4.5pt 4.5pt 4.5pt'>" +
                        "<p>" +
                        "<b>" +
                        "<span style='font-size:12.0pt;font-family:Verdana'>JobTrack AUNZ Completed XML Editing </span>" +
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
                        "<span style='font-size:8.0pt;font-family:Verdana'> " + DateTime.Now.ToString("d-MMM-yy") + " </span>" +
                        "</p>" +
                        "</td>" +
                        "</tr>" +
                        "<tr style='height:12.25pt'>" +
                        "<td style='padding:4.5pt 4.5pt 4.5pt 4.5pt;height:12.25pt'>" +
                        "<p>" +
                        "<b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> Created By : </span>" +
                        "</b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> " + Session["UserName"] + " </span>" +
                        "</p>" +
                        "</td>" +
                        "</tr>" +
                        "<tr style='height:12.25pt'>" +
                        "<td style='padding:4.5pt 4.5pt 4.5pt 4.5pt;height:12.25pt'>" +
                        "<p>" +
                        "<b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> Coversheet Number : </span>" +
                        "</b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> " + mdata.model1.CoversheetNumber + " </span>" +
                        "</p>" +
                        "</td>" +
                        "</tr>" +
                        "<tr style='height:12.25pt'>" +
                        "<td style='padding:4.5pt 4.5pt 4.5pt 4.5pt;height:12.25pt'>" +
                        "<p>" +
                        "<b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> Product : </span>" +
                        "</b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> " + mdata.model1.BPSProductID + " </span>" +
                        "</p>" +
                        "</td>" +
                        "</tr>" +
                        "<tr style='height:7.75pt'>" +
                        "<td style='padding:4.5pt 4.5pt 4.5pt 4.5pt;height:7.75pt'>" +
                        "<p>" +
                        "<b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> Service Number : </span>" +
                        "</b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> " + mdata.model1.ServiceNumber + " </span>" +
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
        public JsonResult ProceedToOnline(EditCoversheetViewModelBase mdata)
        {
            try
            {
                if (ModelState.IsValid)
                {
                    if (!string.IsNullOrEmpty(mdata.model1.BPSProductID) && !string.IsNullOrEmpty(mdata.model1.ServiceNumber))
                    {
                        var Username = Session["UserName"];
                        //var resultEmail = GetCoversheetCreatedEmail(mdata.model1.CoversheetID, Username.ToString());
                        //var resultEmail = GetPEEmail();
                        MySqlCommand com = new MySqlCommand("InsertSubsequentPass", dbConnection);
                        com.CommandType = CommandType.StoredProcedure;
                        com.Parameters.AddWithValue("@p_Username", Username);
                        com.Parameters.AddWithValue("@p_CoversheetID", mdata.model1.CoversheetID);
                        com.Parameters.AddWithValue("@p_CoversheetNumber", mdata.model1.CoversheetNumber);
                        com.Parameters.AddWithValue("@p_BPSProductID", mdata.model1.BPSProductID);
                        com.Parameters.AddWithValue("@p_ServiceNumber", mdata.model1.ServiceNumber);
                        com.Parameters.AddWithValue("@p_AttachmentBody", null);

                        com.Parameters.AddWithValue("@p_ActionType", "Proceed To Online");
                        com.Parameters.AddWithValue("@p_ActionStatus", "Email sent to assigned Coding");

                        com.Parameters.AddWithValue("@p_PDFQAStatus", "Completed");
                        if (dbConnection.State == ConnectionState.Closed)
                            dbConnection.Open();
                        int Count = com.ExecuteNonQuery();

                        if (Count > 0)
                        {
                            mdata.model1.Response = "Y";
                            SendProceedToOnlineEmail(mdata);
                        }
                        else
                        {
                            mdata.model1.Response = "N";
                            mdata.model1.ErrorMessage = "cannot send XML Editing Completion";
                        }
                    }
                }
                else
                {
                    foreach (var Key in ModelState.Keys)
                    {
                        if (ModelState[Key].Errors.Count > 0)
                        {
                            mdata.model1.Response = "N";
                            mdata.model1.ErrorMessage = ModelState[Key].Errors[0].ErrorMessage;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ModelState.AddModelError("ErrorMessage", ex.Message);
                ViewBag.ErrorMessage = ex.Message;
                mdata.model1.Response = "N";
                mdata.model1.ErrorMessage = "Error : " + ex.Message;
            }
            finally
            {
                dbConnection.Close();
            }
            return Json(mdata.model1, JsonRequestBehavior.AllowGet);
        }
        public void SendProceedToOnlineEmail(EditCoversheetViewModelBase mdata)
        {
            if (ModelState.IsValid)
            {
                try
                {
                    using (var mail = new MailMessage())
                    {
                        mail.From = new MailAddress("JobTrack_AUNZ-NoReply@spi-global.com", "JobTrack_AUNZ-NoReply@spi-global.com");
                        mail.To.Add(new MailAddress(mdata.model1.UpdateEmailCC));
                        mail.CC.Add(new MailAddress("jeffrey.danque@spi-global.com"));
                        mail.CC.Add(new MailAddress("mark.mendoza@straive.com"));
                        mail.CC.Add(new MailAddress("katherine.masangkay@straive.com"));
                        mail.Subject = "[JobTrack AUNZ] Proceed To Online";

                        string body = "<div>" +
                        "<table border=0 cellspacing=1 cellpadding=0 width='100%'" +
                        "style='width:100.0%;mso-cellspacing:.7pt;mso-padding-alt:4.5pt 4.5pt 4.5pt 4.5pt'>" +
                        "<tr>" +
                        "<td valign=top style='background:whitesmoke;padding:4.5pt 4.5pt 4.5pt 4.5pt'>" +
                        "<p>" +
                        "<b>" +
                        "<span style='font-size:12.0pt;font-family:Verdana'>JobTrack AUNZ Proceed To Online </span>" +
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
                        "<span style='font-size:8.0pt;font-family:Verdana'> " + DateTime.Now.ToString("d-MMM-yy") + " </span>" +
                        "</p>" +
                        "</td>" +
                        "</tr>" +
                        "<tr style='height:12.25pt'>" +
                        "<td style='padding:4.5pt 4.5pt 4.5pt 4.5pt;height:12.25pt'>" +
                        "<p>" +
                        "<b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> Created By : </span>" +
                        "</b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> " + Session["UserName"] + " </span>" +
                        "</p>" +
                        "</td>" +
                        "</tr>" +
                        "<tr style='height:12.25pt'>" +
                        "<td style='padding:4.5pt 4.5pt 4.5pt 4.5pt;height:12.25pt'>" +
                        "<p>" +
                        "<b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> Coversheet Number : </span>" +
                        "</b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> " + mdata.model1.CoversheetNumber + " </span>" +
                        "</p>" +
                        "</td>" +
                        "</tr>" +
                        "<tr style='height:12.25pt'>" +
                        "<td style='padding:4.5pt 4.5pt 4.5pt 4.5pt;height:12.25pt'>" +
                        "<p>" +
                        "<b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> Product : </span>" +
                        "</b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> " + mdata.model1.BPSProductID + " </span>" +
                        "</p>" +
                        "</td>" +
                        "</tr>" +
                        "<tr style='height:7.75pt'>" +
                        "<td style='padding:4.5pt 4.5pt 4.5pt 4.5pt;height:7.75pt'>" +
                        "<p>" +
                        "<b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> Service Number : </span>" +
                        "</b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> " + mdata.model1.ServiceNumber + " </span>" +
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
        [HttpPost]
        public JsonResult UpdateOnlineStartDate(EditCoversheetViewModelBase mdata)
        {
            try
            {
                if (ModelState.IsValid)
                {
                    if (!string.IsNullOrEmpty(mdata.model1.BPSProductID) && !string.IsNullOrEmpty(mdata.model1.ServiceNumber))
                    {
                        var Username = Session["UserName"];
                        MySqlCommand com = new MySqlCommand("UpdateCoversheetOnlineStartDate", dbConnection);
                        com.CommandType = CommandType.StoredProcedure;
                        com.Parameters.AddWithValue("@p_Username", Username);
                        com.Parameters.AddWithValue("@p_CoversheetID", mdata.model1.CoversheetID);
                        com.Parameters.AddWithValue("@p_BPSProductID", mdata.model1.BPSProductID);
                        com.Parameters.AddWithValue("@p_ServiceNumber", mdata.model1.ServiceNumber);
                        com.Parameters.AddWithValue("@p_OnlineStartDate", mdata.model1.OnlineStartDate);

                        com.Parameters.AddWithValue("@p_CurrentTask", "Online");
                        com.Parameters.AddWithValue("@p_TaskStatus", "On-Going");
                        com.Parameters.AddWithValue("@p_OnlineStatus", "On-Going");
                        com.Parameters.AddWithValue("@p_OnlineTimeliness", "On-Going");
                        if (dbConnection.State == ConnectionState.Closed)
                            dbConnection.Open();
                        int Count = com.ExecuteNonQuery();

                        if (Count > 0)
                        {
                            mdata.model1.Response = "Y";
                        }
                        else
                        {
                            mdata.model1.Response = "N";
                            mdata.model1.ErrorMessage = "Coversheet data could not be updated";
                        }
                    }
                }
                else
                {
                    foreach (var Key in ModelState.Keys)
                    {
                        if (ModelState[Key].Errors.Count > 0)
                        {
                            mdata.model1.Response = "N";
                            mdata.model1.ErrorMessage = ModelState[Key].Errors[0].ErrorMessage;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ModelState.AddModelError("ErrorMessage", ex.Message);
                ViewBag.ErrorMessage = ex.Message;
                mdata.model1.Response = "N";
                mdata.model1.ErrorMessage = "Error : " + ex.Message;
            }
            finally
            {
                dbConnection.Close();
            }
            return Json(mdata.model1, JsonRequestBehavior.AllowGet);
        }
        [HttpPost]
        public JsonResult UpdateOnlineDoneDate(EditCoversheetViewModelBase mdata)
        {
            try
            {
                if (ModelState.IsValid)
                {
                    if (!string.IsNullOrEmpty(mdata.model1.BPSProductID) && !string.IsNullOrEmpty(mdata.model1.ServiceNumber))
                    {
                        var Username = Session["UserName"];
                        var resultEmail = GetCoversheetCreatedEmail(mdata.model1.CoversheetID, Username.ToString());
                        MySqlCommand com = new MySqlCommand("UpdateCoversheetOnlineDoneDate", dbConnection);
                        com.CommandType = CommandType.StoredProcedure;
                        com.Parameters.AddWithValue("@p_Username", Username);
                        com.Parameters.AddWithValue("@p_CoversheetID", mdata.model1.CoversheetID);
                        com.Parameters.AddWithValue("@p_BPSProductID", mdata.model1.BPSProductID);
                        com.Parameters.AddWithValue("@p_ServiceNumber", mdata.model1.ServiceNumber);
                        com.Parameters.AddWithValue("@p_OnlineDoneDate", mdata.model1.OnlineDoneDate);

                        com.Parameters.AddWithValue("@p_CurrentTask", "Online");
                        com.Parameters.AddWithValue("@p_TaskStatus", "Completed");
                        com.Parameters.AddWithValue("@p_OnlineStatus", "Completed");

                        if (mdata.model1.OnlineDueDate > (mdata.model1.RevisedOnlineDueDate ?? mdata.model1.OnlineDoneDate))
                        {
                            com.Parameters.AddWithValue("@p_OnlineTimeliness", "Ahead");
                        }
                        else if (mdata.model1.OnlineDueDate == (mdata.model1.RevisedOnlineDueDate ?? mdata.model1.OnlineDoneDate))
                        {
                            com.Parameters.AddWithValue("@p_OnlineTimeliness", "On Time");
                        }
                        else if (mdata.model1.OnlineDueDate < (mdata.model1.RevisedOnlineDueDate ?? mdata.model1.OnlineDoneDate))
                        {
                            com.Parameters.AddWithValue("@p_OnlineTimeliness", "Delay");
                        }
                        if (dbConnection.State == ConnectionState.Closed)
                            dbConnection.Open();
                        int Count = com.ExecuteNonQuery();

                        if (Count > 0)
                        {
                            mdata.model1.Response = "Y";
                            SendCompletedOnlineEmail(mdata, resultEmail);
                        }
                        else
                        {
                            mdata.model1.Response = "N";
                            mdata.model1.ErrorMessage = "Coversheet data could not be updated";
                        }
                    }
                }
                else
                {
                    foreach (var Key in ModelState.Keys)
                    {
                        if (ModelState[Key].Errors.Count > 0)
                        {
                            mdata.model1.Response = "N";
                            mdata.model1.ErrorMessage = ModelState[Key].Errors[0].ErrorMessage;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ModelState.AddModelError("ErrorMessage", ex.Message);
                ViewBag.ErrorMessage = ex.Message;
                mdata.model1.Response = "N";
                mdata.model1.ErrorMessage = "Error : " + ex.Message;
            }
            finally
            {
                dbConnection.Close();
            }
            return Json(mdata.model1, JsonRequestBehavior.AllowGet);
        }
        public void SendCompletedOnlineEmail(EditCoversheetViewModelBase mdata, EmployeeData resultEmail)
        {
            if (ModelState.IsValid)
            {
                try
                {
                    using (var mail = new MailMessage())
                    {
                        mail.From = new MailAddress("JobTrack_AUNZ-NoReply@spi-global.com", "JobTrack_AUNZ-NoReply@spi-global.com");
                        mail.To.Add(new MailAddress(resultEmail.EmailAddress.ToString()));
                        mail.CC.Add(new MailAddress("jeffrey.danque@spi-global.com"));
                        mail.CC.Add(new MailAddress("mark.mendoza@straive.com"));
                        mail.CC.Add(new MailAddress("katherine.masangkay@straive.com"));
                        mail.Subject = "[JobTrack AUNZ] Completed Online";

                        string body = "<div>" +
                        "<table border=0 cellspacing=1 cellpadding=0 width='100%'" +
                        "style='width:100.0%;mso-cellspacing:.7pt;mso-padding-alt:4.5pt 4.5pt 4.5pt 4.5pt'>" +
                        "<tr>" +
                        "<td valign=top style='background:whitesmoke;padding:4.5pt 4.5pt 4.5pt 4.5pt'>" +
                        "<p>" +
                        "<b>" +
                        "<span style='font-size:12.0pt;font-family:Verdana'>JobTrack AUNZ Completed Online </span>" +
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
                        "<span style='font-size:8.0pt;font-family:Verdana'> " + DateTime.Now.ToString("d-MMM-yy") + " </span>" +
                        "</p>" +
                        "</td>" +
                        "</tr>" +
                        "<tr style='height:12.25pt'>" +
                        "<td style='padding:4.5pt 4.5pt 4.5pt 4.5pt;height:12.25pt'>" +
                        "<p>" +
                        "<b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> Created By : </span>" +
                        "</b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> " + Session["UserName"] + " </span>" +
                        "</p>" +
                        "</td>" +
                        "</tr>" +
                        "<tr style='height:12.25pt'>" +
                        "<td style='padding:4.5pt 4.5pt 4.5pt 4.5pt;height:12.25pt'>" +
                        "<p>" +
                        "<b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> Coversheet Number : </span>" +
                        "</b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> " + mdata.model1.CoversheetNumber + " </span>" +
                        "</p>" +
                        "</td>" +
                        "</tr>" +
                        "<tr style='height:12.25pt'>" +
                        "<td style='padding:4.5pt 4.5pt 4.5pt 4.5pt;height:12.25pt'>" +
                        "<p>" +
                        "<b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> Product : </span>" +
                        "</b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> " + mdata.model1.BPSProductID + " </span>" +
                        "</p>" +
                        "</td>" +
                        "</tr>" +
                        "<tr style='height:7.75pt'>" +
                        "<td style='padding:4.5pt 4.5pt 4.5pt 4.5pt;height:7.75pt'>" +
                        "<p>" +
                        "<b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> Service Number : </span>" +
                        "</b>" +
                        "<span style='font-size:8.0pt;font-family:Verdana'> " + mdata.model1.ServiceNumber + " </span>" +
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
        [HttpGet]
        public ActionResult ViewCoversheet(string coversheetid, string bpsproductid, string servicenumber)
        {
            EditCoversheetViewModel mdata = new EditCoversheetViewModel();
            mdata.model1 = new CoversheetData();
            try
            {
                TempData["CodingUser"] = new SelectList(GetAllUser().Where(model => model.UserAccessName == "Coding"), "EmployeeID", "FullName");
                DataTable dt = new DataTable();

                cmd = new MySqlCommand("GetCoversheetDataByCoversheetID", dbConnection);
                cmd.CommandType = CommandType.StoredProcedure;

                cmd.Parameters.Clear();
                cmd.Parameters.AddWithValue("@p_CoversheetID", coversheetid);
                adp = new MySqlDataAdapter(cmd);
                adp.Fill(dt);

                foreach (DataRow dr in dt.Rows)
                {

                    mdata.model1.CoversheetID = Convert.ToInt32(dr["CoversheetID"].ToString());
                    mdata.model1.CoversheetNumber = dr["CoversheetNumber"].ToString();
                    mdata.model1.BPSProductID = dr["BPSProductID"].ToString();
                    mdata.model1.ServiceNumber = dr["ServiceNumber"].ToString();
                    mdata.model1.TaskNumber = dr["TaskNumber"].ToString();
                    mdata.model1.CoversheetTier = dr["CoversheetTier"].ToString();
                    mdata.model1.Editor = dr["Editor"].ToString();
                    mdata.model1.ChargeCode = dr["ChargeCode"].ToString();
                    mdata.model1.TargetPressDate = dr.Field<DateTime?>("TargetPressDate");
                    mdata.model1.ActualPressDate = dr.Field<DateTime?>("ActualPressDate");
                    mdata.model1.CurrentTask = dr["CurrentTask"].ToString();
                    mdata.model1.TaskStatus = dr["TaskStatus"].ToString();
                    mdata.model1.TaskType = dr["TaskType"].ToString();
                    mdata.model1.GuideCard = dr["GuideCard"].ToString();

                    mdata.model1.LocationOfManuscript = dr["LocationOfManuscript"].ToString();
                    mdata.model1.UpdateType = dr["UpdateType"].ToString();
                    mdata.model1.FurtherInstruction = dr["FurtherInstruction"].ToString();

                    mdata.model1.GeneralLegRefCheck = Convert.ToBoolean(Convert.ToInt32(dr["GeneralLegRefCheck"]));
                    mdata.model1.GeneralTOC = Convert.ToBoolean(Convert.ToInt32(dr["GeneralTOC"]));
                    mdata.model1.GeneralTOS = Convert.ToBoolean(Convert.ToInt32(dr["GeneralTOS"]));
                    mdata.model1.GeneralReprints = Convert.ToBoolean(Convert.ToInt32(dr["GeneralReprints"]));
                    mdata.model1.GeneralFascicleInsertion = Convert.ToBoolean(Convert.ToInt32(dr["GeneralFascicleInsertion"]));
                    mdata.model1.GeneralGraphicLink = Convert.ToBoolean(Convert.ToInt32(dr["GeneralGraphicLink"]));
                    mdata.model1.GeneralGraphicEmbed = Convert.ToBoolean(Convert.ToInt32(dr["GeneralGraphicEmbed"]));
                    mdata.model1.GeneralHandtooling = Convert.ToBoolean(Convert.ToInt32(dr["GeneralHandtooling"]));
                    mdata.model1.GeneralNonContent = Convert.ToBoolean(Convert.ToInt32(dr["GeneralNonContent"]));
                    mdata.model1.GeneralSamplePages = Convert.ToBoolean(Convert.ToInt32(dr["GeneralSamplePages"]));
                    mdata.model1.GeneralComplexTask = Convert.ToBoolean(Convert.ToInt32(dr["GeneralComplexTask"]));

                    mdata.model1.AcceptedDate = dr.Field<DateTime?>("AcceptedDate");
                    mdata.model1.JobOwner = dr["JobOwner"].ToString();
                    mdata.model1.UpdateEmailCC = dr["UpdateEmailCC"].ToString();

                    mdata.model1.IsXMLEditing = Convert.ToBoolean(Convert.ToInt32(dr["IsXMLEditing"]));
                    mdata.model1.CodingDueDate = dr.Field<DateTime?>("CodingDueDate");
                    mdata.model1.CodingStartDate = dr.Field<DateTime?>("CodingStartDate");
                    mdata.model1.CodingDoneDate = dr.Field<DateTime?>("CodingDoneDate");

                    mdata.model1.SubTask = dr["SubTask"].ToString();
                    mdata.model1.PDFQAStatus = dr["PDFQAStatus"].ToString();
                    mdata.model1.PDFQCStartDate = dr.Field<DateTime?>("PDFQCStartDate");
                    mdata.model1.PDFQCDoneDate = dr.Field<DateTime?>("PDFQCDoneDate");

                    mdata.model1.XMLStatus = dr["XMLStatus"].ToString();

                    mdata.model1.IsOnline = Convert.ToBoolean(Convert.ToInt32(dr["IsOnline"]));
                    mdata.model1.OnlineDueDate = dr.Field<DateTime?>("OnlineDueDate");
                    mdata.model1.OnlineStartDate = dr.Field<DateTime?>("OnlineStartDate");
                    mdata.model1.OnlineDoneDate = dr.Field<DateTime?>("OnlineDoneDate");
                    mdata.model1.OnlineTimeliness = dr["OnlineTimeliness"].ToString();
                    mdata.model1.ReasonIfLate = dr["ReasonIfLate"].ToString();
                    mdata.model1.DateCreated = Convert.ToDateTime(dr["DateCreated"].ToString());

                    mdata.model1.RevisedOnlineDueDate = dr.Field<DateTime?>("RevisedOnlineDueDate");

                }
                return PartialView(mdata);
            }



            catch (Exception ex)
            {
                ModelState.AddModelError("ErrorMessage", ex.Message);
                mdata.model1.ErrorMessage = ex.Message;
                return PartialView(mdata);
            }
        }
        [HttpPost]
        public JsonResult EditCoversheet(EditCoversheetViewModelBase mdata)
        {
            try
            {
                if (ModelState.IsValid)
                {
                    if (!string.IsNullOrEmpty(mdata.model1.BPSProductID) && !string.IsNullOrEmpty(mdata.model1.ServiceNumber))
                    {
                        var Username = Session["UserName"];
                        MySqlCommand com = new MySqlCommand("UpdateCoversheet", dbConnection);
                        com.CommandType = CommandType.StoredProcedure;
                        com.Parameters.AddWithValue("@p_Username", Username);
                        com.Parameters.AddWithValue("@p_CoversheetID", mdata.model1.CoversheetID);
                        com.Parameters.AddWithValue("@p_CoversheetNumber", mdata.model1.CoversheetNumber);
                        com.Parameters.AddWithValue("@p_BPSProductID", mdata.model1.BPSProductID);
                        com.Parameters.AddWithValue("@p_ServiceNumber", mdata.model1.ServiceNumber);

                        com.Parameters.AddWithValue("@p_LocationOfManuscript", mdata.model1.LocationOfManuscript);
                        com.Parameters.AddWithValue("@p_GuideCard", mdata.model1.GuideCard);

                        com.Parameters.AddWithValue("@p_GeneralLegRefCheck", mdata.model1.GeneralLegRefCheck);
                        com.Parameters.AddWithValue("@p_GeneralTOC", mdata.model1.GeneralTOC);
                        com.Parameters.AddWithValue("@p_GeneralTOS", mdata.model1.GeneralTOS);
                        com.Parameters.AddWithValue("@p_GeneralReprints", mdata.model1.GeneralReprints);
                        com.Parameters.AddWithValue("@p_GeneralFascicleInsertion", mdata.model1.GeneralFascicleInsertion);
                        com.Parameters.AddWithValue("@p_GeneralGraphicLink", mdata.model1.GeneralGraphicLink);
                        com.Parameters.AddWithValue("@p_GeneralGraphicEmbed", mdata.model1.GeneralGraphicEmbed);
                        com.Parameters.AddWithValue("@p_GeneralHandtooling", mdata.model1.GeneralHandtooling);
                        com.Parameters.AddWithValue("@p_GeneralNonContent", mdata.model1.GeneralNonContent);
                        com.Parameters.AddWithValue("@p_GeneralSamplePages", mdata.model1.GeneralSamplePages);
                        com.Parameters.AddWithValue("@p_GeneralComplexTask", mdata.model1.GeneralComplexTask);

                        com.Parameters.AddWithValue("@p_FurtherInstruction", mdata.model1.FurtherInstruction);
                        com.Parameters.AddWithValue("@p_RevisedOnlineDueDate", mdata.model1.RevisedOnlineDueDate);
                        com.Parameters.AddWithValue("@p_ReasonIfLate", mdata.model1.ReasonIfLate);

                        if (dbConnection.State == ConnectionState.Closed)
                            dbConnection.Open();
                        int Count = com.ExecuteNonQuery();

                        if (Count > 0)
                        {
                            mdata.model1.Response = "Y";
                        }
                        else
                        {
                            mdata.model1.Response = "N";
                            mdata.model1.ErrorMessage = "Coversheet data could not be updated";
                        }
                    }
                }
                else
                {
                    foreach (var Key in ModelState.Keys)
                    {
                        if (ModelState[Key].Errors.Count > 0)
                        {
                            mdata.model1.Response = "N";
                            mdata.model1.ErrorMessage = ModelState[Key].Errors[0].ErrorMessage;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ModelState.AddModelError("ErrorMessage", ex.Message);
                ViewBag.ErrorMessage = ex.Message;
                mdata.model1.Response = "N";
                mdata.model1.ErrorMessage = "Error : " + ex.Message;
            }
            finally
            {
                dbConnection.Close();
            }
            return Json(mdata.model1, JsonRequestBehavior.AllowGet);
        }
    }
}