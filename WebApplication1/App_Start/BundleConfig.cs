using System.Web;
using System.Web.Optimization;

namespace WebApplication1
{
    public class BundleConfig
    {
        // For more information on bundling, visit https://go.microsoft.com/fwlink/?LinkId=301862
        public static void RegisterBundles(BundleCollection bundles)
        {
            bundles.Add(new ScriptBundle("~/bundles/jquery").Include(
                        "~/Scripts/jquery-{version}.js"));

            bundles.Add(new ScriptBundle("~/bundles/jqueryval").Include(
                        "~/Scripts/jquery.validate*"));

            bundles.Add(new ScriptBundle("~/bundles/unobtrusiveajax").Include(
                        "~/Scripts/jquery.unobtrusive*"));

            // Use the development version of Modernizr to develop with and learn from. Then, when you're
            // ready for production, use the build tool at https://modernizr.com to pick only the tests you need.
            bundles.Add(new ScriptBundle("~/bundles/modernizr").Include(
                        "~/Scripts/modernizr-*"));

            bundles.Add(new ScriptBundle("~/bundles/bootstrap").Include(
                      "~/Scripts/bootstrap.js",
                      "~/Scripts/respond.js"));

            bundles.Add(new ScriptBundle("~/Scripts/vendorJS").Include(
                      "~/Scripts/jquery-3.5.1.min.js",
                      "~/Scripts/umd/popper.min.js",
                      "~/Scripts/bootstrap.min.js",
                      "~/Scripts/jquery.validate.min.js",
                      "~/Scripts/jquery.validate.unobtrusive.min.js",
                      "~/Scripts/jquery.blockUI.js",
                      "~/Scripts/toastr.min.js",
                      "~/Scripts/respond.js",
                      "~/Scripts/jquery-ui-1.13.0.js",
                      "~/temp/Site.js",
                      "~/Scripts/bootstrap-datepicker.min.js",
                      "~/Scripts/bootstrap-select.min.js"));

            bundles.Add(new StyleBundle("~/Content/vendorCSS").Include(
                        "~/Content/bootstrap.min.css",
                        //"~/Content/twitterbootstrap.min.css",
                        "~/Content/font-awesome.min.css",
                        "~/temp/Site.css",
                        "~/Content/toastr.min.css",
                        "~/Content/bundle/jquery-ui.css",

                        "~/Content/bootstrap-datepicker.min.css",
                        "~/Content/bootstrap-select.min.css"));

            // jquery datatables js files
            bundles.Add(new ScriptBundle("~/bundles/datatables").Include(
                        "~/Content/bundle/jquery.dataTables.min.js",
                        //"~/Content/bundle/dataTables.bootstrap4.min.js",
                        "~/Content/bundle/moment.min.js",
                        "~/Content/bundle/dataTables.select.min.js",
                        "~/Content/bundle/dataTables.buttons.min.js",
                        "~/Content/bundle/jszip.min.js",
                        "~/Content/bundle/pdfmake.min.js",
                        "~/Content/bundle/vfs_fonts.js",
                        "~/Content/bundle/buttons.html5.min.js"));

            // jquery datatables css file
            bundles.Add(new StyleBundle("~/Content/datatables").Include(
                      "~/Content/bundle/jquery.dataTables.min.css",
                      //"~/Content/bundle/dataTables.jqueryui.min.css",
                      //"~/Content/bundle/jquery.dataTables.min.css",
                      "~/Content/bundle/dataTables.bootstrap4.min.css",
                      "~/Content/bundle/buttons.dataTables.min.css",
                      "~/Content/bundle/select.dataTables.min.css"));
        }
    }
}
