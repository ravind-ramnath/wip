/*
 * Generic error object - response
 */
namespace ClientManager.Errors
{
    public class ExceptionHanlder
    {
        public ExceptionHanlder(string _title, string _code, string _desc)
        {
            error.Title = _title;
            error.ErrorCode = _code;
            error.Description = _desc;
        }

        private Error _error = new Error();
        public Error error { get => _error; set => _error = value; }

        public class Error
        {
            public string Title { get; set; }
            public string ErrorCode { get; set; }
            public string Description { get; set; }
        }
    }
}
