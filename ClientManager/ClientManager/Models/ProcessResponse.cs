/* Serialized Response Object
 * Total is formatted - Decimal with 2 places. Cast to string for display purposes
 * TotalExcludingTax - Decimal with 2 places, calculated base on 14% GST. Cast to string for display purposes
 * Tax - Decimal with 2 places, calculated tax amount on total value. Cast to string for display purposes
 */
 using System;

namespace ClientManager.Models
{
    [System.Serializable]
    public class ProcessResponse
    {
        public ProcessResponse(string _vendor,
            string _desc,
            string _date,
            string _ccentre,
            string _total,
            string _method)
        {
            response.Vendor = _vendor.Trim();
            response.Description = _desc.Trim();
            response.EventDate = _date.Trim();
            response.CostCenter = _ccentre.Trim();
            response.Total = Convert.ToString(decimal.Round(Convert.ToDecimal(_total.Trim()), 2, MidpointRounding.AwayFromZero)); //
            response.TotalExcludingTax = Convert.ToString(decimal.Round((Convert.ToDecimal(_total.Trim()) - (Convert.ToDecimal(_total.Trim())
                                                * Convert.ToDecimal(0.14))), 2, MidpointRounding.AwayFromZero));
            response.Tax = Convert.ToString(decimal.Round(((Convert.ToDecimal(_total.Trim())
                                            * Convert.ToDecimal(0.14))), 2, MidpointRounding.AwayFromZero));
            response.PaymentMethod = _method.Trim();
        }

        private Response _response = new Response();
        public Response response { get => _response; set => _response = value; }

        public class Response
        {
            public string Vendor { get; set; }
            public string Description { get; set; }
            public string EventDate { get; set; }
            public string PaymentMethod { get; set; }
            public string CostCenter { get; set; }            
            public string Total { get; set; }
            public string TotalExcludingTax { get; set; }
            public string Tax { get; set; }
        }
    }
}
