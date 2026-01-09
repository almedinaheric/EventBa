using Newtonsoft.Json;
using System.Net;
using System.Net.Mail;
using System.Net.Security;
using System.Security.Cryptography.X509Certificates;
using EventBa.Model.Helpers;

namespace EventBa.Subscriber;

    public class EmailService
    {
        public EmailService()
        {
            ServicePointManager.ServerCertificateValidationCallback = 
                delegate (object s, X509Certificate certificate, X509Chain chain, SslPolicyErrors sslPolicyErrors)
                {
                    return true;
                };
        }

        public void SendEmail(string message)
        {
            try
            {
            string smtpServer = Environment.GetEnvironmentVariable("SMTP_SERVER") ?? "smtp.gmail.com";
            int smtpPort = int.Parse(Environment.GetEnvironmentVariable("SMTP_PORT") ?? "587");
            string fromMail = Environment.GetEnvironmentVariable("SMTP_USERNAME") ?? "eventba2025@gmail.com";
            string password = Environment.GetEnvironmentVariable("SMTP_PASSWORD") ?? "kzezoymnrdxlwbdu";
            var emailData = JsonConvert.DeserializeObject<EmailModel>(message);

            var recipientEmail = emailData.Recipient;
            var subject = emailData.Subject;
            var content = emailData.Content;
            
            MailMessage MailMessageObj = new MailMessage();

            MailMessageObj.From = new MailAddress(fromMail);
            MailMessageObj.Subject = subject;
            MailMessageObj.To.Add(recipientEmail);
            MailMessageObj.Body = content;
            MailMessageObj.IsBodyHtml = false;

            var smtpClient = new SmtpClient()
            {
                Host = smtpServer,
                Port = smtpPort,
                Credentials = new NetworkCredential(fromMail, password),
                EnableSsl = true,
                UseDefaultCredentials = false,
                DeliveryMethod = SmtpDeliveryMethod.Network
            };

            smtpClient.Send(MailMessageObj);
            Console.WriteLine($"Email sent successfully to {recipientEmail}");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error sending email: {ex.Message}");
            Console.WriteLine($"Stack trace: {ex.StackTrace}");
        }
    }
}

