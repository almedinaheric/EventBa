using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using System.Text;
using EventBa.Subscriber;

var factory = new ConnectionFactory()
{
    HostName = Environment.GetEnvironmentVariable("RABBITMQ_HOST") ?? "localhost",
    Port = int.Parse(Environment.GetEnvironmentVariable("RABBITMQ_PORT") ?? "5672"),
    UserName = Environment.GetEnvironmentVariable("RABBITMQ_USERNAME") ?? "guest",
    Password = Environment.GetEnvironmentVariable("RABBITMQ_PASSWORD") ?? "guest",
};

factory.ClientProvidedName = "EventBa Consumer";
var connection = factory.CreateConnection();
var channel = connection.CreateModel();

string exchangeName = "EmailExchange";
string routingKey = "email_queue";
string queueName = "EmailQueue";

channel.ExchangeDeclare(exchangeName, ExchangeType.Direct);
channel.QueueDeclare(queueName, true, false, false, null);
channel.QueueBind(queueName, exchangeName, routingKey, null);

var consumer = new EventingBasicConsumer(channel);

consumer.Received += (sender, args) =>
{
    var body = args.Body.ToArray();
    string message = Encoding.UTF8.GetString(body);

    Console.WriteLine($" [*] Message received: {message.Substring(0, Math.Min(100, message.Length))}...");
    EmailService emailService = new EmailService();
    emailService.SendEmail(message);

    channel.BasicAck(args.DeliveryTag, false);
};

channel.BasicConsume(queueName, false, consumer);

Console.WriteLine(" [*] Waiting for messages. Press [enter] to quit.");
Thread.Sleep(Timeout.Infinite);

channel.Close();
connection.Close();
