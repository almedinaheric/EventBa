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
            string fromMail = Environment.GetEnvironmentVariable("SMTP_USERNAME");
            string password = Environment.GetEnvironmentVariable("SMTP_PASSWORD");

            if (string.IsNullOrWhiteSpace(fromMail))
            {
                Console.WriteLine("Error: SMTP_USERNAME environment variable is not set or is empty");
                Console.WriteLine("Please set SMTP_USERNAME environment variable (e.g., export SMTP_USERNAME=your-email@gmail.com)");
                return;
            }

            if (string.IsNullOrWhiteSpace(password))
            {
                Console.WriteLine("Error: SMTP_PASSWORD environment variable is not set or is empty");
                Console.WriteLine("Please set SMTP_PASSWORD environment variable (e.g., export SMTP_PASSWORD=your-app-password)");
                return;
            }

            var emailData = JsonConvert.DeserializeObject<EmailModel>(message);
            if (emailData == null)
            {
                Console.WriteLine("Error: Failed to deserialize email data");
                return;
            }

            var recipientEmail = emailData.Recipient;
            var subject = emailData.Subject;
            var content = emailData.Content;

            if (string.IsNullOrWhiteSpace(recipientEmail))
            {
                Console.WriteLine("Error: Recipient email address is empty");
                return;
            }

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

