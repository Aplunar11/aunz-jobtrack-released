using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using JobTrack_AUNZ.Models.Coding;
using JobTrack_AUNZ.Models;

namespace JobTrack_AUNZ.Controllers
{
    public class CodingController : Controller
    {
        CodingModel coding = new CodingModel();
        BaseModel BM = new BaseModel();

        // GET: Coding
        public ActionResult CodingIndex()
        {
            var row = coding.GetCodingCoversheet();
            this.ViewBag.Product = new SelectList(BM.GetProduct(), "product_id", "product");
            this.ViewBag.Service = new SelectList(BM.GetService(), "service_id", "service_no");

            return View(row);
        }
        public ActionResult CodingMyJob()
        {
            var row = coding.GetCodingCoversheet();
            this.ViewBag.Product = new SelectList(BM.GetProduct(), "product_id", "product");
            this.ViewBag.Service = new SelectList(BM.GetService(), "service_id", "service_no");

            return PartialView(row);
        }
        public ActionResult SearchJob(int selectedItem, int product, int service, int uid)
        {
            this.ViewBag.Product = new SelectList(BM.GetProduct(), "product_id", "product");
            this.ViewBag.Service = new SelectList(BM.GetService(), "service_id", "service_no");

            if ((product > 0) && (service <= 0))
            {
                var row_product = BM.GetProduct().Where(model => model.product_id == product).FirstOrDefault();
                var row = coding.GetCodingCoversheet().Where(model => model.Product == row_product.product).ToList();
                return PartialView("CodingCoversheetLevel", row);
            }
            else if ((product <= 0) && (service > 0))
            {
                var row_service = BM.GetService().Where(model => model.service_id == service).FirstOrDefault();
                var row = coding.GetCodingCoversheet().Where(model => model.ServiceNo == row_service.service_no).ToList();
                return PartialView("CodingCoversheetLevel", row);
            }
            else if ((product > 0) && (service > 0))
            {
                var row_service = BM.GetService().Where(model => model.service_id == service).FirstOrDefault();
                var row_product = BM.GetProduct().Where(model => model.product_id == product).FirstOrDefault();
                var row = coding.GetCodingCoversheet().Where(model => model.Product == row_product.product && model.ServiceNo == row_service.service_no).ToList();
                return PartialView("CodingCoversheetLevel", row);
            }
            else
            {
                this.ViewBag.Product = new SelectList(BM.GetProduct(), "product_id", "product");
                this.ViewBag.Service = new SelectList(BM.GetService(), "service_id", "service_no");
                var row = coding.GetCodingCoversheet();
                return PartialView("CodingCoversheetLevel", row);
            }
        }
    }
}