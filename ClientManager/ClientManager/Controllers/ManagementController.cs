using System;
using Microsoft.AspNetCore.Mvc;
using ClientManager.Models;
using ClientManager.Parser;
using ClientManager.Errors;

namespace ClientManager.Controllers
{
    [Route("api/clientmanager")]
    [Route("api/clientmanager/process")]
    [ApiController]
    public class ManagementController : ControllerBase
    {
        /*POST method - message object containging unstructured content
         * Null check only - error handling managed within the MessageProcessor
         */
        [HttpPost]
        public object process(Message message)
        {
            try
            {
                if (message != null
                    && !string.IsNullOrEmpty(message.message))
                    return MessageProcessor.processMessage(message);
                else
                    return new ExceptionHanlder("Fatal Exception: Null", "-1",
                                                "Required key:message is either Null or Empty");
            }
            catch (Exception)
            {
                return BadRequest();
            }
        }
    }
}