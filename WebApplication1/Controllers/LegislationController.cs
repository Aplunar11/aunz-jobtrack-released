using System;
using JobTrack.Models;
using System.Linq;
using System.Linq.Dynamic;
using System.Web;
using System.Web.Mvc;
using Microsoft.AspNet.Identity.Owin;
using DataTables.Mvc;
using System.Collections.Generic;
using System.Net;
using System.Data.Entity;
using System.Threading.Tasks;
using JobTrack.Models.Legislation;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using MySql.Data.MySqlClient;

namespace JobTrack.Controllers
{
    public class LegislationController : Controller
    {

        // CONNECTION STRING
        public MySqlConnection dbConnection = new MySqlConnection(ConfigurationManager.ConnectionStrings["SQLConn"].ConnectionString);
        public MySqlCommand cmd = new MySqlCommand();
        public MySqlDataAdapter adp = new MySqlDataAdapter();

        // GET: Legislation
        public ActionResult Legislation()
        {
            List<LegislationData> mdata = new List<LegislationData>();
            DataTable dt = new DataTable();

            cmd = new MySqlCommand("GetAllLegislation", dbConnection);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Clear();
            //cmd.Parameters.AddWithValue("@int_owner", owner);
            adp = new MySqlDataAdapter(cmd);
            adp.Fill(dt);

            foreach (DataRow dr in dt.Rows)
            {
                mdata.Add(new LegislationData
                {


                    LegislationID = Convert.ToInt32(dr["LegislationID"].ToString()),
                    LLE2E = dr["LLE2E"].ToString(),
                    DateEntered = Convert.ToDateTime(dr["DateEntered"].ToString()),
                    Editor = dr["Editor"].ToString(),
                    QAEditor = dr["QAEditor"].ToString(),
                    PrincipalLegislation = dr["PrincipalLegislation"].ToString(),
                    AmendingLegislation = dr["AmendingLegislation"].ToString(),
                    CommencementDate = Convert.ToDateTime(dr["CommencementDate"].ToString()),
                    LegislationComment = dr["LegislationComment"].ToString(),
                    AssentDate = Convert.ToDateTime(dr["AssentDate"].ToString()),
                    AffectedProvisions = dr["AffectedProvisions"].ToString(),
                    UpdateType = dr["UpdateType"].ToString(),
                    Tier = dr["Tier"].ToString(),
                    Publication = dr["Publication"].ToString(),
                    ServiceNumber = dr["ServiceNumber"].ToString(),
                    GuideCard = dr["GuideCard"].ToString(),
                    Jurisdiction = dr["Jurisdiction"].ToString(),
                    TotalOutput = Convert.ToInt32(dr["TotalOutput"].ToString()),
                    ActualEDTOutput = Convert.ToInt32(dr["ActualEDTOutput"].ToString()),
                    Latup = Convert.ToInt32(dr["Latup"].ToString()),
                    CNTsAlpha = Convert.ToInt32(dr["CNTsAlpha"].ToString()),
                    GraphicsWord = Convert.ToInt32(dr["GraphicsWord"].ToString()),
                    GraphicsPDF = Convert.ToInt32(dr["GraphicsPDF"].ToString()),
                    GraphicsOTP = Convert.ToInt32(dr["GraphicsPDF"].ToString()),
                    ActualOnlineOutput = Convert.ToInt32(dr["ActualOnlineOutput"].ToString()),
                    JobIDs = dr["JobIDs"].ToString(),
                    EDTTargetCompletionDate = Convert.ToDateTime(dr["EDTTargetCompletionDate"].ToString()),
                    EDTActualDate = Convert.ToDateTime(dr["EDTActualDate"].ToString()),
                    QCDate = Convert.ToDateTime(dr["QCDate"].ToString()),
                    DateInitiatedOnline = Convert.ToDateTime(dr["DateInitiatedOnline"].ToString()),
                    OnlineCheckingDate = Convert.ToDateTime(dr["OnlineCheckingDate"].ToString()),
                    RevisedOnlineDueDate = Convert.ToDateTime(dr["RevisedOnlineDueDate"].ToString()),
                    OnlineActualDueDate = Convert.ToDateTime(dr["OnlineActualDueDate"].ToString()),
                    BenchmarkMet = dr["BenchmarkMet"].ToString(),
                    ProposedDate = Convert.ToDateTime(dr["ProposedDate"].ToString()),
                    ActualQAOnlineDate = Convert.ToDateTime(dr["ActualQAOnlineDate"].ToString()),
                    LegislationStatus = dr["LegislationStatus"].ToString(),
                    Stage = dr["Stage"].ToString(),
                    StatusCategory = dr["StatusCategory"].ToString(),
                    OnTrackOffTrack = dr["OnTrackOffTrack"].ToString(),
                    ReasonForDelay = dr["ReasonForDelay"].ToString(),
                    StartDateOnHold = Convert.ToDateTime(dr["StartDateOnHold"].ToString()),
                    PostbackToStableDate = Convert.ToDateTime(dr["PostbackToStableDate"].ToString()),
                    TargetPressDate = Convert.ToDateTime(dr["TargetPressDate"].ToString()),
                    SSLRServices = dr["SSLRServices"].ToString(),
                    JiraTickets = dr["JiraTickets"].ToString(),
                    LegislationRemarks = dr["LegislationRemarks"].ToString(),
                    isBilled = dr["isBilled"].ToString()

                });
            }
            return View(mdata);
        }
        public ActionResult AddNewLegislation()
        {
            LegislationData mdata = new LegislationData();
            //LastManuscriptID mid = new LastManuscriptID();
            //this.ViewBag.Service = new SelectList(mid.GetLastManuscriptID(), "service_id", "service_no");
            try
            {
                //TempData["ManuscriptTier"] = new SelectList(GetAllPubschedTier(), "PubSchedTier", "PubSchedTier");
                //TempData["BPSProductID"] = new SelectList(GetAllPubschedBPSProductID(), "PubschedBPSProductID", "PubschedBPSProductID");
                //TempData["UpdateType"] = new SelectList(GetAllTurnAroundTime(), "TurnAroundTimeID", "UpdateType");
                return PartialView(mdata);
            }
            catch (Exception ex)
            {
                ModelState.AddModelError("ErrorMessage", ex.Message);
                mdata.ErrorMessage = ex.Message;
                return PartialView(mdata);
            }
        }

    }
}