using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using JobTrack_AUNZ.Models.CodingStp;
using JobTrack_AUNZ.Models;

namespace JobTrack_AUNZ.Controllers
{
    public class CodingSTPController : Controller
    {
         CodingSTPModel codingstp = new CodingSTPModel();
        BaseModel BM = new BaseModel();
        // GET: CodingSTP
        public ActionResult CodingSTPIndex()
        {
            var row = codingstp.GetCodingSTPMyJobs(0, "", 0);
            this.ViewBag.Product = new SelectList(BM.GetProduct(), "product_id", "product");
            this.ViewBag.Service = new SelectList(BM.GetService(), "service_id", "service_no");
            return View(row);
        }
        public ActionResult CodingSTPSTPLevel()
        {
            var row = codingstp.GetCodingSTPMyJobs(0, "", 0);
            this.ViewBag.Product = new SelectList(BM.GetProduct(), "product_id", "product");
            this.ViewBag.Service = new SelectList(BM.GetService(), "service_id", "service_no");
            return View(row);
        }

        public ActionResult SearchJob(int selectedItem, int product, int service, int uid)
        {
            this.ViewBag.Product = new SelectList(BM.GetProduct(), "product_id", "product");
            this.ViewBag.Service = new SelectList(BM.GetService(), "service_id", "service_no");

            if ((product > 0) && (service <= 0))
            {
                var row_product = BM.GetProduct().Where(model => model.product_id == product).FirstOrDefault();
                var row = codingstp.GetCodingSTPMyJobs(0, "", 0).Where(model => model.Product == row_product.product).ToList();
                return PartialView("CodingSTPSTPLevel", row);
            }
            else if ((product <= 0) && (service > 0))
            {
                var row_service = BM.GetService().Where(model => model.service_id == service).FirstOrDefault();
                var row = codingstp.GetCodingSTPMyJobs(0, "", 0).Where(model => model.ServiceNo == row_service.service_no).ToList();
                return PartialView("CodingSTPSTPLevel", row);
            }
            else if ((product > 0) && (service > 0))
            {
                var row_service = BM.GetService().Where(model => model.service_id == service).FirstOrDefault();
                var row_product = BM.GetProduct().Where(model => model.product_id == product).FirstOrDefault();
                var row = codingstp.GetCodingSTPMyJobs(0, "", 0).Where(model => model.Product == row_product.product && model.ServiceNo == row_service.service_no).ToList();
                return PartialView("CodingSTPSTPLevel", row);
            }
            else
            {
                var row = codingstp.GetCodingSTPMyJobs(0,"",0);
                return PartialView("CodingSTPSTPLevel", row);
            }
        }
    }
}