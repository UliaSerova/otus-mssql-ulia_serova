using System.Text.RegularExpressions;

namespace Validator
{
    public class Validator
    {
        public static string ReplaceFunction(string name)
        {
            return Regex.Replace(name, @"[^0-9a-zA-Z:,]+", "");
        }
    }
}
