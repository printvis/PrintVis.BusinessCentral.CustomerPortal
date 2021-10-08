#if OnPrem
dotnet
{

    assembly("mscorlib")
    {

        type("System.Collections.Generic.List`1"; "List_Of_T") { }
        type("System.Collections.IEnumerator"; "IEnumerator") { }
        type("System.Environment"; "Environment") { }
        type("System.Enum"; "Enum") { }
        type("System.Diagnostics.StackTrace"; "StackTrace") { }
        type("System.Diagnostics.StackFrame"; "StackFrame") { }
        type("System.Reflection.MethodInfo"; "MethodInfo") { }
        type("System.IO.FileMode"; "FileMode") { }
        type("System.IO.FileAccess"; "FileAccess") { }
        type("System.IO.FileStream"; "FileStream") { }
        type("System.Collections.Generic.Dictionary`2"; "Dictionary_Of_T_U") { }
        type("System.Collections.Generic.KeyValuePair`2"; "KeyValuePair_Of_T_U") { }
        type("System.Collections.Generic.IEnumerator`1"; "IEnumerator_Of_T") { }
        type("System.IO.DriveInfo"; "DriveInfo") { }
        type("System.Collections.Generic.IEnumerable`1"; "IEnumerable_Of_T") { }
    }
    assembly("System.Xml")
    {

        Culture = 'neutral';
        PublicKeyToken = 'b77a5c561934e089';
        Version = '4.0.0.0';

        type("System.Xml.XmlTextReader"; "XmlTextReaderPVS") { }
        type("System.Xml.XmlTextWriter"; "XmlTextWriterPVS") { }
        type("System.Xml.WhitespaceHandling"; "WhitespaceHandling") { }
        type("System.Xml.XmlNamedNodeMap"; "XmlNamedNodeMap") { }
        type("System.Xml.XmlComment"; "XmlComment") { }
        type("System.Xml.XmlCDataSection"; "XmlCDataSection") { }
        type("System.Xml.XmlDateTimeSerializationMode"; "XmlDateTimeSerializationMode") { }
    }
    assembly("System")
    {
        Culture = 'neutral';
        PublicKeyToken = 'b77a5c561934e089';
        Version = '4.0.0.0';

        type("System.Net.FtpWebRequest"; "FtpWebRequest") { }
        type("System.Net.FtpWebResponse"; "FtpWebResponse") { }
        type("System.Net.WebHeaderCollection"; "WebHeaderCollection") { }
    }



}
#endif