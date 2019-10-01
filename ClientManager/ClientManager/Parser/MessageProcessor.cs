/* MessageProcessor - responsible for processing and validation of incoming message
 * Extracts XML islands and markup XML information - creates XML document
 */
using ClientManager.Models;
using System.Xml.Linq;
using ClientManager.Errors;
using System;
using System.Linq;

namespace ClientManager.Parser
{
    public class MessageProcessor
    {
        public MessageProcessor()
        {
        }

        //main message processor - parses, validates and contructs the response/error objects
        public static object processMessage(Message message)
        {
            try
            {
                XElement xelement = gatherIslands(message.message);
                string _ccentre = "";

                if (xelement == null)
                    return new ExceptionHanlder("Fatal Exception: Malformed XML", "-1",
                                                    "Parsing Message Object Failed");
                
                if (xelement.Elements("expense").Any() &&
                    xelement.Elements("expense").Elements("payment_method").Any() &&
                    xelement.Elements("vendor").Any() &&
                    xelement.Elements("description").Any() &&
                    xelement.Elements("date").Any())
                {
                    if (!xelement.Elements("expense").Elements("total").Any())
                        return new ExceptionHanlder("Fatal Exception: Missing required element", "-1",
                                                    "TOTAL is required for processing");

                    if (xelement.Elements("expense").Elements("total").Any()
                   && string.IsNullOrEmpty(xelement.Descendants("total").FirstOrDefault()?.Value))
                        return new ExceptionHanlder("Fatal Exception: Parse Error", "-1",
                                                    "TOTAL value cannot be Null or Empty");

                    if (xelement.Elements("expense").Elements("cost_centre").Any()
                   && string.IsNullOrEmpty(xelement.Descendants("cost_centre").FirstOrDefault()?.Value))
                        _ccentre = "UNKNOWN";
                    else if (!xelement.Elements("expense").Elements("cost_centre").Any())
                        _ccentre = "UNKNOWN";
                    else
                        _ccentre = xelement.Descendants("cost_centre").FirstOrDefault()?.Value;

                    return new ProcessResponse(xelement.Element("vendor").Value,
                    xelement.Element("description").Value,
                    xelement.Element("date").Value,
                    _ccentre,
                    xelement.Descendants("total").FirstOrDefault()?.Value,
                    xelement.Descendants("payment_method").FirstOrDefault()?.Value);
                }
                else
                {
                    return new ExceptionHanlder("Fatal Exception: Malformed XML", "-1",
                                                "XML Data is not well formed or missing");
                }  
            }
            catch (Exception e)
            {
                return new ExceptionHanlder("Fatal Exception: Parse Error", "-1",
                                            "XML Data is not well formed or missing. " + e.Message);
            }            
        }

        //create XML content from unstructured text
        private static XElement gatherIslands(string xmls)
        {
            string xmlObject = "<root>";
            int i = 0;

            try
            {
                while (i > -1)
                {
                    xmls = trimmError2(trimmError1(xmls));
                    string xmlx = searchIsland(xmls, searchTags(xmls));
                    if (xmlx == "delete")
                    {
                        xmls = xmls.Replace("<" + searchTags(xmls) + ">", "");
                    }
                    else
                    {
                        xmls = xmls.Replace(xmlx, "");
                        xmlObject = $"{xmlObject}{xmlx}";
                    }

                    i = xmls.IndexOf("<", StringComparison.Ordinal);
                }

                xmlObject = xmlObject + "</root>";
                return XElement.Parse(@xmlObject);
            }
            catch (Exception)
            {
                return null;
            }
        }

        //check position of illegal characters and remove it - < or > including catering for tags not closed correctly. Parent tags
        private static string trimmError1(string aString)
        {
            try
            {
                string original = aString;
                int first = aString.IndexOf("<", StringComparison.Ordinal);
                int second = aString.IndexOf(">", StringComparison.Ordinal);
                aString = aString.Remove(aString.IndexOf("<"), 1);
                int third = aString.IndexOf("<", StringComparison.Ordinal);
                if (third < second)
                {
                    return aString;
                }
                return original;
            }
            catch (Exception)
            {
                return null;
            }
        }

        //check position of illegal characters and remove it - < or > including catering for tags not closed correctly. Descendants where applicable
        private static string trimmError2(string aString)
        {
            try
            {
                string original = aString;
                int first = aString.IndexOf("<", StringComparison.Ordinal);
                int second = aString.IndexOf(">", StringComparison.Ordinal);

                if (second < first)
                {
                    aString = aString.Remove(aString.IndexOf(">"), 1);
                    return aString;
                }
                return original;
            }
            catch (Exception)
            {
                return null;
            }
        }

        //process string to search for possible tags
        private static string searchTags(string aString)
        {
            try
            {
                string tag;
                int first = aString.IndexOf("<", StringComparison.Ordinal);
                int second = aString.IndexOf(">", StringComparison.Ordinal);
                tag = aString.Substring(first + 1, (second - first) - 1);
                return tag.Replace(" ", "");
            }
            catch(Exception)
            {
                return null;
            }
        }

        //validates tags
        private static string searchIsland(string aString, string tag)
        {
            try
            {
                string island;
                int first = aString.IndexOf("<" + tag + ">", StringComparison.Ordinal);
                int second = aString.IndexOf("</" + tag + ">", StringComparison.Ordinal);
                if (second == -1)
                {
                    return "delete";
                }
                island = aString.Substring(first, (second - first)) + "</" + tag + ">";
                return island;
            }
            catch (Exception)
            {
                return null;
            }
        }
    }
}